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
        $recnum = "8.5.5"
    }

    process {
        try {
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
                Rec           = $recnum
                Result        = $chatAnonDisabled
                Status        = if ($chatAnonDisabled) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            Write-Error "An error occurred during the test: $_"

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
