function Test-AuditLogSearch {
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
        # 3.1.1 (L1) Ensure Microsoft 365 audit log search is Enabled

        # Retrieve the audit log configuration
        $auditLogConfig = Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled
        $auditLogResult = $auditLogConfig.UnifiedAuditLogIngestionEnabled

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $auditLogResult) {
            "Audit log search is not enabled"
        }
        else {
            "N/A"
        }

        $details = if ($auditLogResult) {
            "UnifiedAuditLogIngestionEnabled: True"
        }
        else {
            "UnifiedAuditLogIngestionEnabled: False"
        }

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($auditLogResult) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "3.1.1"
        $auditResult.RecDescription = "Ensure Microsoft 365 audit log search is Enabled"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "8.2"
        $auditResult.CISDescription = "Collect Audit Logs"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $auditLogResult
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
