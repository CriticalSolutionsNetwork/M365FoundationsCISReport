function Test-CustomerLockbox {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "1.3.6"
    }

    process {

        try {
        # 1.3.6 (L2) Ensure the customer lockbox feature is enabled

        # Retrieve the organization configuration
        $orgConfig = Get-OrganizationConfig | Select-Object CustomerLockBoxEnabled
        $customerLockboxEnabled = $orgConfig.CustomerLockBoxEnabled

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $customerLockboxEnabled) {
            "Customer lockbox feature is not enabled."
        }
        else {
            "N/A"
        }

        $details = if ($customerLockboxEnabled) {
            "Customer Lockbox Enabled: True"
        }
        else {
            "Customer Lockbox Enabled: False"
        }

        # Create and populate the CISAuditResult object #
        $params = @{
            Rec            = $recnum
            Result         = $customerLockboxEnabled
            Status         = if ($customerLockboxEnabled) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
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
