function Test-AdministrativeAccountCompliance {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    [OutputType([CISAuditResult])]
    param (
        # Parameters can be added if needed
    )

    begin {
        $validLicenses = @('AAD_PREMIUM', 'AAD_PREMIUM_P2')
        $recnum = "1.1.1"
    }

    process {
        try {
            # Retrieve all necessary data outside the loops
            $adminRoles = Get-MgRoleManagementDirectoryRoleDefinition | Where-Object { $_.DisplayName -like "*Admin*" }
            $roleAssignments = Get-MgRoleManagementDirectoryRoleAssignment
            $principalIds = $roleAssignments.PrincipalId | Select-Object -Unique

            # Fetch user details using filter
            $userDetailsList = @{}
            $licensesList = @{}

            $userDetails = Get-MgUser -Filter "id in ('$($principalIds -join "','")')" -Property "DisplayName, UserPrincipalName, Id, OnPremisesSyncEnabled" -ErrorAction SilentlyContinue
            foreach ($user in $userDetails) {
                $userDetailsList[$user.Id] = $user
            }

            # Fetch user licenses for each unique principal ID
            foreach ($principalId in $principalIds) {
                $licensesList[$principalId] = Get-MgUserLicenseDetail -UserId $principalId -ErrorAction SilentlyContinue
            }

            $adminRoleUsers = @()

            foreach ($role in $adminRoles) {
                foreach ($assignment in $roleAssignments | Where-Object { $_.RoleDefinitionId -eq $role.Id }) {
                    $userDetails = $userDetailsList[$assignment.PrincipalId]
                    if ($userDetails) {
                        $licenses = $licensesList[$assignment.PrincipalId]
                        $licenseString = if ($licenses) { ($licenses.SkuPartNumber -join '|') } else { "No Licenses Found" }

                        $adminRoleUsers += [PSCustomObject]@{
                            UserName   = $userDetails.UserPrincipalName
                            RoleName   = $role.DisplayName
                            UserId     = $userDetails.Id
                            HybridUser = $userDetails.OnPremisesSyncEnabled
                            Licenses   = $licenseString
                        }
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
                "$($_.UserName)|$($_.Roles)|$accountType|$($missingLicenses -join ',')"
            }
            $failureReasons = $failureReasons -join "`n"

            $details = if ($nonCompliantUsers) {
                "Non-compliant accounts: `nUsername | Roles | HybridStatus | Missing Licence`n$failureReasons"
            } else {
                "Compliant Accounts: $($uniqueAdminRoleUsers.Count)"
            }

            $failureReason = if ($nonCompliantUsers) {
                "Non-Compliant Accounts: $($nonCompliantUsers.Count)`nDetails:`n" + ($nonCompliantUsers | ForEach-Object { $_.UserName }) -join "`n"
            } else {
                "N/A"
            }

            $result = $nonCompliantUsers.Count -eq 0
            $status = if ($result) { 'Pass' } else { 'Fail' }

            $params = @{
                Rec           = $recnum
                Result        = $result
                Status        = $status
                Details       = $details
                FailureReason = $failureReason
            }

            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            Write-Error "An error occurred during the test: $_"

            $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
            $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }

            $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })

            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }
    end {
        return $auditResult
    }
}
