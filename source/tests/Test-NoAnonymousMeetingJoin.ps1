function Test-NoAnonymousMeetingJoin {
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
        $recnum = "8.5.1"
        Write-Verbose "Running Test-NoAnonymousMeetingJoin for $recnum..."
    }
    process {
        try {
            # 8.5.1 (L2) Ensure anonymous users can't join a meeting
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: `AllowAnonymousUsersToJoinMeeting` is set to `False`.
            #   - Condition B: Verification using the UI confirms that `Anonymous users can join a meeting` is set to `Off` in the Global meeting policy.
            #   - Condition C: PowerShell command output indicates that anonymous users are not allowed to join meetings.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: `AllowAnonymousUsersToJoinMeeting` is not set to `False`.
            #   - Condition B: Verification using the UI shows that `Anonymous users can join a meeting` is not set to `Off` in the Global meeting policy.
            #   - Condition C: PowerShell command output indicates that anonymous users are allowed to join meetings.
            # Connect to Teams PowerShell using Connect-MicrosoftTeams
            # $teamsMeetingPolicy Mock Object
            <#
                $teamsMeetingPolicy = [PSCustomObject]@{
                    AllowAnonymousUsersToJoinMeeting            = $true
                }
            #>
            $teamsMeetingPolicy = Get-CISMSTeamsOutput -Rec $recnum
            $allowAnonymousUsersToJoinMeeting = $teamsMeetingPolicy.AllowAnonymousUsersToJoinMeeting
            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($allowAnonymousUsersToJoinMeeting) {
                "Anonymous users are allowed to join meetings, remediate with the following command if needed:`nSet-CsTeamsMeetingPolicy -Identity Global -AllowAnonymousUsersToJoinMeeting `$false"
            }
            else {
                "N/A"
            }
            $details = "AllowAnonymousUsersToJoinMeeting is set to $allowAnonymousUsersToJoinMeeting"
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = -not $allowAnonymousUsersToJoinMeeting
                Status        = if (-not $allowAnonymousUsersToJoinMeeting) { "Pass" } else { "Fail" }
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
