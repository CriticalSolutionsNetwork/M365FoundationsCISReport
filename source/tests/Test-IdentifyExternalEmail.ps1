function Test-IdentifyExternalEmail {
    [CmdletBinding()]
    param (
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 6.2.3 (L1) Ensure email from external senders is identified
        # Requirement is to have external sender tagging enabled

        $externalInOutlook = Get-ExternalInOutlook
        $externalTaggingEnabled = ($externalInOutlook | ForEach-Object { $_.Enabled }) -contains $true

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($externalTaggingEnabled) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "6.2.3"
        $auditResult.RecDescription = "Ensure email from external senders is identified"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.Result = $externalTaggingEnabled
        $auditResult.Details = "Enabled: $($externalTaggingEnabled); AllowList: $($externalInOutlook.AllowList)"
        $auditResult.FailureReason = if (-not $externalTaggingEnabled) { "External sender tagging is disabled" } else { "N/A" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
