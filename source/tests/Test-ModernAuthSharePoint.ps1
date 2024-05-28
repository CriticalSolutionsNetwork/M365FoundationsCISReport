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
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.10"
        $auditResult.CISDescription = "Encrypt Sensitive Data in Transit"
        $auditResult.Rec = "7.2.1"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Modern Authentication for SharePoint Applications"
        $auditResult.Result = $modernAuthForSPRequired
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if ($modernAuthForSPRequired) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
