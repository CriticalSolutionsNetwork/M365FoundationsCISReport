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
        $recnum = "3.1.1"
    }

    process {

        try {
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
            $params = @{
                Rec           = $recnum
                Result        = $auditLogResult
                Status        = if ($auditLogResult) { "Pass" } else { "Fail" }
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
