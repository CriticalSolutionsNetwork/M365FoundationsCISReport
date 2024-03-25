function Test-DisallowInfectedFilesDownload_7.3.1_E5L2_IG1_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {
        # Initialization code
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 7.3.1 (L2) Ensure Office 365 SharePoint infected files are disallowed for download
        $SPOTenantDisallowInfectedFileDownload = Get-SPOTenant | Select-Object DisallowInfectedFileDownload
        $isDisallowInfectedFileDownloadEnabled = $SPOTenantDisallowInfectedFileDownload.DisallowInfectedFileDownload

        # Populate the auditResult object with the required properties
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "10.1"
        $auditResult.CISDescription = "Deploy and Maintain Anti-Malware Software"

        $auditResult.Rec = "7.3.1"
        $auditResult.ELevel = "E5"
        $auditResult.Profile = "L2"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Ensure Office 365 SharePoint infected files are disallowed for download"

        $auditResult.Result = $isDisallowInfectedFileDownloadEnabled
        $auditResult.Details = "DisallowInfectedFileDownload: $($SPOTenantDisallowInfectedFileDownload.DisallowInfectedFileDownload)"
        $auditResult.FailureReason = if (-not $isDisallowInfectedFileDownloadEnabled) { "Downloading infected files is not disallowed." } else { "N/A" }
        $auditResult.Status = if ($isDisallowInfectedFileDownloadEnabled) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
