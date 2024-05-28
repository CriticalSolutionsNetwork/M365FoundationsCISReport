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
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"  # Explicitly Not Mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "7.2.9"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.RecDescription = "Ensure guest access to a site or OneDrive will expire automatically"
        $auditResult.Result = $isGuestAccessExpirationConfiguredCorrectly
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if ($isGuestAccessExpirationConfiguredCorrectly) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
