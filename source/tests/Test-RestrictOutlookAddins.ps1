function Test-RestrictOutlookAddins {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters could include credentials or other necessary data
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code
        $defaultPolicyFailureDetails = @()
        $relevantRoles = @('My Custom Apps', 'My Marketplace Apps', 'My ReadWriteMailbox Apps')
        $recnum = "6.3.1"

        # Conditions for 6.3.1 (L2) Ensure users installing Outlook add-ins is not allowed
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: Verify that the roles MyCustomApps, MyMarketplaceApps, and MyReadWriteMailboxApps are unchecked under Other roles.
        #   - Condition B: Using PowerShell, verify that MyCustomApps, MyMarketplaceApps, and MyReadWriteMailboxApps are not assigned to users.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: One or more of the roles MyCustomApps, MyMarketplaceApps, and MyReadWriteMailboxApps are checked under Other roles.
        #   - Condition B: Using PowerShell, verify that MyCustomApps, MyMarketplaceApps, and MyReadWriteMailboxApps are assigned to users.
    }

    process {
        try {
            # 6.3.1 (L2) Ensure users installing Outlook add-ins is not allowed

            # Check all mailboxes for custom policies with unallowed add-ins
            # Check Default Role Assignment Policy
            $customPolicyFailures, $defaultPolicy = Get-ExoOutput -Rec $recnum
            $defaultPolicyRoles = $defaultPolicy.AssignedRoles | Where-Object { $_ -in $relevantRoles }

            # Condition A: Verify that the roles MyCustomApps, MyMarketplaceApps, and MyReadWriteMailboxApps are unchecked under Other roles.
            if ($defaultPolicyRoles) {
                $defaultPolicyFailureDetails = $defaultPolicyRoles
            }

            # Prepare result details string
            $detailsString = ""
            if ($customPolicyFailures) {
                $detailsString += "Custom Policy Failures: | "
                $detailsString += ($customPolicyFailures -join " | ")
            }
            else {
                $detailsString += "Custom Policy Failures: None | "
            }

            $detailsString += "Default Role Assignment Policy: "
            if ($defaultPolicyFailureDetails) {
                $detailsString += ($defaultPolicyFailureDetails -join ', ')
            }
            else {
                $detailsString += "Compliant"
            }

            # Determine result based on findings
            $isCompliant = -not ($customPolicyFailures -or $defaultPolicyFailureDetails)

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $isCompliant
                Status        = if ($isCompliant) { "Pass" } else { "Fail" }
                Details       = $detailsString
                FailureReason = if ($isCompliant) { "N/A" } else { "Unauthorized Outlook add-ins found in custom or default policies." }
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
