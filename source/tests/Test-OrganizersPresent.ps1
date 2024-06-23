function Test-OrganizersPresent {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
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
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `DesignatedPresenterRoleMode` setting in the Teams meeting policy is set to `OrganizerOnlyUserOverride`.
            #   - Condition B: Verification using the Teams admin center confirms that the setting "Who can present" is configured to "Only organizers and co-organizers".
            #   - Condition C: Verification using PowerShell confirms that the `DesignatedPresenterRoleMode` is set to `OrganizerOnlyUserOverride`.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `DesignatedPresenterRoleMode` setting in the Teams meeting policy is not set to `OrganizerOnlyUserOverride`.
            #   - Condition B: Verification using the Teams admin center indicates that the setting "Who can present" is not configured to "Only organizers and co-organizers".
            #   - Condition C: Verification using PowerShell indicates that the `DesignatedPresenterRoleMode` is not set to `OrganizerOnlyUserOverride`.

            # Retrieve the Teams meeting policy for presenters
            $CsTeamsMeetingPolicyPresenters = Get-CISMSTeamsOutput -Rec $recnum
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
                Rec           = $recnum
                Result        = $presenterRoleRestricted
                Status        = if ($presenterRoleRestricted) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
