function Test-DialInBypassLobby {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary

        # Initialization code, if needed
    }

    process {
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
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"  # Explicitly Not Mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.4"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false  # Set based on the CIS Controls image
        $auditResult.IG2 = $false  # Set based on the CIS Controls image
        $auditResult.IG3 = $false  # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure users dialing in can't bypass the lobby"
        $auditResult.Result = $PSTNBypassDisabled
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if ($PSTNBypassDisabled) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
