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
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"  # Explicitly Not Mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "6.5.2"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L2"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.RecDescription = "Ensure MailTips are enabled for end users"
        $auditResult.Result = $allTipsEnabled -and $externalRecipientsTipsEnabled
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if ($auditResult.Result) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
