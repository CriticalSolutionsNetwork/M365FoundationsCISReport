function Test-ExternalNoControl {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        # . .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
    }

    process {
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
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"  # Explicitly Not Mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.7"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false  # Set based on the CIS Controls image
        $auditResult.IG2 = $false  # Set based on the CIS Controls image
        $auditResult.IG3 = $false  # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure external participants can't give or request control"
        $auditResult.Result = $externalControlRestricted
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if ($externalControlRestricted) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
