function Test-CustomerLockbox {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {

        $auditResults = @()
    }

    process {
        # 1.3.6 (L2) Ensure the customer lockbox feature is enabled
        $orgConfig = Get-OrganizationConfig | Select-Object CustomerLockBoxEnabled
        $customerLockboxEnabled = $orgConfig.CustomerLockBoxEnabled

        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($customerLockboxEnabled) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E5"
        $auditResult.ProfileLevel = "L2"
        $auditResult.Rec = "1.3.6"
        $auditResult.RecDescription = "Ensure the customer lockbox feature is enabled"
        $auditResult.CISControlVer = 'v8'
        $auditResult.CISControl = "0.0" # As per the snapshot provided, this is explicitly not mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.Result = $customerLockboxEnabled
        $auditResult.Details = "Customer Lockbox Enabled: $customerLockboxEnabled"
        $auditResult.FailureReason = if ($customerLockboxEnabled) { "N/A" } else { "Customer lockbox feature is not enabled." }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
