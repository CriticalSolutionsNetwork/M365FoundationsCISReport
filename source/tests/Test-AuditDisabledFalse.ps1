function Test-AuditDisabledFalse {
    [CmdletBinding()]
    # Aligned
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary

        # Initialization code, if needed
    }

    process {
        # 6.1.1 (L1) Ensure 'AuditDisabled' organizationally is set to 'False'

        # Retrieve the AuditDisabled configuration
        $auditDisabledConfig = Get-OrganizationConfig | Select-Object AuditDisabled
        $auditNotDisabled = -not $auditDisabledConfig.AuditDisabled

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $auditNotDisabled) {
            "AuditDisabled is set to True"
        }
        else {
            "N/A"
        }

        $details = if ($auditNotDisabled) {
            "Audit is not disabled organizationally"
        }
        else {
            "Audit is disabled organizationally"
        }

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($auditNotDisabled) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "6.1.1"
        $auditResult.RecDescription = "Ensure 'AuditDisabled' organizationally is set to 'False'"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "8.2"
        $auditResult.CISDescription = "Collect Audit Logs"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $auditNotDisabled
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
