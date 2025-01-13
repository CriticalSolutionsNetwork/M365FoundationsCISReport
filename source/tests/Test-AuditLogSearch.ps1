function Test-AuditLogSearch {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added if needed
    )
    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $RecNum = "3.1.1"
        Write-Verbose "Running Test-AuditLogSearch for $RecNum..."
        <#
        Conditions for 3.1.1 (L1) Ensure Microsoft 365 audit log search is Enabled
        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
            - Condition A: Audit log search is enabled in the Microsoft Purview compliance portal.
            - Condition B: The audit log retains user and admin activity for 90 days.
            - Condition C: Audit log search capabilities are functional (search results are displayed for activities within the past 30 days).
        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
            - Condition A: Audit log search is not enabled in the Microsoft Purview compliance portal.
            - Condition B: The audit log does not retain user and admin activity for 90 days.
            - Condition C: Audit log search capabilities are non-functional (no search results are displayed for activities within the past 30 days).
        #>
    }
    process {
        try {
            # 3.1.1 (L1) Ensure Microsoft 365 audit log search is Enabled
            $auditLogResult = Get-CISExoOutput -Rec $RecNum
            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $auditLogResult) {
                # Condition A (Fail): Audit log search is not enabled in the Microsoft Purview compliance portal
                "Audit log search is not enabled"
            }
            else {
                "N/A"
            }
            $details = if ($auditLogResult) {
                # Condition A (Pass): Audit log search is enabled in the Microsoft Purview compliance portal
                "UnifiedAuditLogIngestionEnabled: True"
            }
            else {
                "UnifiedAuditLogIngestionEnabled: False"
            }
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $RecNum
                Result        = $auditLogResult
                Status        = if ($auditLogResult) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -RecNum $RecNum
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}