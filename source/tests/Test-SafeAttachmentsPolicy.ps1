function Test-SafeAttachmentsPolicy {
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
        $recnum = "2.1.4"
    }

    process {
        try {
            # 2.1.4 (L2) Ensure Safe Attachments policy is enabled

            # Retrieve all Safe Attachment policies where Enable is set to True
            $safeAttachmentPolicies = Get-SafeAttachmentPolicy | Where-Object { $_.Enable -eq $true }

            # Determine result and details based on the presence of enabled policies
            $result = $null -ne $safeAttachmentPolicies -and $safeAttachmentPolicies.Count -gt 0
            $details = if ($result) {
                "Enabled Safe Attachments Policies: $($safeAttachmentPolicies.Name -join ', ')"
            }
            else {
                "No Safe Attachments Policies are enabled."
            }

            $failureReasons = if ($result) {
                "N/A"
            }
            else {
                "Safe Attachments policy is not enabled."
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

# Additional helper functions (if any)
