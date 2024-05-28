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

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Rec = "6.2.1"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"  # Explicitly Not Mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.RecDescription = "Ensure all forms of mail forwarding are blocked and/or disabled"
        $auditResult.Result = $forwardingBlocked
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if ($forwardingBlocked) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
