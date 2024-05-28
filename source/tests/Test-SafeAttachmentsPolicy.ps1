function Test-SafeAttachmentsPolicy {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
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
            Rec            = "2.1.4"
            Result         = $result
            Status         = if ($result) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}

# Additional helper functions (if any)
