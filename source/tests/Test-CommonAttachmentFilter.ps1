function Test-CommonAttachmentFilter {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {

        $auditResults = @()
    }

    process {
        # 2.1.2 (L1) Ensure the Common Attachment Types Filter is enabled
        # Pass if EnableFileFilter is set to True. Fail otherwise.

        $attachmentFilter = Get-MalwareFilterPolicy -Identity Default | Select-Object EnableFileFilter
        $result = $attachmentFilter.EnableFileFilter
        $details = "File Filter Enabled: $($attachmentFilter.EnableFileFilter)"
        $failureReason = if ($result) { "N/A" } else { "Common Attachment Types Filter is disabled" }
        $status = if ($result) { "Pass" } else { "Fail" }

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = $status
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "2.1.2"
        $auditResult.RecDescription = "Ensure the Common Attachment Types Filter is enabled"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "9.6"
        $auditResult.CISDescription = "Block Unnecessary File Types"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $true
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
