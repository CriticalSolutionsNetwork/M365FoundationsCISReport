function Test-ReportSecurityInTeams {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 8.6.1 (L1) Ensure users can report security concerns in Teams

        # Retrieve the necessary settings for Teams and Exchange Online
        $CsTeamsMessagingPolicy = Get-CsTeamsMessagingPolicy -Identity Global | Select-Object -Property AllowSecurityEndUserReporting
        $ReportSubmissionPolicy = Get-ReportSubmissionPolicy | Select-Object -Property ReportJunkToCustomizedAddress, ReportNotJunkToCustomizedAddress, ReportPhishToCustomizedAddress, ReportChatMessageToCustomizedAddressEnabled

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
            Rec            = "8.6.1"
            Result         = $securityReportEnabled
            Status         = if ($securityReportEnabled) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
