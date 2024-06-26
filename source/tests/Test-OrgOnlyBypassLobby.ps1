function Test-OrgOnlyBypassLobby {
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
        $recnum = "8.5.3"
    }

    process {
        try {
            # 8.5.3 (L1) Ensure only people in my org can bypass the lobby
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `AutoAdmittedUsers` setting in the Teams meeting policy is set to `EveryoneInCompanyExcludingGuests`.
            #   - Condition B: The setting for "Who can bypass the lobby" is configured to "People in my org" using the UI.
            #   - Condition C: Verification using the Microsoft Teams admin center confirms that the meeting join & lobby settings are configured as recommended.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `AutoAdmittedUsers` setting in the Teams meeting policy is not set to `EveryoneInCompanyExcludingGuests`.
            #   - Condition B: The setting for "Who can bypass the lobby" is not configured to "People in my org" using the UI.
            #   - Condition C: Verification using the Microsoft Teams admin center indicates that the meeting join & lobby settings are not configured as recommended.

            # Connect to Teams PowerShell using Connect-MicrosoftTeams

            # Retrieve the Teams meeting policy for lobby bypass settings
            $CsTeamsMeetingPolicyLobby = Get-CISMSTeamsOutput -Rec $recnum
            $lobbyBypassRestricted = $CsTeamsMeetingPolicyLobby.AutoAdmittedUsers -eq 'EveryoneInCompanyExcludingGuests'

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $lobbyBypassRestricted) {
                # Condition C: Verification using the Microsoft Teams admin center indicates that the meeting join & lobby settings are not configured as recommended.
                "AutoAdmittedUsers is set to $($CsTeamsMeetingPolicyLobby.AutoAdmittedUsers)"

            }else {
                "N/A"
            }

            $details = if ($lobbyBypassRestricted) {
                # Condition B: The setting for "Who can bypass the lobby" is configured to "People in my org" using the UI.
                "Only people in the organization can bypass the lobby."
            }else {
                # Condition A: The `AutoAdmittedUsers` setting in the Teams meeting policy is not set to `EveryoneInCompanyExcludingGuests`.
                "External participants can bypass the lobby"
            }
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $lobbyBypassRestricted
                Status        = if ($lobbyBypassRestricted) { "Pass" } else { "Fail" }
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
