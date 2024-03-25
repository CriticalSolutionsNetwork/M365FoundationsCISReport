function Test-MeetingChatNoAnonymous {
    [CmdletBinding()]
    param (
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 8.5.5 (L2) Ensure meeting chat does not allow anonymous users
        # Name doesn't match profile level in benchmarks either.

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $CsTeamsMeetingPolicyChat = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property MeetingChatEnabledType
        $chatAnonDisabled = $CsTeamsMeetingPolicyChat.MeetingChatEnabledType -eq 'EnabledExceptAnonymous'

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.5"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure meeting chat does not allow anonymous users"
        $auditResult.Result = $chatAnonDisabled
        $auditResult.Details = "MeetingChatEnabledType is set to $($CsTeamsMeetingPolicyChat.MeetingChatEnabledType)"
        $auditResult.FailureReason = if ($chatAnonDisabled) { "N/A" } else { "Meeting chat allows anonymous users" }
        $auditResult.Status = if ($chatAnonDisabled) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
