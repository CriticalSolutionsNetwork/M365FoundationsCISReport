function Test-NoWhitelistDomains {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 6.2.2 (L1) Ensure mail transport rules do not whitelist specific domains

        # Retrieve transport rules that whitelist specific domains
        $whitelistedRules = Get-TransportRule | Where-Object { $_.SetSCL -eq -1 -and $null -ne $_.SenderDomainIs }

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($whitelistedRules) {
            "There are transport rules whitelisting specific domains."
        }
        else {
            "N/A"
        }

        $details = if ($whitelistedRules) {
            $ruleDetails = $whitelistedRules | ForEach-Object { "{0}: {1}" -f $_.Name, ($_.SenderDomainIs -join ', ') }
            "Whitelisted Rules: $($ruleDetails -join '; ')"
        }
        else {
            "No transport rules whitelisting specific domains found."
        }

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($whitelistedRules) { "Fail" } else { "Pass" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "6.2.2"
        $auditResult.RecDescription = "Ensure mail transport rules do not whitelist specific domains"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.Result = -not $whitelistedRules
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return auditResult
        return $auditResult
    }
}