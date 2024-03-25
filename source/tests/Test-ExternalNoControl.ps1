function Test-ExternalNoControl {
    [CmdletBinding()]
    param (
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 8.5.7 (L1) Ensure external participants can't give or request control

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $CsTeamsMeetingPolicyControl = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AllowExternalParticipantGiveRequestControl
        $externalControlRestricted = -not $CsTeamsMeetingPolicyControl.AllowExternalParticipantGiveRequestControl

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.7"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure external participants can't give or request control"
        $auditResult.Result = $externalControlRestricted
        $auditResult.Details = "AllowExternalParticipantGiveRequestControl is set to $($CsTeamsMeetingPolicyControl.AllowExternalParticipantGiveRequestControl)"
        $auditResult.FailureReason = if ($externalControlRestricted) { "N/A" } else { "External participants can give or request control" }
        $auditResult.Status = if ($externalControlRestricted) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
