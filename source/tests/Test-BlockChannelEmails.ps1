function Test-BlockChannelEmails {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "8.1.2"
    }

    process {

        try {
            # 8.1.2 (L1) Ensure users can't send emails to a channel email address
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `AllowEmailIntoChannel` setting in Teams is set to `False`.
            #   - Condition B: The setting `Users can send emails to a channel email address` is set to `Off` in the Teams admin center.
            #   - Condition C: Verification using PowerShell confirms that the `AllowEmailIntoChannel` setting is disabled.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `AllowEmailIntoChannel` setting in Teams is not set to `False`.
            #   - Condition B: The setting `Users can send emails to a channel email address` is not set to `Off` in the Teams admin center.
            #   - Condition C: Verification using PowerShell indicates that the `AllowEmailIntoChannel` setting is enabled.

            # Retrieve Teams client configuration
            $teamsClientConfig = Get-CsTeamsClientConfiguration -Identity Global
            $allowEmailIntoChannel = $teamsClientConfig.AllowEmailIntoChannel

            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($allowEmailIntoChannel) {
                "Emails can be sent to a channel email address" # Condition A Fail: AllowEmailIntoChannel is True
            }
            else {
                "N/A" # Condition A Pass: AllowEmailIntoChannel is False
            }

            $details = if ($allowEmailIntoChannel) {
                "AllowEmailIntoChannel is set to True" # Condition B Fail: Emails are allowed
            }
            else {
                "AllowEmailIntoChannel is set to False" # Condition B Pass: Emails are blocked
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec            = $recnum
                Result         = -not $allowEmailIntoChannel
                Status         = if (-not $allowEmailIntoChannel) { "Pass" } else { "Fail" }
                Details        = $details
                FailureReason  = $failureReasons
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
