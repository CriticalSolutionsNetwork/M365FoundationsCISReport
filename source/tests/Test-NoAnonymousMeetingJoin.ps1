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
        $recnum = "8.5.1"
    }

    process {
        try {
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
            Write-Error "An error occurred during the test: $_"

            # Retrieve the description from the test definitions
            $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
            $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }

            $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
