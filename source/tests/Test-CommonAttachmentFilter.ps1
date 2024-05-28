function Test-CommonAttachmentFilter {
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
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($result) { "Pass" } else { "Fail" }
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
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
