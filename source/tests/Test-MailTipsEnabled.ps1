function Test-MailTipsEnabled {
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
        # 6.5.2 (L2) Ensure MailTips are enabled for end users

        # Retrieve organization configuration for MailTips settings
        $orgConfig = Get-OrganizationConfig | Select-Object MailTipsAllTipsEnabled, MailTipsExternalRecipientsTipsEnabled, MailTipsGroupMetricsEnabled, MailTipsLargeAudienceThreshold
        $allTipsEnabled = $orgConfig.MailTipsAllTipsEnabled -and $orgConfig.MailTipsGroupMetricsEnabled -and $orgConfig.MailTipsLargeAudienceThreshold -eq 25
        $externalRecipientsTipsEnabled = $orgConfig.MailTipsExternalRecipientsTipsEnabled

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not ($allTipsEnabled -and $externalRecipientsTipsEnabled)) {
            "One or more MailTips settings are not configured as required."
        }
        else {
            "N/A"
        }

        $details = if ($allTipsEnabled -and $externalRecipientsTipsEnabled) {
            "MailTipsAllTipsEnabled: $($orgConfig.MailTipsAllTipsEnabled); MailTipsExternalRecipientsTipsEnabled: $($orgConfig.MailTipsExternalRecipientsTipsEnabled); MailTipsGroupMetricsEnabled: $($orgConfig.MailTipsGroupMetricsEnabled); MailTipsLargeAudienceThreshold: $($orgConfig.MailTipsLargeAudienceThreshold)"
        }
        else {
            "One or more MailTips settings are not configured as required."
        }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "6.5.2"
            Result         = $allTipsEnabled -and $externalRecipientsTipsEnabled
            Status         = if ($allTipsEnabled -and $externalRecipientsTipsEnabled) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure MailTips are enabled for end users"
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
