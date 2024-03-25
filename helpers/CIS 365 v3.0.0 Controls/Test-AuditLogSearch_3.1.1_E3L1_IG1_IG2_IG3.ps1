function Test-AuditLogSearch_3.1.1_E3L1_IG1_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResults = @()
    }

    process {
        # 3.1.1 (L1) Ensure Microsoft 365 audit log search is Enabled
        # Pass if UnifiedAuditLogIngestionEnabled is True. Fail otherwise.
        $auditLogConfig = Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled
        $auditLogResult = $auditLogConfig.UnifiedAuditLogIngestionEnabled

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($auditLogResult) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L1"
        $auditResult.Rec = "3.1.1"
        $auditResult.RecDescription = "Ensure Microsoft 365 audit log search is Enabled"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "8.2"
        $auditResult.CISDescription = "Collect Audit Logs"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $auditLogResult
        $auditResult.Details = "UnifiedAuditLogIngestionEnabled: $($auditLogConfig.UnifiedAuditLogIngestionEnabled)"
        $auditResult.FailureReason = if (-not $auditLogResult) { "Audit log search is not enabled" } else { "N/A" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
