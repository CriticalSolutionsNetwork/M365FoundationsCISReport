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

        $adminRoleUsers = @()
        $userIds = @()
    }

    Process {
        $adminroles = Get-MgRoleManagementDirectoryRoleDefinition | Where-Object { $_.DisplayName -like "*Admin*" }

        foreach ($role in $adminroles) {
            $usersInRole = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"

            foreach ($user in $usersInRole) {
                $userDetails = Get-MgUser -UserId $user.PrincipalId -Property "DisplayName, UserPrincipalName, Id, onPremisesSyncEnabled" -ErrorAction SilentlyContinue

                if ($userDetails) {
                    $userIds += $user.PrincipalId
                    $adminRoleUsers += [PSCustomObject]@{
                        RoleName = $role.DisplayName
                        UserName = $userDetails.DisplayName
                        UserPrincipalName = $userDetails.UserPrincipalName
                        UserId = $userDetails.Id
                        HybridUser = $userDetails.onPremisesSyncEnabled
                        Licenses = $null  # Initialize as $null
                    }
                }
            }
        }

        foreach ($userId in $userIds | Select-Object -Unique) {
            $licenses = Get-MgUserLicenseDetail -UserId $userId -ErrorAction SilentlyContinue
            if ($licenses) {
                $licenseList = ($licenses.SkuPartNumber -join '|')
                $adminRoleUsers | Where-Object { $_.UserId -eq $userId } | ForEach-Object {
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