function Test-GuestAccessExpiration {
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
        $recnum = "7.2.9"
    }

    process {

        try {
            # 7.2.9 (L1) Ensure guest access to a site or OneDrive will expire automatically
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The ExternalUserExpirationRequired setting in SharePoint is set to True.
            #   - Condition B: The ExternalUserExpireInDays setting in SharePoint is configured to 30 or less.
            #   - Condition C: Verification using the SharePoint Admin Center confirms that guest access will expire automatically after the specified number of days.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The ExternalUserExpirationRequired setting in SharePoint is not set to True.
            #   - Condition B: The ExternalUserExpireInDays setting in SharePoint is configured to more than 30 days.
            #   - Condition C: Verification using the SharePoint Admin Center indicates that guest access is not set to expire automatically after the specified number of days.

            # Retrieve SharePoint tenant settings related to guest access expiration
            $SPOTenantGuestAccess = Get-CISSpoOutput -Rec $recnum
            $isGuestAccessExpirationConfiguredCorrectly = $SPOTenantGuestAccess.ExternalUserExpirationRequired -and $SPOTenantGuestAccess.ExternalUserExpireInDays -le 30

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $isGuestAccessExpirationConfiguredCorrectly) {
                "Guest access expiration is not configured to automatically expire within 30 days or less."
            }
            else {
                "N/A"
            }

            $details = "ExternalUserExpirationRequired: $($SPOTenantGuestAccess.ExternalUserExpirationRequired); ExternalUserExpireInDays: $($SPOTenantGuestAccess.ExternalUserExpireInDays)"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec            = $recnum
                Result         = $isGuestAccessExpirationConfiguredCorrectly
                Status         = if ($isGuestAccessExpirationConfiguredCorrectly) { "Pass" } else { "Fail" }
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
