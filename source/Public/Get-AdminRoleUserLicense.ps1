<#
.SYNOPSIS
    Retrieves user licenses and roles for administrative accounts from Microsoft 365 via the Graph API.
.DESCRIPTION
    The Get-AdminRoleUserLicense function connects to Microsoft Graph and retrieves all users who are assigned administrative roles along with their user details and licenses. This function is useful for auditing and compliance checks to ensure that administrators have appropriate licenses and role assignments.
.PARAMETER SkipGraphConnection
    A switch parameter that, when set, skips the connection to Microsoft Graph if already established. This is useful for batch processing or when used within scripts where multiple calls are made and the connection is managed externally.
.EXAMPLE
    PS> Get-AdminRoleUserLicense

    This example retrieves all administrative role users along with their licenses by connecting to Microsoft Graph using the default scopes.
.EXAMPLE
    PS> Get-AdminRoleUserLicense -SkipGraphConnection

    This example retrieves all administrative role users along with their licenses without attempting to connect to Microsoft Graph, assuming that the connection is already established.
.INPUTS
    None. You cannot pipe objects to Get-AdminRoleUserLicense.
.OUTPUTS
    PSCustomObject
    Returns a custom object for each user with administrative roles that includes the following properties: RoleName, UserName, UserPrincipalName, UserId, HybridUser, and Licenses.
.NOTES
    Creation Date:  2024-04-15
    Purpose/Change: Initial function development to support Microsoft 365 administrative role auditing.
.LINK
    https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-AdminRoleUserLicense
#>
function Get-AdminRoleUserLicense {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$SkipGraphConnection
    )

    begin {
        if (-not $SkipGraphConnection) {
            Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -NoWelcome
        }

        $adminRoleUsers = [System.Collections.ArrayList]::new()
        $userIds = [System.Collections.ArrayList]::new()
    }

    Process {
        $adminroles = Get-MgRoleManagementDirectoryRoleDefinition | Where-Object { $_.DisplayName -like "*Admin*" }

        foreach ($role in $adminroles) {
            $usersInRole = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"

            foreach ($user in $usersInRole) {
                $userDetails = Get-MgUser -UserId $user.PrincipalId -Property "DisplayName, UserPrincipalName, Id, onPremisesSyncEnabled" -ErrorAction SilentlyContinue

                if ($userDetails) {
                    [void]($userIds.Add($user.PrincipalId))
                    [void](
                        $adminRoleUsers.Add(
                            [PSCustomObject]@{
                                RoleName          = $role.DisplayName
                                UserName          = $userDetails.DisplayName
                                UserPrincipalName = $userDetails.UserPrincipalName
                                UserId            = $userDetails.Id
                                HybridUser        = $userDetails.onPremisesSyncEnabled
                                Licenses          = $null  # Initialize as $null
                            }
                        )
                    )
                }
            }
        }

        foreach ($userId in $userIds.ToArray() | Select-Object -Unique) {
            $licenses = Get-MgUserLicenseDetail -UserId $userId -ErrorAction SilentlyContinue
            if ($licenses) {
                $licenseList = ($licenses.SkuPartNumber -join '|')
                $adminRoleUsers.ToArray() | Where-Object { $_.UserId -eq $userId } | ForEach-Object {
                    $_.Licenses = $licenseList
                }
            }
        }
    }

    End {
        Write-Host "Disconnecting from Microsoft Graph..." -ForegroundColor Green
        Disconnect-MgGraph | Out-Null
        return $adminRoleUsers
    }
}
