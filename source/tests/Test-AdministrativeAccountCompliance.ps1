function Test-AdministrativeAccountCompliance {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        #. .\source\Classes\CISAuditResult.ps1
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

                        # Collect user information
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

            # Group admin role users by UserName and collect unique roles and licenses
            $uniqueAdminRoleUsers = $adminRoleUsers | Group-Object -Property UserName | ForEach-Object {
                $first = $_.Group | Select-Object -First 1
                $roles = ($_.Group.RoleName -join ', ')
                $licenses = (($_.Group | Select-Object -ExpandProperty Licenses) -join ',').Split(',') | Select-Object -Unique

                $first | Select-Object UserName, UserId, HybridUser, @{Name = 'Roles'; Expression = { $roles } }, @{Name = 'Licenses'; Expression = { $licenses -join '|' } }
            }

            # Identify non-compliant users
            $nonCompliantUsers = $uniqueAdminRoleUsers | Where-Object {
                # Condition A: The administrative account is not cloud-only (it is synced).
                $_.HybridUser -or
                # Condition B: The account is assigned a license associated with applications.
                -not ($_.Licenses -split '\|' | Where-Object { $validLicenses -contains $_ })
            }

            # Generate failure reasons
            $failureReasons = $nonCompliantUsers | ForEach-Object {
                $accountType = if ($_.HybridUser) { "Hybrid" } else { "Cloud-Only" }
                $missingLicenses = $validLicenses | Where-Object { $_ -notin ($_.Licenses -split '\|') }
                "$($_.UserName)|$($_.Roles)|$accountType|Missing: $($missingLicenses -join ',')"
            }
            $failureReasons = $failureReasons -join "`n"
            $details = if ($nonCompliantUsers) {
                "Non-Compliant Accounts: $($nonCompliantUsers.Count)`nDetails:`n" + ($nonCompliantUsers | ForEach-Object { $_.UserName }) -join "`n"
            } else {
                "Compliant Accounts: $($uniqueAdminRoleUsers.Count)"
            }

            $result = $nonCompliantUsers.Count -eq 0
            $status = if ($result) { 'Pass' } else { 'Fail' }
            $failureReason = if ($nonCompliantUsers) { "Non-compliant accounts: `nUsername | Roles | HybridStatus | Missing Licence`n$failureReasons" } else { "N/A" }

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
