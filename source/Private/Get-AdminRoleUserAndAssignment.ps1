function Get-AdminRoleUserAndAssignment {
    [CmdletBinding()]
    param ()

    $result = @{}

    # Get the DisplayNames of all admin roles
    $adminRoleNames = (Get-MgDirectoryRole | Where-Object { $null -ne $_.RoleTemplateId }).DisplayName

    # Get Admin Roles
    $adminRoles = Get-MgRoleManagementDirectoryRoleDefinition | Where-Object { ($adminRoleNames -contains $_.DisplayName) -and ($_.DisplayName -ne "Directory Synchronization Accounts") }

    foreach ($role in $adminRoles) {
        Write-Verbose "Processing role: $($role.DisplayName)"
        $roleAssignments = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"

        foreach ($assignment in $roleAssignments) {
            Write-Verbose "Processing role assignment for principal ID: $($assignment.PrincipalId)"
            $userDetails = Get-MgUser -UserId $assignment.PrincipalId -Property "DisplayName, UserPrincipalName, Id, OnPremisesSyncEnabled" -ErrorAction SilentlyContinue

            if ($userDetails) {
                Write-Verbose "Retrieved user details for: $($userDetails.UserPrincipalName)"
                $licenses = Get-MgUserLicenseDetail -UserId $assignment.PrincipalId -ErrorAction SilentlyContinue

                if (-not $result[$role.DisplayName]) {
                    $result[$role.DisplayName] = @()
                }
                $result[$role.DisplayName] += [PSCustomObject]@{
                    AssignmentId = $assignment.Id
                    UserDetails  = $userDetails
                    Licenses     = $licenses
                }
            }
        }
    }

    return $result
}
