function Test-NoAnonymousMeetingJoin {
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
        # 8.5.1 (L2) Ensure anonymous users can't join a meeting

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $teamsMeetingPolicy = Get-CsTeamsMeetingPolicy -Identity Global
        $allowAnonymousUsersToJoinMeeting = $teamsMeetingPolicy.AllowAnonymousUsersToJoinMeeting

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($allowAnonymousUsersToJoinMeeting) {
            "Anonymous users are allowed to join meetings"
        }
        else {
            "N/A"
        }

        $details = "AllowAnonymousUsersToJoinMeeting is set to $allowAnonymousUsersToJoinMeeting"

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "8.5.1"
            Result         = -not $allowAnonymousUsersToJoinMeeting
            Status         = if (-not $allowAnonymousUsersToJoinMeeting) { "Pass" } else { "Fail" }
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
