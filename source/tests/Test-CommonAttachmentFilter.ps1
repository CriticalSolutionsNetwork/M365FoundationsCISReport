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
        $params = @{
            Rec            = "2.1.2"
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
