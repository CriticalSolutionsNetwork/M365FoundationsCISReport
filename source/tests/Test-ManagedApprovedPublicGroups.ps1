function Test-ManagedApprovedPublicGroups {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "1.2.1"

        # Conditions for 1.2.1 (L2) Ensure that only organizationally managed/approved public groups exist (Automated)
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: No groups have the status 'Public' in the privacy column on the Active teams and groups page.
        #   - Condition B: Using Microsoft Graph PowerShell, all groups return a status other than 'Public' when checked.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: One or more groups have the status 'Public' in the privacy column on the Active teams and groups page.
        #   - Condition B: Using Microsoft Graph PowerShell, one or more groups return a status of 'Public' when checked.
    }

    process {
        try {
            # Step: Retrieve all groups with visibility set to 'Public'
            $allGroups = Get-MgOutput -Rec $recnum

            # Step: Determine failure reasons based on the presence of public groups
            $failureReasons = if ($null -ne $allGroups -and $allGroups.Count -gt 0) {
                "There are public groups present that are not organizationally managed/approved."
            }
            else {
                "N/A"
            }

            # Step: Prepare details for the audit result
            $details = if ($null -eq $allGroups -or $allGroups.Count -eq 0) {
                "No public groups found."
            }
            else {
                $groupDetails = $allGroups | ForEach-Object { $_.DisplayName + " (" + $_.Visibility + ")" }
                "Public groups found: $($groupDetails -join ', ')"
            }

            # Step: Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $null -eq $allGroups -or $allGroups.Count -eq 0
                Status        = if ($null -eq $allGroups -or $allGroups.Count -eq 0) { "Pass" } else { "Fail" }
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
