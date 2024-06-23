function Test-ModernAuthExchangeOnline {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Conditions for 6.5.1 (L1) Ensure modern authentication for Exchange Online is enabled
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: Modern authentication for Exchange Online is enabled.
        #   - Condition B: Exchange Online clients use modern authentication to log in to Microsoft 365 mailboxes.
        #   - Condition C: Users of older email clients, such as Outlook 2013 and Outlook 2016, are no longer able to authenticate to Exchange using Basic Authentication.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: Modern authentication for Exchange Online is not enabled.
        #   - Condition B: Exchange Online clients do not use modern authentication to log in to Microsoft 365 mailboxes.
        #   - Condition C: Users of older email clients, such as Outlook 2013 and Outlook 2016, are still able to authenticate to Exchange using Basic Authentication.

        $recnum = "6.5.1"
    }

    process {
        try {
            # 6.5.1 (L1) Ensure modern authentication for Exchange Online is enabled

            # Check modern authentication setting in Exchange Online configuration (Condition A and B)
            $orgConfig = Get-CISExoOutput -Rec $recnum

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $orgConfig.OAuth2ClientProfileEnabled) {
                "Modern authentication is disabled"
            }
            else {
                "N/A"
            }

            # Details include the current setting (Condition A and B)
            $details = "OAuth2ClientProfileEnabled: $($orgConfig.OAuth2ClientProfileEnabled) for Organization: $($orgConfig.Name)"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $orgConfig.OAuth2ClientProfileEnabled
                Status        = if ($orgConfig.OAuth2ClientProfileEnabled) { "Pass" } else { "Fail" }
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
