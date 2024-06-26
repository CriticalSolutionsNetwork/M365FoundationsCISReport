function Test-CommonAttachmentFilter {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added if needed
    )
    begin {
        <#
            Conditions for 2.1.2 (L1) Ensure the Common Attachment Types Filter is enabled
            Validate test for a pass:
            - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            - Specific conditions to check:
                - Condition A: The Common Attachment Types Filter is enabled in the Microsoft 365 Security & Compliance Center.
                - Condition B: Using Exchange Online PowerShell, verify that the `EnableFileFilter` property of the default malware filter policy is set to `True`.
                - Condition C: Ensure that the setting is enabled in the highest priority policy listed if custom policies exist.
            Validate test for a fail:
            - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            - Specific conditions to check:
                - Condition A: The Common Attachment Types Filter is not enabled in the Microsoft 365 Security & Compliance Center.
                - Condition B: Using Exchange Online PowerShell, verify that the `EnableFileFilter` property of the default malware filter policy is set to `False`.
                - Condition C: Ensure that the setting is not enabled in the highest priority policy listed if custom policies exist.
        #>
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "2.1.2"
        Write-Verbose "Running Test-CommonAttachmentFilter for $recnum..."
    }
    process {
        try {
            # 2.1.2 (L1) Ensure the Common Attachment Types Filter is enabled
            # Condition A: The Common Attachment Types Filter is enabled in the Microsoft 365 Security & Compliance Center.
            # Condition B: Using Exchange Online PowerShell, verify that the `EnableFileFilter` property of the default malware filter policy is set to `True`.
            # Retrieve the attachment filter policy
            # $result Mock Object
            # $result = $true
            $result = Get-CISExoOutput -Rec $recnum
            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $result) {
                # Condition A: The Common Attachment Types Filter is not enabled in the Microsoft 365 Security & Compliance Center.
                # Condition B: Using Exchange Online PowerShell, verify that the `EnableFileFilter` property of the default malware filter policy is set to `False`.
                "Common Attachment Types Filter is disabled"
            }
            else {
                "N/A"
            }
            $details = if ($result) {
                "File Filter Enabled: True"
            }
            else {
                "File Filter Enabled: False"
            }
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $result
                Status        = if ($result) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}
