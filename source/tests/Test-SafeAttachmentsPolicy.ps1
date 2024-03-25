function Test-SafeAttachmentsPolicy {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {

        $auditResults = @()
    }

    process {
        # Retrieve all Safe Attachment policies where Enable is set to True
        $safeAttachmentPolicies = Get-SafeAttachmentPolicy | Where-Object { $_.Enable -eq $true }

        # If there are any enabled policies, the result is Pass. If not, it's Fail.
        $result = $safeAttachmentPolicies -ne $null -and $safeAttachmentPolicies.Count -gt 0
        $details = if ($result) {
            "Enabled Safe Attachments Policies: $($safeAttachmentPolicies.Name -join ', ')"
        } else {
            "No Safe Attachments Policies are enabled."
        }
        $failureReason = if ($result) { "N/A" } else { "Safe Attachments policy is not enabled." }

        # Create an instance of CISAuditResult and populate it
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
        $auditResult.FailureReason = $failureReason

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
