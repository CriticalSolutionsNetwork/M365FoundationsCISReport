function Test-ReportSecurityInTeams {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "8.6.1"
    }

    process {
        try {
            # Test-ReportSecurityInTeams.ps1
            # 8.6.1 (L1) Ensure users can report security concerns in Teams

            # Retrieve the necessary settings for Teams and Exchange Online
            # Condition A: Ensure the 'Report a security concern' setting in the Teams admin center is set to 'On'.
            $CsTeamsMessagingPolicy = Get-CsTeamsMessagingPolicy -Identity Global | Select-Object -Property AllowSecurityEndUserReporting
            # Condition B: Verify that 'Monitor reported messages in Microsoft Teams' is checked in the Microsoft 365 Defender portal.
            # Condition C: Ensure the 'Send reported messages to' setting in the Microsoft 365 Defender portal is set to 'My reporting mailbox only' with the correct report email addresses.
            $ReportSubmissionPolicy = Get-CISExoOutput -Rec $recnum
            # Check if all the required settings are enabled
            $securityReportEnabled = $CsTeamsMessagingPolicy.AllowSecurityEndUserReporting -and
            $ReportSubmissionPolicy.ReportJunkToCustomizedAddress -and
            $ReportSubmissionPolicy.ReportNotJunkToCustomizedAddress -and
            $ReportSubmissionPolicy.ReportPhishToCustomizedAddress -and
            $ReportSubmissionPolicy.ReportChatMessageToCustomizedAddressEnabled

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $securityReportEnabled) {
                "Users cannot report security concerns in Teams due to one or more incorrect settings"
            }
            else {
                "N/A"
            }

            $details = "AllowSecurityEndUserReporting: $($CsTeamsMessagingPolicy.AllowSecurityEndUserReporting); " +
            "ReportJunkToCustomizedAddress: $($ReportSubmissionPolicy.ReportJunkToCustomizedAddress); " +
            "ReportNotJunkToCustomizedAddress: $($ReportSubmissionPolicy.ReportNotJunkToCustomizedAddress); " +
            "ReportPhishToCustomizedAddress: $($ReportSubmissionPolicy.ReportPhishToCustomizedAddress); " +
            "ReportChatMessageToCustomizedAddressEnabled: $($ReportSubmissionPolicy.ReportChatMessageToCustomizedAddressEnabled)"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $securityReportEnabled
                Status        = if ($securityReportEnabled) { "Pass" } else { "Fail" }
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
