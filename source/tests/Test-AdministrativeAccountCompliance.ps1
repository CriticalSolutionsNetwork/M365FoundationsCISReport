function Test-AdministrativeAccountCompliance {
    [CmdletBinding()]
    param ()
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
            # Retrieve admin roles, assignments, and user details including licenses
            Write-Verbose "Retrieving admin roles, assignments, and user details including licenses"
            $adminRoleAssignments = Get-CISMgOutput -Rec $recnum
            $adminRoleUsers = @()
            foreach ($roleName in $adminRoleAssignments.Keys) {
                $assignments = $adminRoleAssignments[$roleName]
                foreach ($assignment in $assignments) {
                    $userDetails = $assignment.UserDetails
                    $userId = $userDetails.Id
                    $userPrincipalName = $userDetails.UserPrincipalName
                    $licenses = $assignment.Licenses
                    $licenseString = if ($licenses) { ($licenses.SkuPartNumber -join '|') } else { "No Licenses Found" }
                    # Condition A: Check if the account is cloud-only
                    $cloudOnlyStatus = if ($userDetails.OnPremisesSyncEnabled) { "Fail" } else { "Pass" }
                    # Condition B: Check if the account has valid licenses
                    $hasValidLicense = $licenses.SkuPartNumber | ForEach-Object { $validLicenses -contains $_ }
                    $validLicensesStatus = if ($hasValidLicense) { "Pass" } else { "Fail" }
                    # Condition C: Check if the account has no other licenses
                    $hasInvalidLicense = $licenses.SkuPartNumber | ForEach-Object { $validLicenses -notcontains $_ }
                    $invalidLicenses = $licenses.SkuPartNumber | Where-Object { $validLicenses -notcontains $_ }
                    $applicationAssignmentStatus = if ($hasInvalidLicense) { "Fail" } else { "Pass" }
                    Write-Verbose "User: $userPrincipalName, Cloud-Only: $cloudOnlyStatus, Valid Licenses: $validLicensesStatus, Invalid Licenses: $($invalidLicenses -join ', ')"
                    # Collect user information
                    $adminRoleUsers += [PSCustomObject]@{
                        UserName                    = $userPrincipalName
                        RoleName                    = $roleName
                        UserId                      = $userId
                        HybridUser                  = $userDetails.OnPremisesSyncEnabled
                        Licenses                    = $licenseString
                        CloudOnlyStatus             = $cloudOnlyStatus
                        ValidLicensesStatus         = $validLicensesStatus
                        ApplicationAssignmentStatus = $applicationAssignmentStatus
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
            }
            else {
                "Compliant Accounts: $($uniqueAdminRoleUsers.Count)"
            }
            $result = $nonCompliantUsers.Count -eq 0
            $status = if ($result) { 'Pass' } else { 'Fail' }
            $details = if ($nonCompliantUsers) { "Username | Roles | Cloud-Only Status | EntraID P1/P2 License Status | Other Applications Assigned Status`n$failureReasons" } else { "N/A" }
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
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }
    end {
        # Output the result
        return $auditResult
    }
}
