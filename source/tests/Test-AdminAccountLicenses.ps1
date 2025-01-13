function Test-AdminAccountLicenses {
    [CmdletBinding()]
    param ()
    begin {
        # The following conditions are checked:
        # Condition A: The administrative account is cloud-only (not synced).
        # Condition B: The account is assigned a valid license (e.g., Microsoft Entra ID P1 or P2).
        # Condition C: The administrative account does not have any other application assignments (only valid licenses).
        $validLicenses = @('AAD_PREMIUM', 'AAD_PREMIUM_P2')
        $RecNum = "1.1.4"
        Write-Verbose "Starting Test-AdministrativeAccountCompliance with Rec: $RecNum"
    }
    process {
        try {
            # Retrieve admin roles, assignments, and user details including licenses
            Write-Verbose "Retrieving admin roles, assignments, and user details including licenses"
            $Report = Get-CISMgOutput -Rec $RecNum
            $NonCompliantUsers = $Report | Where-Object {$_.License -notin $validLicenses}
            # Generate failure reasons
            Write-Verbose "Generating failure reasons for non-compliant users"
            $failureReasons = $nonCompliantUsers | ForEach-Object {
                "$($_.DisplayName)|$($_.UserPrincipalName)|$(if ($_.License) {$_.License}else{"No licenses found"})"
            }
            $failureReasons = $failureReasons -join "`n"
            $failureReason = if ($nonCompliantUsers) {
                "Non-Compliant Accounts without only a singular P1 or P2 license and no others: $($nonCompliantUsers.Count)"
            }
            else {
                "Compliant Accounts: $($uniqueAdminRoleUsers.Count)"
            }
            $result = $nonCompliantUsers.Count -eq 0
            $status = if ($result) { 'Pass' } else { 'Fail' }
            $details = if ($nonCompliantUsers) { "DisplayName | UserPrincipalName | License`n$failureReasons" } else { "N/A" }
            Write-Verbose "Assessment completed. Result: $status"
            # Create the parameter splat
            $params = @{
                Rec           = $RecNum
                Result        = $result
                Status        = $status
                Details       = $details
                FailureReason = $failureReason
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -RecNum $RecNum
        }
    }
    end {
        # Output the result
        return $auditResult
    }
}
 #   $validLicenses = @('AAD_PREMIUM', 'AAD_PREMIUM_P2')