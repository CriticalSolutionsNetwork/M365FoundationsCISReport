function Test-AttachmentFiltering {
    [CmdletBinding()]
    param ()
    begin {
        # Record the recommendation number and log the test start
        $RecNum = "2.1.11" # Recommendation for attachment filtering
        Write-Verbose "Starting Test-AttachmentFiltering with Rec: $RecNum"
    }
    process {
        try {
            # Step 1: Retrieve data needed for compliance check
            Write-Verbose "Retrieving malware policies, rules, and extensions for compliance evaluation..."
            $malwarePolicies, $malwareRules, $L2Extensions = Get-CISExoOutput -Rec $RecNum
            # Initialize compliance tracking
            $compliantPolicyFound = $false
            $failureReasons = @()
            $details = @()
            # Step 2: Check each malware policy for compliance
            Write-Verbose "Evaluating each malware filter policy..."
            foreach ($policy in $malwarePolicies) {
                # Check if the policy enables the file filter
                if (-not $policy.EnableFileFilter) {
                    $failureReasons += "Policy $($policy.Identity) has file filtering disabled."
                    continue
                }
                # Check if the number of extensions exceeds the minimum threshold (120)
                if ($policy.FileTypes.Count -le 120) {
                    $failureReasons += "Policy $($policy.Identity) does not include the minimum number of extensions (120)."
                    continue
                }
                # Check for missing extensions from the L2 benchmark
                $missingExtensions = $L2Extensions | Where-Object { -not $policy.FileTypes.Contains($_) }
                if ($missingExtensions.Count -gt 0) {
                    $failureReasons += "Policy $($policy.Identity) is missing extensions: $($missingExtensions -join ', ')."
                } else {
                    # Policy is compliant if it passes all checks
                    $compliantPolicyFound = $true
                    $details += "Compliant Policy Found: $($policy.Identity)"
                    # Break out of the loop since we only need one compliant policy
                    break
                }
            }
            # Step 3: Determine overall compliance
            $isCompliant = $compliantPolicyFound
            # Step 4: Prepare result details
            if ($isCompliant) {
                $resultDetails = $details -join "`n"
            } else {
                $resultDetails = "Non-Compliant Policies:`n$($failureReasons -join '`n')"
            }
            # Step 5: Create the audit result
            $params = @{
                Rec           = $RecNum
                Result        = $isCompliant
                Status        = if ($isCompliant) { 'Pass' } else { 'Fail' }
                Details       = $resultDetails
                FailureReason = if (-not $isCompliant) { $failureReasons -join "`n" } else { 'None' }
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            # Handle errors and return the error result
            $LastError = $_
            Write-Error "An error occurred during Test-AttachmentFiltering: $($LastError.Exception.Message)"
            $auditResult = Get-TestError -LastError $LastError -RecNum $RecNum
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}
