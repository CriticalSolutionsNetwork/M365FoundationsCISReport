function Test-MailTipsEnabled {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed

        $auditResult = [CISAuditResult]::new()
        $recnum = "6.5.2"

        # Conditions for 6.5.2 (L2) Ensure MailTips are enabled for end users
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: MailTipsAllTipsEnabled is set to True.
        #   - Condition B: MailTipsExternalRecipientsTipsEnabled is set to True.
        #   - Condition C: MailTipsGroupMetricsEnabled is set to True.
        #   - Condition D: MailTipsLargeAudienceThreshold is set to an acceptable value (default is 25).
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: MailTipsAllTipsEnabled is not set to True.
        #   - Condition B: MailTipsExternalRecipientsTipsEnabled is not set to True.
        #   - Condition C: MailTipsGroupMetricsEnabled is not set to True.
        #   - Condition D: MailTipsLargeAudienceThreshold is not set to an acceptable value (default is 25).
    }

    process {
        try {
            # 6.5.2 (L2) Ensure MailTips are enabled for end users

            # Retrieve organization configuration for MailTips settings
            $orgConfig = Get-CISExoOutput -Rec $recnum

            # Check the MailTips settings (Conditions A, B, C, D)
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
                Rec           = $recnum
                Result        = $allTipsEnabled -and $externalRecipientsTipsEnabled
                Status        = if ($allTipsEnabled -and $externalRecipientsTipsEnabled) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
