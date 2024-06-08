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
        $recnum = "6.5.2"
    }

    process {
        try {
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
                Rec           = $recnum
                Result        = $allTipsEnabled -and $externalRecipientsTipsEnabled
                Status        = if ($allTipsEnabled -and $externalRecipientsTipsEnabled) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            Write-Error "An error occurred during the test: $_"

            # Retrieve the description from the test definitions
            $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
            $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }

            $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
