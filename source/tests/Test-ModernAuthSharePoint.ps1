function Test-ModernAuthSharePoint {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "7.2.1"

        <#
        # Conditions for 7.2.1 (L1) Ensure modern authentication for SharePoint applications is required

        ## Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: The setting "Apps that don't use modern authentication" is set to "Block access" in the SharePoint admin center.
        #   - Condition B: The PowerShell command `Get-SPOTenant | ft LegacyAuthProtocolsEnabled` returns `False`.

        ## Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: The setting "Apps that don't use modern authentication" is not set to "Block access" in the SharePoint admin center.
        #   - Condition B: The PowerShell command `Get-SPOTenant | ft LegacyAuthProtocolsEnabled` returns `True`.
        #>
    }

    process {
        try {
            # 7.2.1 (L1) Ensure modern authentication for SharePoint applications is required
            $SPOTenant = Get-SPOTenant | Select-Object -Property LegacyAuthProtocolsEnabled
            $modernAuthForSPRequired = -not $SPOTenant.LegacyAuthProtocolsEnabled

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $modernAuthForSPRequired) {
                "Legacy authentication protocols are enabled" # Fail Condition B
            }
            else {
                "N/A"
            }

            $details = "LegacyAuthProtocolsEnabled: $($SPOTenant.LegacyAuthProtocolsEnabled)" # Details for Condition B

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $modernAuthForSPRequired
                Status        = if ($modernAuthForSPRequired) { "Pass" } else { "Fail" }
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
