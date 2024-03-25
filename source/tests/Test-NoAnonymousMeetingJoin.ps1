function Test-NoAnonymousMeetingJoin {
    [CmdletBinding()]
    param (
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 8.5.1 (L2) Ensure anonymous users can't join a meeting

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $teamsMeetingPolicy = Get-CsTeamsMeetingPolicy -Identity Global
        $allowAnonymousUsersToJoinMeeting = $teamsMeetingPolicy.AllowAnonymousUsersToJoinMeeting

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # The control is Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.1"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L2"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure anonymous users can't join a meeting"
        $auditResult.Result = -not $allowAnonymousUsersToJoinMeeting
        $auditResult.Details = "AllowAnonymousUsersToJoinMeeting is set to $allowAnonymousUsersToJoinMeeting"
        $auditResult.FailureReason = if ($allowAnonymousUsersToJoinMeeting) { "Anonymous users are allowed to join meetings" } else { "N/A" }
        $auditResult.Status = if (-not $allowAnonymousUsersToJoinMeeting) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
