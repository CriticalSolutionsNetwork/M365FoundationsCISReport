function Test-DisallowInfectedFilesDownload {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "7.3.1"
    }

    process {

        try {
            # 7.3.1 (L2) Ensure Office 365 SharePoint infected files are disallowed for download
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `DisallowInfectedFileDownload` setting is set to `True`.
            #   - Condition B: The setting prevents users from downloading infected files as detected by Defender for Office 365.
            #   - Condition C: Verification using the PowerShell command confirms that the setting is correctly configured.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `DisallowInfectedFileDownload` setting is not set to `True`.
            #   - Condition B: The setting does not prevent users from downloading infected files.
            #   - Condition C: Verification using the PowerShell command indicates that the setting is incorrectly configured.

            # Retrieve the SharePoint tenant configuration
            $SPOTenantDisallowInfectedFileDownload = Get-CISSpoOutput -Rec $recnum

            # Condition A: The `DisallowInfectedFileDownload` setting is set to `True`
            $isDisallowInfectedFileDownloadEnabled = $SPOTenantDisallowInfectedFileDownload.DisallowInfectedFileDownload

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $isDisallowInfectedFileDownloadEnabled) {
                "Downloading infected files is not disallowed."  # Condition B: The setting does not prevent users from downloading infected files
            }
            else {
                "N/A"
            }

            $details = if ($isDisallowInfectedFileDownloadEnabled) {
                "DisallowInfectedFileDownload: True"  # Condition C: Verification confirms the setting is correctly configured
            }
            else {
                "DisallowInfectedFileDownload: False"  # Condition C: Verification indicates the setting is incorrectly configured
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $isDisallowInfectedFileDownloadEnabled
                Status        = if ($isDisallowInfectedFileDownloadEnabled) { "Pass" } else { "Fail" }
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
