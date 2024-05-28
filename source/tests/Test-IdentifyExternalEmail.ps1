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
        $params = @{
            Rec            = "6.2.3"
            Result         = $externalTaggingEnabled
            Status         = if ($externalTaggingEnabled) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure email from external senders is identified"
            CISControl     = "0.0"
            CISDescription = "Explicitly Not Mapped"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
