function Test-ExternalNoControl {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "8.5.7"
    }

    process {

        try {
        # 8.5.7 (L1) Ensure external participants can't give or request control

        # Retrieve Teams meeting policy for external participant control
        $CsTeamsMeetingPolicyControl = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AllowExternalParticipantGiveRequestControl
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
