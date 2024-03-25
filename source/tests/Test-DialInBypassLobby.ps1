function Test-DialInBypassLobby {
    [CmdletBinding()]
    param (
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 8.5.4 (L1) Ensure users dialing in can't bypass the lobby

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $CsTeamsMeetingPolicyPSTN = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AllowPSTNUsersToBypassLobby
        $PSTNBypassDisabled = -not $CsTeamsMeetingPolicyPSTN.AllowPSTNUsersToBypassLobby

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.4"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure users dialing in can't bypass the lobby"
        $auditResult.Result = $PSTNBypassDisabled
        $auditResult.Details = "AllowPSTNUsersToBypassLobby is set to $($CsTeamsMeetingPolicyPSTN.AllowPSTNUsersToBypassLobby)"
        $auditResult.FailureReason = if ($PSTNBypassDisabled) { "N/A" } else { "Users dialing in can bypass the lobby" }
        $auditResult.Status = if ($PSTNBypassDisabled) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
