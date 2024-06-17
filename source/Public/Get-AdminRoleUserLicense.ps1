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
    [OutputType([System.Collections.ArrayList])]
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

    process {
        Write-Verbose "Retrieving all admin roles"
        $adminRoleNames = (Get-MgDirectoryRole | Where-Object { $null -ne $_.RoleTemplateId }).DisplayName

        Write-Verbose "Filtering admin roles"
        $adminRoles = Get-MgRoleManagementDirectoryRoleDefinition | Where-Object { ($adminRoleNames -contains $_.DisplayName) -and ($_.DisplayName -ne "Directory Synchronization Accounts") }

        foreach ($role in $adminRoles) {
            Write-Verbose "Processing role: $($role.DisplayName)"
            $roleAssignments = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"

            foreach ($assignment in $roleAssignments) {
                Write-Verbose "Processing role assignment for principal ID: $($assignment.PrincipalId)"
                $userDetails = Get-MgUser -UserId $assignment.PrincipalId -Property "DisplayName, UserPrincipalName, Id, OnPremisesSyncEnabled" -ErrorAction SilentlyContinue

                if ($userDetails) {
                    Write-Verbose "Retrieved user details for: $($userDetails.UserPrincipalName)"
                    [void]($userIds.Add($userDetails.Id))
                    [void]($adminRoleUsers.Add([PSCustomObject]@{
                        RoleName          = $role.DisplayName
                        UserName          = $userDetails.DisplayName
                        UserPrincipalName = $userDetails.UserPrincipalName
                        UserId            = $userDetails.Id
                        HybridUser        = [bool]$userDetails.OnPremisesSyncEnabled
                        Licenses          = $null  # Initialize as $null
                    }))
                }
            }
        }

        Write-Verbose "Retrieving licenses for admin role users"
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

    end {
        Write-Host "Disconnecting from Microsoft Graph..." -ForegroundColor Green
        Disconnect-MgGraph | Out-Null
        return $adminRoleUsers
    }
}
