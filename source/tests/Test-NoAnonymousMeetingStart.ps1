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
        $recnum = "8.5.2"
    }

    process {
        try {
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
            $params = @{
                Rec           = $recnum
                Result        = $anonymousStartDisabled
                Status        = if ($anonymousStartDisabled) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
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
