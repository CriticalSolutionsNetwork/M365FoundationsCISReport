function Test-NoAnonymousMeetingJoin {
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
        # 8.5.1 (L2) Ensure anonymous users can't join a meeting

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $teamsMeetingPolicy = Get-CsTeamsMeetingPolicy -Identity Global
        $allowAnonymousUsersToJoinMeeting = $teamsMeetingPolicy.AllowAnonymousUsersToJoinMeeting

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($allowAnonymousUsersToJoinMeeting) {
            "Anonymous users are allowed to join meetings"
        }
        else {
            "N/A"
        }

        $details = "AllowAnonymousUsersToJoinMeeting is set to $allowAnonymousUsersToJoinMeeting"

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # The control is Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.1"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L2"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure anonymous users can't join a meeting"
        $auditResult.Result = -not $allowAnonymousUsersToJoinMeeting
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if (-not $allowAnonymousUsersToJoinMeeting) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}