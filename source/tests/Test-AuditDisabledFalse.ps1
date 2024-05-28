function Test-AuditDisabledFalse {
    [CmdletBinding()]
    # Aligned
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
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
        $params = @{
            Rec            = "6.1.1"
            Result         = $auditNotDisabled
            Status         = if ($auditNotDisabled) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure 'AuditDisabled' organizationally is set to 'False'"
            CISControl     = "8.2"
            CISDescription = "Collect Audit Logs"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
