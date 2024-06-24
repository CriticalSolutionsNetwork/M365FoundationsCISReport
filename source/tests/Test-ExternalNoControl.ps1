function Test-ExternalNoControl {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        # . .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "8.5.7"
    }

    process {

        try {
            # 8.5.7 (L1) Ensure external participants can't give or request control
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: Ensure the `AllowExternalParticipantGiveRequestControl` setting in Teams is set to `False`.
            #   - Condition B: The setting is verified through the Microsoft Teams admin center or via PowerShell command.
            #   - Condition C: Verification using the UI confirms that external participants are unable to give or request control.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `AllowExternalParticipantGiveRequestControl` setting in Teams is not set to `False`.
            #   - Condition B: The setting is verified through the Microsoft Teams admin center or via PowerShell command.
            #   - Condition C: Verification using the UI indicates that external participants can give or request control.

            # Retrieve Teams meeting policy for external participant control
            $CsTeamsMeetingPolicyControl = Get-CISMSTeamsOutput -Rec $recnum
            # Check if external participants can give or request control
            $externalControlRestricted = -not $CsTeamsMeetingPolicyControl.AllowExternalParticipantGiveRequestControl

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $externalControlRestricted) {
                "External participants can give or request control"
            }
            else {
                "N/A"
            }

            $details = if ($externalControlRestricted) {
                "AllowExternalParticipantGiveRequestControl is set to False"
            }
            else {
                "AllowExternalParticipantGiveRequestControl is set to True"
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec            = $recnum
                Result         = $externalControlRestricted
                Status         = if ($externalControlRestricted) { "Pass" } else { "Fail" }
                Details        = $details
                FailureReason  = $failureReasons
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
