function Test-DisallowInfectedFilesDownload {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
    }

    process {
        # 7.3.1 (L2) Ensure Office 365 SharePoint infected files are disallowed for download

        # Retrieve the SharePoint tenant configuration
        $SPOTenantDisallowInfectedFileDownload = Get-SPOTenant | Select-Object DisallowInfectedFileDownload
        $isDisallowInfectedFileDownloadEnabled = $SPOTenantDisallowInfectedFileDownload.DisallowInfectedFileDownload

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $isDisallowInfectedFileDownloadEnabled) {
            "Downloading infected files is not disallowed."
        }
        else {
            "N/A"
        }

        $details = if ($isDisallowInfectedFileDownloadEnabled) {
            "DisallowInfectedFileDownload: True"
        }
        else {
            "DisallowInfectedFileDownload: False"
        }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "7.3.1"
            Result         = $isDisallowInfectedFileDownloadEnabled
            Status         = if ($isDisallowInfectedFileDownloadEnabled) { "Pass" } else { "Fail" }
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
