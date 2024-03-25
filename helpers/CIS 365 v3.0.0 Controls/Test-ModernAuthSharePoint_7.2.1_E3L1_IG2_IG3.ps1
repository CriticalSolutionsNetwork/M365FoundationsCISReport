function Test-ModernAuthSharePoint_7.2.1_E3L1_IG2_IG3 {
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
        # 7.2.1 (L1) Ensure modern authentication for SharePoint applications is required
        $SPOTenant = Get-SPOTenant | Select-Object -Property LegacyAuthProtocolsEnabled
        $modernAuthForSPRequired = -not $SPOTenant.LegacyAuthProtocolsEnabled

        # Populate the auditResult object with the required properties
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.10"
        $auditResult.CISDescription = "Encrypt Sensitive Data in Transit"
        $auditResult.Rec = "7.2.1"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L1"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Modern Authentication for SharePoint Applications"
        $auditResult.Result = $modernAuthForSPRequired
        $auditResult.Details = "LegacyAuthProtocolsEnabled: $($SPOTenant.LegacyAuthProtocolsEnabled)"
        $auditResult.FailureReason = if (-not $modernAuthForSPRequired) { "Legacy authentication protocols are enabled" } else { "N/A" }
        $auditResult.Status = if ($modernAuthForSPRequired) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
