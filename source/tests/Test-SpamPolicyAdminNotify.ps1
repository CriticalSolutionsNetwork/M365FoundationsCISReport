function Test-SpamPolicyAdminNotify {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {

        $auditResults = @()
    }

    process {
        # 2.1.6	Ensure Exchange Online Spam Policies are set to notify administrators

        # Get the default hosted outbound spam filter policy
        $hostedOutboundSpamFilterPolicy = Get-HostedOutboundSpamFilterPolicy | Where-Object { $_.IsDefault -eq $true }

        # Check if both settings are enabled
        $bccSuspiciousOutboundMailEnabled = $hostedOutboundSpamFilterPolicy.BccSuspiciousOutboundMail
        $notifyOutboundSpamEnabled = $hostedOutboundSpamFilterPolicy.NotifyOutboundSpam
        $areSettingsEnabled = $bccSuspiciousOutboundMailEnabled -and $notifyOutboundSpamEnabled

        # Prepare failure details if any setting is not enabled
        $failureDetails = @()
        if (-not $bccSuspiciousOutboundMailEnabled) {
            $failureDetails += "BccSuspiciousOutboundMail is not enabled."
        }
        if (-not $notifyOutboundSpamEnabled) {
            $failureDetails += "NotifyOutboundSpam is not enabled."
        }

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($areSettingsEnabled) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "2.1.6"
        $auditResult.RecDescription = "Ensure Exchange Online Spam Policies are set to notify administrators"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "17.5"
        $auditResult.CISDescription = "Assign Key Roles and Responsibilities"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $areSettingsEnabled
        $auditResult.Details = if ($areSettingsEnabled) { "Both BccSuspiciousOutboundMail and NotifyOutboundSpam are enabled." } else { $failureDetails -join ' ' }
        $auditResult.FailureReason = if (-not $areSettingsEnabled) { "One or both spam policies are not set to notify administrators." } else { "N/A" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}


