function Test-CustomerLockbox {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary

        # Initialization code, if needed
    }

    process {
        # 1.3.6 (L2) Ensure the customer lockbox feature is enabled

        # Retrieve the organization configuration
        $orgConfig = Get-OrganizationConfig | Select-Object CustomerLockBoxEnabled
        $customerLockboxEnabled = $orgConfig.CustomerLockBoxEnabled

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $customerLockboxEnabled) {
            "Customer lockbox feature is not enabled."
        }
        else {
            "N/A"
        }

        $details = if ($customerLockboxEnabled) {
            "Customer Lockbox Enabled: True"
        }
        else {
            "Customer Lockbox Enabled: False"
        }

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($customerLockboxEnabled) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E5"
        $auditResult.ProfileLevel = "L2"
        $auditResult.Rec = "1.3.6"
        $auditResult.RecDescription = "Ensure the customer lockbox feature is enabled"
        $auditResult.CISControlVer = 'v8'
        $auditResult.CISControl = "0.0"  # As per the snapshot provided, this is explicitly not mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.Result = $customerLockboxEnabled
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
