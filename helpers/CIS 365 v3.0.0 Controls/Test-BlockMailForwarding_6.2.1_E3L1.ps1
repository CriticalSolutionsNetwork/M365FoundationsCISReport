function Test-BlockMailForwarding_6.2.1_E3L1 {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResult = [CISAuditResult]::new()
        $auditResult.Rec = "6.2.1"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L1"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.RecDescription = "Ensure all forms of mail forwarding are blocked and/or disabled"
    }

    process {
        # Verify that no rules are forwarding the email to external domains
        $transportRules = Get-TransportRule | Where-Object { $_.RedirectMessageTo -ne $null }
        $forwardingBlocked = $transportRules.Count -eq 0

        $auditResult.Result = $forwardingBlocked
        $auditResult.Details = if ($transportRules.Count -gt 0) {
            $transportRules | ForEach-Object {
                "$($_.Name) redirects to $($_.RedirectMessageTo)"
            } -join " | "
        } else {
            "Step 1: No forwarding rules found. Please proceed with Step 2 described in CIS Benchmark."
        }
        $auditResult.FailureReason = if (-not $forwardingBlocked) {
            "Mail forwarding rules found: $($transportRules.Name -join ', ')"
        } else {
            "N/A"
        }
        $auditResult.Status = if ($forwardingBlocked) { "Pass" } else { "Fail" }
    }

    end {
        # Return the result object
        return $auditResult
    }
}




