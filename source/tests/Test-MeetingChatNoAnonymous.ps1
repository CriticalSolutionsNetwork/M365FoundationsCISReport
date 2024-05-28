function Test-MeetingChatNoAnonymous {
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
        # 8.5.5 (L2) Ensure meeting chat does not allow anonymous users

        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        # Retrieve the Teams meeting policy for meeting chat
        $CsTeamsMeetingPolicyChat = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property MeetingChatEnabledType
        $chatAnonDisabled = $CsTeamsMeetingPolicyChat.MeetingChatEnabledType -eq 'EnabledExceptAnonymous'

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($chatAnonDisabled) {
            "N/A"
        }
        else {
            "Meeting chat allows anonymous users"
        }

        $details = "MeetingChatEnabledType is set to $($CsTeamsMeetingPolicyChat.MeetingChatEnabledType)"

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.5.5"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure meeting chat does not allow anonymous users"
        $auditResult.Result = $chatAnonDisabled
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if ($chatAnonDisabled) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
