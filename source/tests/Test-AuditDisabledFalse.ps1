function Test-AuditDisabledFalse {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    # Aligned
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Conditions for 6.1.1 (L1) Ensure 'AuditDisabled' organizationally is set to 'False'
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: The `AuditDisabled` organizational setting is set to `False` in the Microsoft 365 admin center.
        #   - Condition B: Using PowerShell, the `AuditDisabled` property in the organization's configuration is set to `False`.
        #   - Condition C: Ensure mailbox auditing is enabled by default at the organizational level.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: The `AuditDisabled` organizational setting is set to `True` in the Microsoft 365 admin center.
        #   - Condition B: Using PowerShell, the `AuditDisabled` property in the organization's configuration is set to `True`.
        #   - Condition C: Mailbox auditing is not enabled by default at the organizational level.

        # Initialization code, if needed
        $recnum = "6.1.1"
    }

    process {
        try {
            # 6.1.1 (L1) Ensure 'AuditDisabled' organizationally is set to 'False'

            # Retrieve the AuditDisabled configuration (Condition B)
            $auditDisabledConfig = Get-OrganizationConfig | Select-Object AuditDisabled
            $auditNotDisabled = -not $auditDisabledConfig.AuditDisabled

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $auditNotDisabled) {
                "AuditDisabled is set to True"  # Condition A Fail
            }
            else {
                "N/A"
            }

            $details = if ($auditNotDisabled) {
                "Audit is not disabled organizationally"  # Condition C Pass
            }
            else {
                "Audit is disabled organizationally"  # Condition C Fail
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $auditNotDisabled
                Status        = if ($auditNotDisabled) { "Pass" } else { "Fail" }
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
