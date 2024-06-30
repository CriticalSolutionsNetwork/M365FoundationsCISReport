function Test-NoAnonymousMeetingStart {
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
        $recnum = "8.5.2"
    }
    process {
        try {
            # 8.5.2 (L1) Ensure anonymous users and dial-in callers can't start a meeting
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `AllowAnonymousUsersToStartMeeting` setting in the Teams admin center is set to `False`.
            #   - Condition B: The setting for anonymous users and dial-in callers starting a meeting is configured to ensure they must wait in the lobby.
            #   - Condition C: Verification using the UI confirms that the setting `Anonymous users and dial-in callers can start a meeting` is set to `Off`.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `AllowAnonymousUsersToStartMeeting` setting in the Teams admin center is not set to `False`.
            #   - Condition B: The setting for anonymous users and dial-in callers starting a meeting allows them to bypass the lobby.
            #   - Condition C: Verification using the UI indicates that the setting `Anonymous users and dial-in callers can start a meeting` is not set to `Off`.
            # Connect to Teams PowerShell using Connect-MicrosoftTeams
            # Retrieve the Teams meeting policy for the global scope and check if anonymous users can start meetings
            $CsTeamsMeetingPolicyAnonymous = Get-CISMSTeamsOutput -Rec $recnum
            $anonymousStartDisabled = -not $CsTeamsMeetingPolicyAnonymous.AllowAnonymousUsersToStartMeeting
            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($anonymousStartDisabled) {
                "N/A"
            }
            else {
                "Anonymous users and dial-in callers can start a meeting" # Condition A and B
            }
            $details = "AllowAnonymousUsersToStartMeeting is set to $($CsTeamsMeetingPolicyAnonymous.AllowAnonymousUsersToStartMeeting)" # Condition C
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $anonymousStartDisabled
                Status        = if ($anonymousStartDisabled) { "Pass" } else { "Fail" }
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
