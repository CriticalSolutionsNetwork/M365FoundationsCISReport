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
        $recnum = "6.1.1"
    }

    process {

        try {
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
                Rec           = $recnum
                Result        = $auditNotDisabled
                Status        = if ($auditNotDisabled) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            Write-Error "An error occurred during the test: $_"
            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
