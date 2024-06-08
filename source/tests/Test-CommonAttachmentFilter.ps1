function Test-CommonAttachmentFilter {
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
        $recnum = "2.1.2"
    }

    process {
        try {
            # 2.1.2 (L1) Ensure the Common Attachment Types Filter is enabled

            # Retrieve the attachment filter policy
            $attachmentFilter = Get-MalwareFilterPolicy -Identity Default | Select-Object EnableFileFilter
            $result = $attachmentFilter.EnableFileFilter

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $result) {
                "Common Attachment Types Filter is disabled"
            }
            else {
                "N/A"
            }

            $details = if ($result) {
                "File Filter Enabled: True"
            }
            else {
                "File Filter Enabled: False"
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $result
                Status        = if ($result) { "Pass" } else { "Fail" }
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
