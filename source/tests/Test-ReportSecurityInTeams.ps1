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
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($securityReportEnabled) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "8.6.1"
        $auditResult.RecDescription = "Ensure users can report security concerns in Teams"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.Result = $securityReportEnabled
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
