function Test-NoAnonymousMeetingStart {
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
        # 8.5.2 (L1) Ensure anonymous users and dial-in callers can't start a meeting

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $CsTeamsMeetingPolicyAnonymous = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AllowAnonymousUsersToStartMeeting
        $anonymousStartDisabled = -not $CsTeamsMeetingPolicyAnonymous.AllowAnonymousUsersToStartMeeting

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($anonymousStartDisabled) {
            "N/A"
        }
        else {
            "Anonymous users and dial-in callers can start a meeting"
        }

        $details = "AllowAnonymousUsersToStartMeeting is set to $($CsTeamsMeetingPolicyAnonymous.AllowAnonymousUsersToStartMeeting)"

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.2"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure anonymous users and dial-in callers can't start a meeting"
        $auditResult.Result = $anonymousStartDisabled
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if ($anonymousStartDisabled) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
