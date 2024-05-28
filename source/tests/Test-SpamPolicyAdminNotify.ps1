function Test-SpamPolicyAdminNotify {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed

        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 2.1.6 Ensure Exchange Online Spam Policies are set to notify administrators

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
        $params = @{
            Rec            = "2.1.6"
            Result         = $areSettingsEnabled
            Status         = if ($areSettingsEnabled) { "Pass" } else { "Fail" }
            Details        = if ($areSettingsEnabled) { "Both BccSuspiciousOutboundMail and NotifyOutboundSpam are enabled." } else { $failureDetails -join ' ' }
            FailureReason  = if (-not $areSettingsEnabled) { "One or both spam policies are not set to notify administrators." } else { "N/A" }
            RecDescription = "Ensure Exchange Online Spam Policies are set to notify administrators"
            CISControl     = "17.5"
            CISDescription = "Assign Key Roles and Responsibilities"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
