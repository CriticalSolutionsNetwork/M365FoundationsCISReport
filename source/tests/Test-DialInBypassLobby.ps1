function Test-DialInBypassLobby {
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
        $RecNum = "8.5.4"
        Write-Verbose "Running Test-DialInBypassLobby for $RecNum..."
    }
    process {
        try {
            # 8.5.4 (L1) Ensure users dialing in can't bypass the lobby
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `AllowPSTNUsersToBypassLobby` setting in the Global Teams meeting policy is set to `False`.
            #   - Condition B: Verification using the UI in the Microsoft Teams admin center confirms that "People dialing in can't bypass the lobby" is set to `Off`.
            #   - Condition C: Ensure that individuals who dial in by phone must wait in the lobby until admitted by a meeting organizer, co-organizer, or presenter.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `AllowPSTNUsersToBypassLobby` setting in the Global Teams meeting policy is not set to `False`.
            #   - Condition B: Verification using the UI in the Microsoft Teams admin center shows that "People dialing in can't bypass the lobby" is not set to `Off`.
            #   - Condition C: Individuals who dial in by phone are able to join the meeting directly without waiting in the lobby.
            # Retrieve Teams meeting policy for PSTN users
            # $CsTeamsMeetingPolicyPSTN Mock Object
            <#
                $CsTeamsMeetingPolicyPSTN = [PSCustomObject]@{
                    AllowPSTNUsersToBypassLobby           = $true
                }
            #>
            $CsTeamsMeetingPolicyPSTN = Get-CISMSTeamsOutput -Rec $RecNum
            $PSTNBypassDisabled = -not $CsTeamsMeetingPolicyPSTN.AllowPSTNUsersToBypassLobby
            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $PSTNBypassDisabled) {
                "Users dialing in can bypass the lobby"
            }
            else {
                "N/A"
            }
            $details = if ($PSTNBypassDisabled) {
                "AllowPSTNUsersToBypassLobby is set to False"
            }
            else {
                "AllowPSTNUsersToBypassLobby is set to True"
            }
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $RecNum
                Result        = $PSTNBypassDisabled
                Status        = if ($PSTNBypassDisabled) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -RecNum $RecNum
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}
