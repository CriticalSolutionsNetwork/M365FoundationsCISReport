function Test-DialInBypassLobby {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "8.5.4"
    }

    process {

        try {
            # 8.5.4 (L1) Ensure users dialing in can't bypass the lobby

            # Retrieve Teams meeting policy for PSTN users
            $CsTeamsMeetingPolicyPSTN = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AllowPSTNUsersToBypassLobby
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
                Rec           = $recnum
                Result        = $PSTNBypassDisabled
                Status        = if ($PSTNBypassDisabled) { "Pass" } else { "Fail" }
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
