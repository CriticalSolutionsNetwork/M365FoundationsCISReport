function Test-RestrictStorageProvidersOutlook {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added here if needed
    )

    begin {
        <#
        # 6.5.3 (L2) Ensure additional storage providers are restricted in Outlook on the web
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: Using PowerShell, verify that `AdditionalStorageProvidersAvailable` is set to `False` in the OwaMailboxPolicy.
        #   - Condition B: Ensure that the command `Get-OwaMailboxPolicy | Format-Table Name, AdditionalStorageProvidersAvailable` returns `False`.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: Using PowerShell, verify that `AdditionalStorageProvidersAvailable` is not set to `False` in the OwaMailboxPolicy.
        #   - Condition B: Ensure that the command `Get-OwaMailboxPolicy | Format-Table Name, AdditionalStorageProvidersAvailable` does not return `False`.
        #>

        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "6.5.3"
    }

    process {
        try {
            # 6.5.3 (L2) Ensure additional storage providers are restricted in Outlook on the web

            # Retrieve all OwaMailbox policies
            $owaPolicies = Get-ExoOutput -Rec $recnum
            # Condition A: Check if AdditionalStorageProvidersAvailable is set to False
            $nonCompliantPolicies = $owaPolicies | Where-Object { $_.AdditionalStorageProvidersAvailable }

            # Determine compliance
            $allPoliciesRestricted = $nonCompliantPolicies.Count -eq 0

            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($allPoliciesRestricted) {
                "N/A"
            }
            else {
                "One or more OwaMailbox policies allow AdditionalStorageProvidersAvailable."
            }

            $details = if ($allPoliciesRestricted) {
                "All OwaMailbox policies restrict AdditionalStorageProvidersAvailable"
            }
            else {
                "Non-compliant OwaMailbox policies: $($nonCompliantPolicies.Name -join ', ')"
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $allPoliciesRestricted
                Status        = if ($allPoliciesRestricted) { "Pass" } else { "Fail" }
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
