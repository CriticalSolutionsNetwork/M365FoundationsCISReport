function Test-EnableDKIM {
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
        $recnum = "2.1.9"

        <#
        Conditions for 2.1.9 (L1) Ensure DKIM is enabled for all Exchange Online Domains (Automated)

        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
          - Condition A: DKIM is enabled for all Exchange Online domains in the Microsoft 365 security center.
          - Condition B: Using the Exchange Online PowerShell Module, the `CnameConfiguration.Enabled` property for each domain is set to `True`.

        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
          - Condition A: DKIM is not enabled for one or more Exchange Online domains in the Microsoft 365 security center.
          - Condition B: Using the Exchange Online PowerShell Module, the `CnameConfiguration.Enabled` property for one or more domains is set to `False`.
        #>
    }

    process {

        try {
            # 2.1.9 (L1) Ensure DKIM is enabled for all Exchange Online Domains

            # Retrieve DKIM configuration for all domains
            $dkimConfig = Get-CISExoOutput -Rec $recnum
            $dkimResult = ($dkimConfig | ForEach-Object { $_.Enabled }) -notcontains $false
            $dkimFailedDomains = $dkimConfig | Where-Object { -not $_.Enabled } | ForEach-Object { $_.Domain }

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $dkimResult) {
                "DKIM is not enabled for some domains"  # Condition A fail
            }
            else {
                "N/A"
            }

            $details = if ($dkimResult) {
                "All domains have DKIM enabled"  # Condition A pass
            }
            else {
                "DKIM not enabled for: $($dkimFailedDomains -join ', ')"  # Condition B fail
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec            = $recnum
                Result         = $dkimResult
                Status         = if ($dkimResult) { "Pass" } else { "Fail" }
                Details        = $details
                FailureReason  = $failureReasons
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
