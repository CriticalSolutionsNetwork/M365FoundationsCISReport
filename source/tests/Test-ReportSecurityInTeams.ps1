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
            $CsTeamsMessagingPolicy = Get-CISMSTeamsOutput -Rec $recnum
            # Condition B: Verify that 'Monitor reported messages in Microsoft Teams' is checked in the Microsoft 365 Defender portal.
            # Condition C: Ensure the 'Send reported messages to' setting in the Microsoft 365 Defender portal is set to 'My reporting mailbox only' with the correct report email addresses.
            $ReportSubmissionPolicy = Get-CISExoOutput -Rec $recnum
            # Check if all the required settings are enabled
            $securityReportEnabled = $CsTeamsMessagingPolicy.AllowSecurityEndUserReporting -and
            $ReportSubmissionPolicy.ReportJunkToCustomizedAddress -and
            $ReportSubmissionPolicy.ReportNotJunkToCustomizedAddress -and
            $ReportSubmissionPolicy.ReportPhishToCustomizedAddress -and
            $null -ne $ReportSubmissionPolicy.ReportJunkAddresses -and
            $null -ne $ReportSubmissionPolicy.ReportNotJunkAddresses -and
            $null -ne $ReportSubmissionPolicy.ReportPhishAddresses -and
            $ReportSubmissionPolicy.ReportChatMessageToCustomizedAddressEnabled -and
            -not $ReportSubmissionPolicy.ReportChatMessageEnabled

            $faildetailstring = @"
The following settings are required for users to report security concerns in Teams:

MS Teams:
AllowSecurityEndUserReporting: True

EXO:
ReportJunkToCustomizedAddress               : True
ReportNotJunkToCustomizedAddress            : True
ReportPhishToCustomizedAddress              : True
ReportJunkAddresses                         : <security@contoso.com>
ReportNotJunkAddresses                      : <security@contoso.com>
ReportPhishAddresses                        : <security@contoso.com>
ReportChatMessageEnabled                    : False
ReportChatMessageToCustomizedAddressEnabled : True
"@
            $detailsString = "Users cannot report security concerns in Teams due to one or more incorrect settings:`n`n" +
            "MSTeams: AllowSecurityEndUserReporting: $($CsTeamsMessagingPolicy.AllowSecurityEndUserReporting); `n" +
            "EXO: ReportJunkToCustomizedAddress: $($ReportSubmissionPolicy.ReportJunkToCustomizedAddress); `n" +
            "EXO: ReportNotJunkToCustomizedAddress: $($ReportSubmissionPolicy.ReportNotJunkToCustomizedAddress); `n" +
            "EXO: ReportPhishToCustomizedAddress: $($ReportSubmissionPolicy.ReportPhishToCustomizedAddress); `n" +
            "EXO: ReportJunkAddresses: $($ReportSubmissionPolicy.ReportJunkAddresses -join ', '); `n" +
            "EXO: ReportNotJunkAddresses: $($ReportSubmissionPolicy.ReportNotJunkAddresses -join ', '); `n" +
            "EXO: ReportPhishAddresses: $($ReportSubmissionPolicy.ReportPhishAddresses -join ', '); `n" +
            "EXO: ReportChatMessageEnabled: $($ReportSubmissionPolicy.ReportChatMessageEnabled); `n" +
            "EXO: ReportChatMessageToCustomizedAddressEnabled: $($ReportSubmissionPolicy.ReportChatMessageToCustomizedAddressEnabled); "
            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $securityReportEnabled) {
                $detailsString
            }
            else {
                "N/A"
            }
            $details = if ($securityReportEnabled) {
                "Users can report security concerns in Teams."
            }
            else {
                $faildetailstring
            }

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
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
