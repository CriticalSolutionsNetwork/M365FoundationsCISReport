function Test-GlobalAdminsCount {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Define your parameters here if needed
    )

    begin {
                # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Conditions for 1.1.3 (L1) Ensure that between two and four global admins are designated
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: The number of global admins is at least 2.
        #   - Condition B: The number of global admins is at most 4.
        #   - Condition C: The list of global admin usernames is accurately retrieved and displayed.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: The number of global admins is less than 2.
        #   - Condition B: The number of global admins is more than 4.
        #   - Condition C: Any discrepancies or errors in retrieving the list of global admin usernames.

        # Initialization code, if needed
        $recnum = "1.1.3"
    }

    process {
        try {
            $globalAdmins = Get-CISMgOutput -Rec $recnum

            # Step: Count the number of global admins
            $globalAdminCount = $globalAdmins.Count

            # Step: Retrieve and format the usernames of global admins
            $globalAdminUsernames = ($globalAdmins | ForEach-Object {
                "$($_.AdditionalProperties["displayName"]) ($($_.AdditionalProperties["userPrincipalName"]))"
            }) -join ', '

            # Step: Determine failure reasons based on global admin count
            $failureReasons = if ($globalAdminCount -lt 2) {
                "Less than 2 global admins: $globalAdminUsernames"
            }
            elseif ($globalAdminCount -gt 4) {
                "More than 4 global admins: $globalAdminUsernames"
            }
            else {
                "N/A"
            }

            # Step: Prepare details for the audit result
            $details = "Count: $globalAdminCount; Users: $globalAdminUsernames"

            # Step: Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $globalAdminCount -ge 2 -and $globalAdminCount -le 4
                Status        = if ($globalAdminCount -ge 2 -and $globalAdminCount -le 4) { "Pass" } else { "Fail" }
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
