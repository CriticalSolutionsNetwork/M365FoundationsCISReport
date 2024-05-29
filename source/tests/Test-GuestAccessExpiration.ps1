function Test-GuestAccessExpiration {
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
        # 7.2.9 (L1) Ensure guest access to a site or OneDrive will expire automatically

        # Retrieve SharePoint tenant settings related to guest access expiration
        $SPOTenantGuestAccess = Get-SPOTenant | Select-Object ExternalUserExpirationRequired, ExternalUserExpireInDays
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
            Rec            = "7.2.9"
            Result         = $isGuestAccessExpirationConfiguredCorrectly
            Status         = if ($isGuestAccessExpirationConfiguredCorrectly) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
