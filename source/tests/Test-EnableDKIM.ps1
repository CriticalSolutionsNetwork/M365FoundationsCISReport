function Test-EnableDKIM {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "2.1.9"
    }

    process {

        try {
        # 2.1.9 (L1) Ensure DKIM is enabled for all Exchange Online Domains

        # Retrieve DKIM configuration for all domains
        $dkimConfig = Get-DkimSigningConfig | Select-Object Domain, Enabled
        $dkimResult = ($dkimConfig | ForEach-Object { $_.Enabled }) -notcontains $false
        $dkimFailedDomains = $dkimConfig | Where-Object { -not $_.Enabled } | ForEach-Object { $_.Domain }

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $dkimResult) {
            "DKIM is not enabled for some domains"
        }
        else {
            "N/A"
        }

        $details = if ($dkimResult) {
            "All domains have DKIM enabled"
        }
        else {
            "DKIM not enabled for: $($dkimFailedDomains -join ', ')"
        }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = $recnum
            Result         = $dkimResult
            Status         = if ($dkimResult) { "Pass" } else { "Fail" }
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
