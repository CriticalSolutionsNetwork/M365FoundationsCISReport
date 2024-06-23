function Test-ExternalSharingCalendars {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "1.3.3"

        # Conditions for 1.3.3 (L2) Ensure 'External sharing' of calendars is not available (Automated)
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: In the Microsoft 365 admin center, external calendar sharing is disabled.
        #   - Condition B: Using the Exchange Online PowerShell Module, the `OrganizationConfig` property `ExternalSharingEnabled` is set to `False`.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: In the Microsoft 365 admin center, external calendar sharing is enabled.
        #   - Condition B: Using the Exchange Online PowerShell Module, the `OrganizationConfig` property `ExternalSharingEnabled` is set to `True`.
    }

    process {
        try {
            # Step: Retrieve sharing policies related to calendar sharing
            $sharingPolicies = Get-CISExoOutput -Rec $recnum

            # Step (Condition A & B: Pass/Fail): Check if calendar sharing is disabled in all applicable policies
            $isExternalSharingDisabled = $true
            $sharingPolicyDetails = @()
            foreach ($policy in $sharingPolicies) {
                if ($policy.Enabled -eq $true) {
                    $isExternalSharingDisabled = $false
                    $sharingPolicyDetails += "$($policy.Name): Enabled"
                }
            }

            # Step: Prepare failure reasons and details based on compliance (Condition A & B: Fail)
            $failureReasons = if (-not $isExternalSharingDisabled) {
                "Calendar sharing with external users is enabled in one or more policies."
            }
            else {
                "N/A"
            }

            # Step: Prepare details for the audit result (Condition A & B: Pass/Fail)
            $details = if ($isExternalSharingDisabled) {
                "Calendar sharing with external users is disabled."
            }
            else {
                "Enabled Sharing Policies: $($sharingPolicyDetails -join ', ')"
            }

            # Step: Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $isExternalSharingDisabled
                Status        = if ($isExternalSharingDisabled) { "Pass" } else { "Fail" }
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
