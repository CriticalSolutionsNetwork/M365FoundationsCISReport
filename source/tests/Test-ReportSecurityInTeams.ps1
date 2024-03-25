function Test-ReportSecurityInTeams {
    [CmdletBinding()]
    param (
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 8.6.1 (L1) Ensure users can report security concerns in Teams

        # Connect to Teams PowerShell using Connect-MicrosoftTeams
        # Connect to Exchange Online PowerShell using Connect-ExchangeOnline

        $CsTeamsMessagingPolicy = Get-CsTeamsMessagingPolicy -Identity Global | Select-Object -Property AllowSecurityEndUserReporting
        $ReportSubmissionPolicy = Get-ReportSubmissionPolicy | Select-Object -Property ReportJunkToCustomizedAddress, ReportNotJunkToCustomizedAddress, ReportPhishToCustomizedAddress, ReportChatMessageToCustomizedAddressEnabled

        $securityReportEnabled = $CsTeamsMessagingPolicy.AllowSecurityEndUserReporting -and
        $ReportSubmissionPolicy.ReportJunkToCustomizedAddress -and
        $ReportSubmissionPolicy.ReportNotJunkToCustomizedAddress -and
        $ReportSubmissionPolicy.ReportPhishToCustomizedAddress -and
        $ReportSubmissionPolicy.ReportChatMessageToCustomizedAddressEnabled

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.6.1"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure users can report security concerns in Teams"
        $auditResult.Result = $securityReportEnabled
        $auditResult.Details = "AllowSecurityEndUserReporting: $($CsTeamsMessagingPolicy.AllowSecurityEndUserReporting); " +
        "ReportJunkToCustomizedAddress: $($ReportSubmissionPolicy.ReportJunkToCustomizedAddress); " +
        "ReportNotJunkToCustomizedAddress: $($ReportSubmissionPolicy.ReportNotJunkToCustomizedAddress); " +
        "ReportPhishToCustomizedAddress: $($ReportSubmissionPolicy.ReportPhishToCustomizedAddress); " +
        "ReportChatMessageToCustomizedAddressEnabled: $($ReportSubmissionPolicy.ReportChatMessageToCustomizedAddressEnabled)"
        $auditResult.FailureReason = if (-not $securityReportEnabled) { "Users cannot report security concerns in Teams due to one or more incorrect settings" } else { "N/A" }
        $auditResult.Status = if ($securityReportEnabled) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
