function Test-AdministrativeAccountCompliance {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # The following conditions are checked:
        # Condition A: The administrative account is cloud-only (not synced).
        # Condition B: The account is assigned a valid license (e.g., Microsoft Entra ID P1 or P2).
        # Condition C: The administrative account does not have any other application assignments (only valid licenses).

        $validLicenses = @('AAD_PREMIUM', 'AAD_PREMIUM_P2')
        $recnum = "1.1.1"
        Write-Verbose "Starting Test-AdministrativeAccountCompliance with Rec: $recnum"
    }

    process {
        try {
            # Retrieve all admin roles
            Write-Verbose "Retrieving all admin roles"
            $adminRoles = Get-MgRoleManagementDirectoryRoleDefinition | Where-Object { $_.DisplayName -like "*Admin*" }
            $adminRoleUsers = @()

            # Loop through each admin role to get role assignments and user details
            foreach ($role in $adminRoles) {
                Write-Verbose "Processing role: $($role.DisplayName)"
                $roleAssignments = Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$($role.Id)'"

                foreach ($assignment in $roleAssignments) {
                    Write-Verbose "Processing role assignment for principal ID: $($assignment.PrincipalId)"
                    # Get user details for each principal ID
                    $userDetails = Get-MgUser -UserId $assignment.PrincipalId -Property "DisplayName, UserPrincipalName, Id, OnPremisesSyncEnabled" -ErrorAction SilentlyContinue
                    if ($userDetails) {
                        Write-Verbose "Retrieved user details for: $($userDetails.UserPrincipalName)"
                        # Get user license details
                        $licenses = Get-MgUserLicenseDetail -UserId $assignment.PrincipalId -ErrorAction SilentlyContinue
                        $licenseString = if ($licenses) { ($licenses.SkuPartNumber -join '|') } else { "No Licenses Found" }

                        # Condition A: Check if the account is cloud-only
                        $cloudOnlyStatus = if ($userDetails.OnPremisesSyncEnabled) { "Fail" } else { "Pass" }

                        # Condition B: Check if the account has valid licenses
                        $hasValidLicense = $licenses.SkuPartNumber | ForEach-Object { $validLicenses -contains $_ }
                        $validLicensesStatus = if ($hasValidLicense) { "Pass" } else { "Fail" }

                        # Condition C: Check if the account has no other licenses
                        $hasInvalidLicense = $licenses.SkuPartNumber | ForEach-Object { $validLicenses -notcontains $_ }
                        $applicationAssignmentStatus = if ($hasInvalidLicense) { "Fail" } else { "Pass" }

                        Write-Verbose "User: $($userDetails.UserPrincipalName), Cloud-Only: $cloudOnlyStatus, Valid Licenses: $validLicensesStatus, Other Applications Assigned: $applicationAssignmentStatus"

                        # Collect user information
                        $adminRoleUsers += [PSCustomObject]@{
                            UserName                    = $userDetails.UserPrincipalName
                            RoleName                    = $role.DisplayName
                            UserId                      = $userDetails.Id
                            HybridUser                  = $userDetails.OnPremisesSyncEnabled
                            Licenses                    = $licenseString
                            CloudOnlyStatus             = $cloudOnlyStatus
                            ValidLicensesStatus         = $validLicensesStatus
                            ApplicationAssignmentStatus = $applicationAssignmentStatus
                        }
                    }
                    else {
                        Write-Verbose "No user details found for principal ID: $($assignment.PrincipalId)"
                    }
                }
            }

            # Group admin role users by UserName and collect unique roles and licenses
            Write-Verbose "Grouping admin role users by UserName"
            $uniqueAdminRoleUsers = $adminRoleUsers | Group-Object -Property UserName | ForEach-Object {
                $first = $_.Group | Select-Object -First 1
                $roles = ($_.Group.RoleName -join ', ')
                $licenses = (($_.Group | Select-Object -ExpandProperty Licenses) -join ',').Split(',') | Select-Object -Unique

                $first | Select-Object UserName, UserId, HybridUser, @{Name = 'Roles'; Expression = { $roles } }, @{Name = 'Licenses'; Expression = { $licenses -join '|' } }, CloudOnlyStatus, ValidLicensesStatus, ApplicationAssignmentStatus
            }

            # Identify non-compliant users based on conditions A, B, and C
            Write-Verbose "Identifying non-compliant users based on conditions"
            $nonCompliantUsers = $uniqueAdminRoleUsers | Where-Object {
                $_.HybridUser -or # Fails Condition A
                $_.ValidLicensesStatus -eq "Fail" -or # Fails Condition B
                $_.ApplicationAssignmentStatus -eq "Fail" # Fails Condition C
            }

            # Generate failure reasons
            Write-Verbose "Generating failure reasons for non-compliant users"
            $failureReasons = $nonCompliantUsers | ForEach-Object {
                "$($_.UserName)|$($_.Roles)|$($_.CloudOnlyStatus)|$($_.ValidLicensesStatus)|$($_.ApplicationAssignmentStatus)"
            }
            $failureReasons = $failureReasons -join "`n"
            $failureReason = if ($nonCompliantUsers) {
                "Non-Compliant Accounts: $($nonCompliantUsers.Count)"
            } else {
                "Compliant Accounts: $($uniqueAdminRoleUsers.Count)"
            }

            $result = $nonCompliantUsers.Count -eq 0
            $status = if ($result) { 'Pass' } else { 'Fail' }
            $details = if ($nonCompliantUsers) { "Username | Roles | Cloud-Only Status | Entra ID License Status | Other Applications Assigned Status`n$failureReasons" } else { "N/A" }

            Write-Verbose "Assessment completed. Result: $status"

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
