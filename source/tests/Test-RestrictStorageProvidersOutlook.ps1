function Test-RestrictStorageProvidersOutlook {
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
        $recnum = "6.5.3"
    }

    process {
        try {
            # 6.5.3 (L2) Ensure additional storage providers are restricted in Outlook on the web

            # Retrieve all OwaMailbox policies
            $owaPolicies = Get-OwaMailboxPolicy
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

# Additional helper functions (if any)
