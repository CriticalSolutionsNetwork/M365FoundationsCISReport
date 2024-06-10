function Test-AdministrativeAccountCompliance {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # The following conditions are checked:
        # Condition A: The administrative account is cloud-only (not synced).
        # Condition B: The account is assigned only valid licenses (e.g., Microsoft Entra ID P1 or P2).
        # Condition C: The administrative account does not have application assignments (only valid licenses are allowed).

        $validLicenses = @('AAD_PREMIUM', 'AAD_PREMIUM_P2')
        $recnum = "1.1.1"
    }

    process {
        try {
            # Retrieve all admin roles
            $adminRoles = Get-MgRoleManagementDirectoryRoleDefinition | Where-Object { $_.DisplayName -like "*Admin*" }
            $adminRoleUsers = @()

            # Loop through each admin role to get role assignments and user details
            foreach ($role in $adminRoles) {
                $roleAssignments = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"

                foreach ($assignment in $roleAssignments) {
                    # Get user details for each principal ID
                    $userDetails = Get-MgUser -UserId $assignment.PrincipalId -Property "DisplayName, UserPrincipalName, Id, OnPremisesSyncEnabled" -ErrorAction SilentlyContinue
                    if ($userDetails) {
                        # Get user license details
                        $licenses = Get-MgUserLicenseDetail -UserId $assignment.PrincipalId -ErrorAction SilentlyContinue
                        $licenseString = if ($licenses) { ($licenses.SkuPartNumber -join '|') } else { "No Licenses Found" }

                        # Condition A: Check if the account is cloud-only
                        $cloudOnlyStatus = if ($userDetails.OnPremisesSyncEnabled) { "Fail" } else { "Pass" }

                        # Condition B and C: Check if the account has only valid licenses
                        $hasOnlyValidLicenses = ($licenses.SkuPartNumber | ForEach-Object { $validLicenses -contains $_ }) -and (($licenses.SkuPartNumber | ForEach-Object { $validLicenses -notcontains $_ }).Count -eq 0)
                        $validLicensesStatus = if ($hasOnlyValidLicenses) { "Pass" } else { "Fail" }

                        # Collect user information
                        $adminRoleUsers += [PSCustomObject]@{
                            UserName                    = $userDetails.UserPrincipalName
                            RoleName                    = $role.DisplayName
                            UserId                      = $userDetails.Id
                            HybridUser                  = $userDetails.OnPremisesSyncEnabled
                            Licenses                    = $licenseString
                            CloudOnlyStatus             = $cloudOnlyStatus
                            ValidLicensesStatus         = $validLicensesStatus
                            ApplicationAssignmentStatus = $validLicensesStatus # Using the same status as ValidLicensesStatus for now
                        }
                    }
                }
            }

            # Group admin role users by UserName and collect unique roles and licenses
            $uniqueAdminRoleUsers = $adminRoleUsers | Group-Object -Property UserName | ForEach-Object {
                $first = $_.Group | Select-Object -First 1
                $roles = ($_.Group.RoleName -join ', ')
                $licenses = (($_.Group | Select-Object -ExpandProperty Licenses) -join ',').Split(',') | Select-Object -Unique

                $first | Select-Object UserName, UserId, HybridUser, @{Name = 'Roles'; Expression = { $roles } }, @{Name = 'Licenses'; Expression = { $licenses -join '|' } }, CloudOnlyStatus, ValidLicensesStatus, ApplicationAssignmentStatus
            }

            # Identify non-compliant users based on conditions A and B
            $nonCompliantUsers = $uniqueAdminRoleUsers | Where-Object {
                $_.HybridUser -or # Fails Condition A
                $_.ValidLicensesStatus -eq "Fail" # Fails Condition B
            }

            # Generate failure reasons
            $failureReasons = $nonCompliantUsers | ForEach-Object {
                "$($_.UserName)|$($_.Roles)|$($_.CloudOnlyStatus)|$($_.ValidLicensesStatus)|$($_.ApplicationAssignmentStatus)"
            }
            $failureReasons = $failureReasons -join "`n"
            $details = if ($nonCompliantUsers) {
                "Non-Compliant Accounts: $($nonCompliantUsers.Count)`nDetails:`n" + $failureReasons
            } else {
                "Compliant Accounts: $($uniqueAdminRoleUsers.Count)"
            }

            $result = $nonCompliantUsers.Count -eq 0
            $status = if ($result) { 'Pass' } else { 'Fail' }
            $failureReason = if ($nonCompliantUsers) { "Non-compliant accounts: `nUsername | Roles | Cloud-Only Status | Valid Licenses Status | Application Assignment Status`n$failureReasons" } else { "N/A" }

            # Create the parameter splat
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

            # Handle the error and create a failure result
            $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
            $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }

            $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })

            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Output the result
        return $auditResult
    }
}
