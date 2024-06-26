function Test-BlockMailForwarding {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Parameters can be added if needed
    )
    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "6.2.1"
        Write-Verbose "Running Test-BlockMailForwarding for $recnum..."
        <#
        Conditions for 6.2.1 (L1) Ensure all forms of mail forwarding are blocked and/or disabled
        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
          - Condition A: Transport rules do not forward email to external domains.
          - Condition B: Anti-spam outbound policy is configured to disable automatic email forwarding to external domains.
          - Condition C: No exceptions to the forwarding rules unless explicitly defined by organizational policy.
        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
          - Condition A: One or more transport rules forward email to external domains.
          - Condition B: Anti-spam outbound policy does not disable automatic email forwarding to external domains.
          - Condition C: Unapproved exceptions to the forwarding rules are present.
        #>
    }
    process {
        try {
            # 6.2.1 (L1) Ensure all forms of mail forwarding are blocked and/or disabled
            # Step 1: Retrieve the transport rules that redirect messages
            $transportRules,$nonCompliantSpamPolicies = Get-CISExoOutput -Rec $recnum
            $transportForwardingBlocked = $transportRules.Count -eq 0
            # Step 2: Check all anti-spam outbound policies
            $nonCompliantSpamPoliciesArray = @($nonCompliantSpamPolicies)
            $spamForwardingBlocked = $nonCompliantSpamPoliciesArray.Count -eq 0
            # Determine overall compliance
            $forwardingBlocked = $transportForwardingBlocked -and $spamForwardingBlocked
            # Prepare failure reasons and details based on compliance
            $failureReasons = @()
            $details = @()
            if ($transportRules -ne 1) {
                # Fail Condition A
                $failureReasons += "Mail forwarding rules found: $($transportRules.Name -join ', ')"
                $details += "Transport Rules Details:`nRule Name|Redirects To"
                $details += $transportRules | ForEach-Object {
                    "$($_.Name)|$($_.RedirectMessageTo -join ', ')"
                }
                $details += "`n"
            }
            if ($nonCompliantSpamPoliciesArray.Count -gt 0) {
                # Fail Condition B
                $failureReasons += "Outbound spam policies allowing automatic forwarding found."
                $details += "Policy|AutoForwardingMode"
                $details += $nonCompliantSpamPoliciesArray | ForEach-Object {
                    "$($_.Name)|$($_.AutoForwardingMode)"
                }
            }
            if ($failureReasons.Count -eq 0) {
                $failureReasons = "N/A"
                $details = "Both transport rules and outbound spam policies are configured correctly to block forwarding."
            }
            else {
                $failureReasons = $failureReasons -join " | "
                $details = $details -join "`n"
            }
            # Populate the audit result
            $params = @{
                Rec           = $recnum
                Result        = $forwardingBlocked
                Status        = if ($forwardingBlocked) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}