function Test-AuditDisabledFalse {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 6.1.1 (L1) Ensure 'AuditDisabled' organizationally is set to 'False'
        # Pass if AuditDisabled is False. Fail otherwise.
        $auditDisabledConfig = Get-OrganizationConfig | Select-Object AuditDisabled
        $auditNotDisabled = -not $auditDisabledConfig.AuditDisabled

        # Create an instance of CISAuditResult and populate it
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
        $auditResult.Details = if ($auditNotDisabled) { "Audit is not disabled organizationally" } else { "Audit is disabled organizationally" }
        $auditResult.FailureReason = if (-not $auditNotDisabled) { "AuditDisabled is set to True" } else { "N/A" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
