function Test-OrganizersPresent {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 8.5.6 (L2) Ensure only organizers and co-organizers can present

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        # Retrieve the Teams meeting policy for presenters
        $CsTeamsMeetingPolicyPresenters = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property DesignatedPresenterRoleMode
        $presenterRoleRestricted = $CsTeamsMeetingPolicyPresenters.DesignatedPresenterRoleMode -eq 'OrganizerOnlyUserOverride'

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $presenterRoleRestricted) {
            "Others besides organizers and co-organizers can present"
        }
        else {
            "N/A"
        }

        $details = if ($presenterRoleRestricted) {
            "Only organizers and co-organizers can present."
        }
        else {
            "DesignatedPresenterRoleMode is set to $($CsTeamsMeetingPolicyPresenters.DesignatedPresenterRoleMode)"
        }

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($presenterRoleRestricted) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "8.5.6"
        $auditResult.RecDescription = "Ensure only organizers and co-organizers can present"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # Explicitly Not Mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.Result = $presenterRoleRestricted
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
