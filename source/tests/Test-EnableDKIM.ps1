function Test-EnableDKIM {
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
        # 2.1.9 (L1) Ensure DKIM is enabled for all Exchange Online Domains

        # Retrieve DKIM configuration for all domains
        $dkimConfig = Get-DkimSigningConfig | Select-Object Domain, Enabled
        $dkimResult = ($dkimConfig | ForEach-Object { $_.Enabled }) -notcontains $false
        $dkimFailedDomains = $dkimConfig | Where-Object { -not $_.Enabled } | ForEach-Object { $_.Domain }

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $dkimResult) {
            "DKIM is not enabled for some domains"
        }
        else {
            "N/A"
        }

        $details = if ($dkimResult) {
            "All domains have DKIM enabled"
        }
        else {
            "DKIM not enabled for: $($dkimFailedDomains -join ', ')"
        }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "2.1.9"
            Result         = $dkimResult
            Status         = if ($dkimResult) { "Pass" } else { "Fail" }
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
