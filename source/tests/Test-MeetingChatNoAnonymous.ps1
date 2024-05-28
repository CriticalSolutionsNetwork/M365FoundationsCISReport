function Test-MeetingChatNoAnonymous {
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
        # 8.5.5 (L2) Ensure meeting chat does not allow anonymous users

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        # Retrieve the Teams meeting policy for meeting chat
        $CsTeamsMeetingPolicyChat = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property MeetingChatEnabledType
        $chatAnonDisabled = $CsTeamsMeetingPolicyChat.MeetingChatEnabledType -eq 'EnabledExceptAnonymous'

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($chatAnonDisabled) {
            "N/A"
        }
        else {
            "Meeting chat allows anonymous users"
        }

        $details = "MeetingChatEnabledType is set to $($CsTeamsMeetingPolicyChat.MeetingChatEnabledType)"

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "8.5.5"
            Result         = $chatAnonDisabled
            Status         = if ($chatAnonDisabled) { "Pass" } else { "Fail" }
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
