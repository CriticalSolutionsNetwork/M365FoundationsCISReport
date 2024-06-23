function Test-PasswordHashSync {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Conditions for 5.1.8.1 (L1) Ensure password hash sync is enabled for hybrid deployments
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: Password hash sync is enabled in the Azure AD Connect tool on the on-premises server.
        #   - Condition B: Password hash sync is verified as enabled in the Azure AD Connect Sync section in the Microsoft Entra admin center.
        #   - Condition C: Using Microsoft Graph PowerShell, the verification command returns the expected result indicating that password sync is enabled for the on-premises AD.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: Password hash sync is not enabled in the Azure AD Connect tool on the on-premises server.
        #   - Condition B: Password hash sync is not verified as enabled in the Azure AD Connect Sync section in the Microsoft Entra admin center.
        #   - Condition C: Using Microsoft Graph PowerShell, the verification command returns no result indicating that password sync is not enabled for the on-premises AD.

        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "5.1.8.1"
    }

    process {
        try {
            # 5.1.8.1 (L1) Ensure password hash sync is enabled for hybrid deployments

            # Retrieve password hash sync status (Condition A and C)
            $passwordHashSync = Get-CISMgOutput -Rec $recnum
            $hashSyncResult = $passwordHashSync

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $hashSyncResult) {
                "Password hash sync for hybrid deployments is not enabled"
            }
            else {
                "N/A"
            }

            $details = "OnPremisesSyncEnabled: $($passwordHashSync)"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $hashSyncResult
                Status        = if ($hashSyncResult) { "Pass" } else { "Fail" }
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
