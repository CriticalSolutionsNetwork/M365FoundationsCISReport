function Test-OrgOnlyBypassLobby {
    [CmdletBinding()]
    param (
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 8.5.3 (L1) Ensure only people in my org can bypass the lobby

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $CsTeamsMeetingPolicyLobby = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AutoAdmittedUsers
        $lobbyBypassRestricted = $CsTeamsMeetingPolicyLobby.AutoAdmittedUsers -eq 'EveryoneInCompanyExcludingGuests'

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "6.8"
        $auditResult.CISDescription = "Define and Maintain Role-Based Access Control"
        $auditResult.Rec = "8.5.3"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $true # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure only people in my org can bypass the lobby"
        $auditResult.Result = $lobbyBypassRestricted
        $auditResult.Details = "AutoAdmittedUsers is set to $($CsTeamsMeetingPolicyLobby.AutoAdmittedUsers)"
        $auditResult.FailureReason = if ($lobbyBypassRestricted) { "N/A" } else { "External participants can bypass the lobby" }
        $auditResult.Status = if ($lobbyBypassRestricted) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
