function Test-IdentifyExternalEmail {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
    }

    process {
        # 6.2.3 (L1) Ensure email from external senders is identified

        # Retrieve external sender tagging configuration
        $externalInOutlook = Get-ExternalInOutlook
        $externalTaggingEnabled = ($externalInOutlook | ForEach-Object { $_.Enabled }) -contains $true

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $externalTaggingEnabled) {
            "External sender tagging is disabled"
        }
        else {
            "N/A"
        }

        $details = "Enabled: $($externalTaggingEnabled); AllowList: $($externalInOutlook.AllowList)"

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($externalTaggingEnabled) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "6.2.3"
        $auditResult.RecDescription = "Ensure email from external senders is identified"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"  # Explicitly Not Mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.Result = $externalTaggingEnabled
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
