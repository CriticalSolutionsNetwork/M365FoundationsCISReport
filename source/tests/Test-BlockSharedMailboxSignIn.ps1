function Test-BlockSharedMailboxSignIn {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "1.2.2"

        # Conditions for 1.2.2 (L1) Ensure sign-in to shared mailboxes is blocked
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: No shared mailboxes have the "Sign-in blocked" option disabled in the properties pane on the Microsoft 365 admin center.
        #   - Condition B: Using PowerShell, the `AccountEnabled` property for all shared mailboxes is set to `False`.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: One or more shared mailboxes have the "Sign-in blocked" option enabled in the properties pane on the Microsoft 365 admin center.
        #   - Condition B: Using PowerShell, the `AccountEnabled` property for one or more shared mailboxes is set to `True`.
    }

    process {
        try {
            # Step: Retrieve shared mailbox details
            $MBX = Get-EXOMailbox -RecipientTypeDetails SharedMailbox

            # Step: Retrieve details of shared mailboxes from Azure AD (Condition B: Pass/Fail)
            $sharedMailboxDetails = $MBX | ForEach-Object { Get-AzureADUser -ObjectId $_.ExternalDirectoryObjectId }

            # Step: Identify enabled mailboxes (Condition B: Pass/Fail)
            $enabledMailboxes = $sharedMailboxDetails | Where-Object { $_.AccountEnabled } | ForEach-Object { $_.DisplayName }
            $allBlocked = $enabledMailboxes.Count -eq 0

            # Step: Determine failure reasons based on enabled mailboxes (Condition A & B: Fail)
            $failureReasons = if (-not $allBlocked) {
                "Some mailboxes have sign-in enabled: $($enabledMailboxes -join ', ')"
            }
            else {
                "N/A"
            }

            # Step: Prepare details for the audit result (Condition A & B: Pass/Fail)
            $details = if ($allBlocked) {
                "All shared mailboxes have sign-in blocked."
            }
            else {
                "Enabled Mailboxes: $($enabledMailboxes -join ', ')"
            }

            # Step: Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $allBlocked  # Pass: Condition A, Condition B
                Status        = if ($allBlocked) { "Pass" } else { "Fail" }
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
