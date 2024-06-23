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

        $recnum = "2.1.6"

        <#
        Conditions for 2.1.6 (L1) Ensure Exchange Online Spam Policies are set to notify administrators

        Validate recommendation details:
        - Confirm that the recommendation details are accurate and complete as per the CIS benchmark.

        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
          - Condition A: In the Microsoft 365 Security & Compliance Center, the Exchange Online Spam Policies are set to notify administrators when a sender in the organization has been blocked for sending spam emails.
          - Condition B: Using PowerShell, the `NotifyOutboundSpam` and `NotifyOutboundSpamContact` properties are correctly set in all relevant spam filter policies.

        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
          - Condition A: In the Microsoft 365 Security & Compliance Center, the Exchange Online Spam Policies are not set to notify administrators when a sender in the organization has been blocked for sending spam emails.
          - Condition B: Using PowerShell, the `NotifyOutboundSpam` and `NotifyOutboundSpamContact` properties are not correctly set in all relevant spam filter policies.
        #>
    }

    process {
        try {
            # 2.1.6 Ensure Exchange Online Spam Policies are set to notify administrators

            # Retrieve the default hosted outbound spam filter policy
            $hostedOutboundSpamFilterPolicy = Get-CISExoOutput -Rec $recnum

            # Check if both settings are enabled (Condition A and Condition B for pass)
            $bccSuspiciousOutboundMailEnabled = $hostedOutboundSpamFilterPolicy.BccSuspiciousOutboundMail
            $notifyOutboundSpamEnabled = $hostedOutboundSpamFilterPolicy.NotifyOutboundSpam
            $areSettingsEnabled = $bccSuspiciousOutboundMailEnabled -and $notifyOutboundSpamEnabled

            # Prepare failure details if any setting is not enabled (Condition A and Condition B for fail)
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

