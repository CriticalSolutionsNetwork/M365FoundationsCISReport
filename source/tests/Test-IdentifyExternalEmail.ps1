function Test-IdentifyExternalEmail {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "6.2.3"
    }

    process {

        try {
            # 6.2.3 (L1) Ensure email from external senders is identified

            # Retrieve external sender tagging configuration
            $externalInOutlook = Get-ExternalInOutlook
            $externalTaggingEnabled = ($externalInOutlook | ForEach-Object { $_.Enabled }) -contains $true

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $externalTaggingEnabled) {
                "External sender tagging is disabled"
            }
            else {
                "N/A"
            }

            $details = "Enabled: $($externalTaggingEnabled); AllowList: $($externalInOutlook.AllowList)"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $externalTaggingEnabled
                Status        = if ($externalTaggingEnabled) { "Pass" } else { "Fail" }
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
