function Test-CustomerLockbox {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
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

        # Create and populate the CISAuditResult object #
        $params = @{
            Rec            = "1.3.6"
            Result         = $customerLockboxEnabled
            Status         = if ($customerLockboxEnabled) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure the customer lockbox feature is enabled"
            CISControl     = "0.0"
            CISDescription = "Explicitly Not Mapped"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
