function Test-MailTipsEnabled {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {
        # Initialization code

        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 6.5.2 (L2) Ensure MailTips are enabled for end users
        $orgConfig = Get-OrganizationConfig | Select-Object MailTipsAllTipsEnabled, MailTipsExternalRecipientsTipsEnabled, MailTipsGroupMetricsEnabled, MailTipsLargeAudienceThreshold
        $allTipsEnabled = $orgConfig.MailTipsAllTipsEnabled -and $orgConfig.MailTipsGroupMetricsEnabled -and $orgConfig.MailTipsLargeAudienceThreshold -eq 25
        $externalRecipientsTipsEnabled = $orgConfig.MailTipsExternalRecipientsTipsEnabled

        # Since there is no direct CIS Control mapping, the control will be set as not applicable.
        $auditResult.CISControl = "0"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISDescription = "Explicitly Not Mapped"

        $auditResult.Rec = "6.5.2"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L2"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.RecDescription = "Ensure MailTips are enabled for end users"

        $auditResult.Result = $allTipsEnabled -and $externalRecipientsTipsEnabled
        $auditResult.Details = "MailTipsAllTipsEnabled: $($orgConfig.MailTipsAllTipsEnabled); MailTipsExternalRecipientsTipsEnabled: $($orgConfig.MailTipsExternalRecipientsTipsEnabled); MailTipsGroupMetricsEnabled: $($orgConfig.MailTipsGroupMetricsEnabled); MailTipsLargeAudienceThreshold: $($orgConfig.MailTipsLargeAudienceThreshold)"
        $auditResult.FailureReason = if (-not $auditResult.Result) { "One or more MailTips settings are not configured as required." } else { "N/A" }
        $auditResult.Status = if ($auditResult.Result) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}

