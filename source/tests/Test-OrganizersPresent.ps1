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
        $recnum = "8.5.6"
    }

    process {
        try {
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
        $params = @{
            Rec            = $recnum
            Result         = $presenterRoleRestricted
            Status         = if ($presenterRoleRestricted) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
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
