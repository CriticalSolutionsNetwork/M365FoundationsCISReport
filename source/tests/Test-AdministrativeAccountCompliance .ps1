function Test-AdministrativeAccountCompliance {
    [CmdletBinding()]
    param (
        [switch]$SkipGraphConnection
    )
    begin {
        #. C:\Temp\CISAuditResult.ps1
        $validLicenses = @('AAD_PREMIUM', 'AAD_PREMIUM_P2')
    }
    process {
        if (-not $SkipGraphConnection) {
            Connect-MgGraph -Scopes "Directory.Read.All", "User.Read.All", "RoleManagement.Read.Directory" -NoWelcome
        }
        $adminRoles = Get-MgRoleManagementDirectoryRoleDefinition | Where-Object { $_.DisplayName -like "*Admin*" }
        $adminRoleUsers = @()
        foreach ($role in $adminRoles) {
            $roleAssignments = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"
            foreach ($assignment in $roleAssignments) {
                $userDetails = Get-MgUser -UserId $assignment.PrincipalId -Property "DisplayName, UserPrincipalName, Id, OnPremisesSyncEnabled"
                $licenses = (Get-MgUserLicenseDetail -UserId $assignment.PrincipalId).SkuPartNumber -join '|'
                $adminRoleUsers += [PSCustomObject]@{
                    UserName   = $userDetails.UserPrincipalName
                    RoleName   = $role.DisplayName
                    UserId     = $userDetails.Id
                    HybridUser = $userDetails.OnPremisesSyncEnabled
                    Licenses   = $licenses
                }
            }
        }
        $uniqueAdminRoleUsers = $adminRoleUsers | Group-Object -Property UserName | ForEach-Object {
            $first = $_.Group | Select-Object -First 1
            $roles = ($_.Group.RoleName -join ', ')
            $licenses = (($_.Group | Select-Object -ExpandProperty Licenses) -join ',').Split(',') | Select-Object -Unique

            $first | Select-Object UserName, UserId, HybridUser, @{Name = 'Roles'; Expression = { $roles } }, @{Name = 'Licenses'; Expression = { $licenses -join '|' } }
        }
        $nonCompliantUsers = $uniqueAdminRoleUsers | Where-Object {
            $_.HybridUser -or
            -not ($_.Licenses -split '\|' | Where-Object { $validLicenses -contains $_ })
        }
        $failureReasons = $nonCompliantUsers | ForEach-Object {
            $accountType = if ($_.HybridUser) { "Hybrid" } else { "Cloud-Only" }
            $missingLicenses = $validLicenses | Where-Object { $_ -notin ($_.Licenses -split '\|') }
            "$($_.UserName)|$($_.Roles)|$accountType|Missing: $($missingLicenses -join ',')"
        }
        $failureReasons = $failureReasons -join "`n"

        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($nonCompliantUsers) { 'Fail' } else { 'Pass' }
        $auditResult.ELevel = 'E3'
        $auditResult.ProfileLevel = 'L1'
        $auditResult.Rec = '1.1.1'
        $auditResult.RecDescription = "Ensure Administrative accounts are separate and cloud-only"
        $auditResult.CISControlVer = 'v8'
        $auditResult.CISControl = "5.4"
        $auditResult.CISDescription = "Restrict Administrator Privileges to Dedicated Administrator Accounts"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $nonCompliantUsers.Count -eq 0
        $auditResult.Details = "Compliant Accounts: $($uniqueAdminRoleUsers.Count - $nonCompliantUsers.Count); Non-Compliant Accounts: $($nonCompliantUsers.Count)"
        $auditResult.FailureReason = if ($nonCompliantUsers) { "Non-compliant accounts: `nUsername | Roles | HybridStatus | Missing Licence`n$failureReasons" } else { "N/A" }
    }

    end {
        # Output the result
        return $auditResult
    }
}