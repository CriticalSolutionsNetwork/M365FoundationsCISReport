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
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($result) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E5"
        $auditResult.ProfileLevel = "L2"
        $auditResult.Rec = "2.1.4"
        $auditResult.RecDescription = "Ensure Safe Attachments policy is enabled"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "9.7"
        $auditResult.CISDescription = "Deploy and Maintain Email Server Anti-Malware Protections"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $true
        $auditResult.Result = $result
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}

# Additional helper functions (if any)
