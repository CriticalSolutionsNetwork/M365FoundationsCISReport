function Test-NoAnonymousMeetingStart {
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
        # 8.5.2 (L1) Ensure anonymous users and dial-in callers can't start a meeting

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $CsTeamsMeetingPolicyAnonymous = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AllowAnonymousUsersToStartMeeting
        $anonymousStartDisabled = -not $CsTeamsMeetingPolicyAnonymous.AllowAnonymousUsersToStartMeeting

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($anonymousStartDisabled) {
            "N/A"
        }
        else {
            "Anonymous users and dial-in callers can start a meeting"
        }

        $details = "AllowAnonymousUsersToStartMeeting is set to $($CsTeamsMeetingPolicyAnonymous.AllowAnonymousUsersToStartMeeting)"

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "8.5.2"
            Result         = $anonymousStartDisabled
            Status         = if ($anonymousStartDisabled) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
