function Test-SpamPolicyAdminNotify {
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
        $recnum = "2.1.6"
    }

    process {
        try {
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
                Rec           = $recnum
                Result        = $areSettingsEnabled
                Status        = if ($areSettingsEnabled) { "Pass" } else { "Fail" }
                Details       = if ($areSettingsEnabled) { "Both BccSuspiciousOutboundMail and NotifyOutboundSpam are enabled." } else { $failureDetails -join ' ' }
                FailureReason = if (-not $areSettingsEnabled) { "One or both spam policies are not set to notify administrators." } else { "N/A" }
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
        # Return auditResult
        return $auditResult
    }
}
