function Test-CustomerLockbox {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "1.3.6"

        # Conditions for 1.3.6 (L2) Ensure the customer lockbox feature is enabled (Automated)
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: In the Microsoft 365 admin center, the box labeled "Customer Lockbox Requests" is checked.
        #   - Condition B: Using the SecureScore portal, the Customer Lockbox feature is enabled.
        #   - Condition C: Using PowerShell, the Customer Lockbox feature is set to `True`.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: In the Microsoft 365 admin center, the box labeled "Customer Lockbox Requests" is not checked.
        #   - Condition B: Using the SecureScore portal, the Customer Lockbox feature is not enabled.
        #   - Condition C: Using PowerShell, the Customer Lockbox feature is not set to `True`.
    }

    process {
        try {
            # Step: Retrieve the organization configuration (Condition C: Pass/Fail)
            $orgConfig = Get-OrganizationConfig | Select-Object CustomerLockBoxEnabled
            $customerLockboxEnabled = $orgConfig.CustomerLockBoxEnabled

            # Step: Prepare failure reasons and details based on compliance (Condition A, B, & C: Fail)
            $failureReasons = if (-not $customerLockboxEnabled) {
                "Customer lockbox feature is not enabled."
            }
            else {
                "N/A"
            }

            # Step: Prepare details for the audit result (Condition A, B, & C: Pass/Fail)
            $details = if ($customerLockboxEnabled) {
                "Customer Lockbox Enabled: True"
            }
            else {
                "Customer Lockbox Enabled: False"
            }

            # Step: Create and populate the CISAuditResult object
            $params = @{
                Rec            = $recnum
                Result         = $customerLockboxEnabled
                Status         = if ($customerLockboxEnabled) { "Pass" } else { "Fail" }
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
