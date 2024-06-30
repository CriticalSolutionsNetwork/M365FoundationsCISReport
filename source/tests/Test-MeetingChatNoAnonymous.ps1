function Test-MeetingChatNoAnonymous {
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
        $recnum = "8.5.5"
        Write-Verbose "Running Test-MeetingChatNoAnonymous for $recnum..."
    }
    process {
        try {
            # 8.5.5 (L2) Ensure meeting chat does not allow anonymous users
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `MeetingChatEnabledType` setting in Teams is set to `EnabledExceptAnonymous`.
            #   - Condition B: The setting for meeting chat is configured to allow chat for everyone except anonymous users.
            #   - Condition C: Verification using the Teams Admin Center confirms that the meeting chat settings are configured as recommended.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `MeetingChatEnabledType` setting in Teams is not set to `EnabledExceptAnonymous`.
            #   - Condition B: The setting for meeting chat allows chat for anonymous users.
            #   - Condition C: Verification using the Teams Admin Center indicates that the meeting chat settings are not configured as recommended.
            # Retrieve the Teams meeting policy for meeting chat
            # $CsTeamsMeetingPolicyChat Mock Object
            <#
                $CsTeamsMeetingPolicyChat = [PSCustomObject]@{
                    MeetingChatEnabledType           = "Enabled"
                }
            #>
            $CsTeamsMeetingPolicyChat = Get-CISMSTeamsOutput -Rec $recnum
            # Condition A: Check if the MeetingChatEnabledType is set to 'EnabledExceptAnonymous'
            $chatAnonDisabled = $CsTeamsMeetingPolicyChat.MeetingChatEnabledType -eq 'EnabledExceptAnonymous'
            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($chatAnonDisabled) {
                "N/A"
            }
            else {
                "Meeting chat allows anonymous users. User the following command to remediate:`nSet-CsTeamsMeetingPolicy -Identity Global -MeetingChatEnabledType `"EnabledExceptAnonymous`""
            }
            $details = "MeetingChatEnabledType is set to $($CsTeamsMeetingPolicyChat.MeetingChatEnabledType)"
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $chatAnonDisabled
                Status        = if ($chatAnonDisabled) { "Pass" } else { "Fail" }
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
