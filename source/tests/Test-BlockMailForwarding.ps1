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
    }

    process {
        try {
            # 6.2.1 (L1) Ensure all forms of mail forwarding are blocked and/or disabled

            # Step 1: Retrieve the transport rules that redirect messages
            $transportRules = Get-TransportRule | Where-Object { $null -ne $_.RedirectMessageTo }
            $transportForwardingBlocked = $transportRules.Count -eq 0

            # Step 2: Check all anti-spam outbound policies
            $outboundSpamPolicies = Get-HostedOutboundSpamFilterPolicy
            $nonCompliantSpamPolicies = $outboundSpamPolicies | Where-Object { $_.AutoForwardingMode -ne 'Off' }
            $nonCompliantSpamPoliciesArray = @($nonCompliantSpamPolicies)
            $spamForwardingBlocked = $nonCompliantSpamPoliciesArray.Count -eq 0

            # Determine overall compliance
            $forwardingBlocked = $transportForwardingBlocked -and $spamForwardingBlocked

            # Prepare failure reasons and details based on compliance
            $failureReasons = @()
            $details = @()

            if ($transportRules.Count -gt 0) {
                $failureReasons += "Mail forwarding rules found: $($transportRules.Name -join ', ')"
                $details += "Transport Rules Details:`nRule Name|Redirects To"
                $details += $transportRules | ForEach-Object {
                    "$($_.Name)|$($_.RedirectMessageTo -join ', ')"
                }
                $details += "`n"
            }

            if ($nonCompliantSpamPoliciesArray.Count -gt 0) {
                $failureReasons += "Outbound spam policies allowing automatic forwarding found."
                $details += "Outbound Spam Policies Details:`nPolicy|AutoForwardingMode"
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
            Write-Error "An error occurred during the test: $_"

            # Retrieve the description from the test definitions
            $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
            $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }

            $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
