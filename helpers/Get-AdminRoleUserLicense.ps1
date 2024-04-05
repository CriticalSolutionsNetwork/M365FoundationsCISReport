function Get-AdminRoleUserLicense {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [bool]$SkipGraphConnection = $false
    )

    # Connect to Microsoft Graph if not skipping connection
    if (-not $SkipGraphConnection) {
        Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -NoWelcome
    }

    $adminRoleUsers = @()
    $userIds = @()
    $adminroles = Get-MgRoleManagementDirectoryRoleDefinition | Where-Object { $_.DisplayName -like "*Admin*" }

    foreach ($role in $adminroles) {
        $usersInRole = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"

        foreach ($user in $usersInRole) {
            $userIds += $user.PrincipalId
            $userDetails = Get-MgUser -UserId $user.PrincipalId -Property "DisplayName, UserPrincipalName, Id, onPremisesSyncEnabled"

            $adminRoleUsers += [PSCustomObject]@{
                RoleName = $role.DisplayName
                UserName = $userDetails.DisplayName
                UserPrincipalName = $userDetails.UserPrincipalName
                UserId = $userDetails.Id
                HybridUser = $userDetails.onPremisesSyncEnabled
                Licenses = ""  # Placeholder for licenses, to be filled later
            }
        }
    }

    foreach ($userId in $userIds | Select-Object -Unique) {
        $licenses = Get-MgUserLicenseDetail -UserId $userId
        $licenseList = ($licenses.SkuPartNumber -join '|')

        $adminRoleUsers | Where-Object { $_.UserId -eq $userId } | ForEach-Object {
            $_.Licenses = $licenseList
        }
    }

    return $adminRoleUsers
}