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
    }

    process {
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
            Rec            = "6.2.1"
            Result         = $forwardingBlocked
            Status         = if ($forwardingBlocked) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure all forms of mail forwarding are blocked and/or disabled"
            CISControl     = "0.0"
            CISDescription = "Explicitly Not Mapped"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
