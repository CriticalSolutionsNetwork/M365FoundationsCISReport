function Test-NoWhitelistDomains_6.2.2_E3L1 {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {
        # Initialization code
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 6.2.2 (L1) Ensure mail transport rules do not whitelist specific domains
        $whitelistedRules = Get-TransportRule | Where-Object { $_.SetSCL -eq -1 -and $_.SenderDomainIs -ne $null }

        $auditResult.CISControl = "0.0"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISDescription = "Explicitly Not Mapped"

        $auditResult.Rec = "6.2.2"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L1"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.RecDescription = "Ensure mail transport rules do not whitelist specific domains"

        if ($whitelistedRules) {
            $ruleDetails = $whitelistedRules | ForEach-Object { "{0}: {1}" -f $_.Name, ($_.SenderDomainIs -join ', ') }
            $auditResult.Result = $false
            $auditResult.Details = "Whitelisted Rules: $($ruleDetails -join '; ')"
            $auditResult.FailureReason = "There are transport rules whitelisting specific domains."
            $auditResult.Status = "Fail"
        } else {
            $auditResult.Result = $true
            $auditResult.Details = "No transport rules whitelisting specific domains found."
            $auditResult.FailureReason = "N/A"
            $auditResult.Status = "Pass"
        }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
