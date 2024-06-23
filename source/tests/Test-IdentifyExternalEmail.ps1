function Test-IdentifyExternalEmail {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "6.2.3"

        # Conditions for 6.2.3 (L1) Ensure email from external senders is identified
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: External tagging is enabled using PowerShell for all identities.
        #   - Condition B: The BypassAllowList only contains email addresses the organization has permitted to bypass external tagging.
        #   - Condition C: External sender tag appears in email messages received from external sources.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: External tagging is not enabled using PowerShell for all identities.
        #   - Condition B: The BypassAllowList contains unauthorized email addresses.
        #   - Condition C: External sender tag does not appear in email messages received from external sources.
    }

    process {

        try {
            # 6.2.3 (L1) Ensure email from external senders is identified

            # Retrieve external sender tagging configuration
            $externalInOutlook = Get-CISExoOutput -Rec $recnum
            $externalTaggingEnabled = ($externalInOutlook | ForEach-Object { $_.Enabled }) -contains $true

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $externalTaggingEnabled) {
                # Condition A: External tagging is not enabled using PowerShell for all identities.
                "External sender tagging is disabled"
            }
            else {
                "N/A"
            }

            # Details for external tagging configuration
            $details = "Enabled: $($externalTaggingEnabled); AllowList: $($externalInOutlook.AllowList)"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $externalTaggingEnabled
                Status        = if ($externalTaggingEnabled) { "Pass" } else { "Fail" }
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
