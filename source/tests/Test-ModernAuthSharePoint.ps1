function Test-ModernAuthSharePoint {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 7.2.1 (L1) Ensure modern authentication for SharePoint applications is required
        $SPOTenant = Get-SPOTenant | Select-Object -Property LegacyAuthProtocolsEnabled
        $modernAuthForSPRequired = -not $SPOTenant.LegacyAuthProtocolsEnabled

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $modernAuthForSPRequired) {
            "Legacy authentication protocols are enabled"
        }
        else {
            "N/A"
        }

        $details = "LegacyAuthProtocolsEnabled: $($SPOTenant.LegacyAuthProtocolsEnabled)"

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "7.2.1"
            Result         = $modernAuthForSPRequired
            Status         = if ($modernAuthForSPRequired) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Modern Authentication for SharePoint Applications"
            CISControl     = "3.10"
            CISDescription = "Encrypt Sensitive Data in Transit"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
