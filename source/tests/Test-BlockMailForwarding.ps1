function Test-BlockMailForwarding {
    [CmdletBinding()]
    param (
        # Aligned Compare
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

            # Retrieve the transport rules that redirect messages
            $transportRules = Get-TransportRule | Where-Object { $null -ne $_.RedirectMessageTo }
            $forwardingBlocked = $transportRules.Count -eq 0

            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($transportRules.Count -gt 0) {
                "Mail forwarding rules found: $($transportRules.Name -join ', ')"
            }
            else {
                "N/A"
            }

            $details = if ($transportRules.Count -gt 0) {
                $transportRules | ForEach-Object {
                    "$($_.Name) redirects to $($_.RedirectMessageTo)"
                } -join " | "
            }
            else {
                "Step 1: No forwarding rules found. Please proceed with Step 2 described in CIS Benchmark."
            }

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

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
