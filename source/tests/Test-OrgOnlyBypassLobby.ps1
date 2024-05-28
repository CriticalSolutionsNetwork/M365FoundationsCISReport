function Test-OrgOnlyBypassLobby {
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
        # 8.5.3 (L1) Ensure only people in my org can bypass the lobby

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        # Retrieve the Teams meeting policy for lobby bypass settings
        $CsTeamsMeetingPolicyLobby = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AutoAdmittedUsers
        $lobbyBypassRestricted = $CsTeamsMeetingPolicyLobby.AutoAdmittedUsers -eq 'EveryoneInCompanyExcludingGuests'

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $lobbyBypassRestricted) {
            "External participants can bypass the lobby"
        }
        else {
            "N/A"
        }

        $details = if ($lobbyBypassRestricted) {
            "Only people in the organization can bypass the lobby."
        }
        else {
            "AutoAdmittedUsers is set to $($CsTeamsMeetingPolicyLobby.AutoAdmittedUsers)"
        }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "8.5.3"
            Result         = $lobbyBypassRestricted
            Status         = if ($lobbyBypassRestricted) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure only people in my org can bypass the lobby"
            CISControl     = "6.8"
            CISDescription = "Define and Maintain Role-Based Access Control"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
