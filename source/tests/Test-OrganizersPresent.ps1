function Test-OrganizersPresent {
    [CmdletBinding()]
    param (
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 8.5.6 (L2) Ensure only organizers and co-organizers can present

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $CsTeamsMeetingPolicyPresenters = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property DesignatedPresenterRoleMode
        $presenterRoleRestricted = $CsTeamsMeetingPolicyPresenters.DesignatedPresenterRoleMode -eq 'OrganizerOnlyUserOverride'

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.6"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure only organizers and co-organizers can present"
        $auditResult.Result = $presenterRoleRestricted
        $auditResult.Details = "DesignatedPresenterRoleMode is set to $($CsTeamsMeetingPolicyPresenters.DesignatedPresenterRoleMode)"
        $auditResult.FailureReason = if ($presenterRoleRestricted) { "N/A" } else { "Others besides organizers and co-organizers can present" }
        $auditResult.Status = if ($presenterRoleRestricted) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
