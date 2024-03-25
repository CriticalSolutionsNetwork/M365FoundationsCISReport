function Test-GuestAccessExpiration {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {
        # Initialization code

        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 7.2.9 (L1) Ensure guest access to a site or OneDrive will expire automatically
        $SPOTenantGuestAccess = Get-SPOTenant | Select-Object ExternalUserExpirationRequired, ExternalUserExpireInDays
        $isGuestAccessExpirationConfiguredCorrectly = $SPOTenantGuestAccess.ExternalUserExpirationRequired -and $SPOTenantGuestAccess.ExternalUserExpireInDays -le 30

        # Populate the auditResult object with the required properties
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"
        $auditResult.CISDescription = "Explicitly Not Mapped"

        $auditResult.Rec = "7.2.9"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.RecDescription = "Ensure guest access to a site or OneDrive will expire automatically"

        $auditResult.Result = $isGuestAccessExpirationConfiguredCorrectly
        $auditResult.Details = "ExternalUserExpirationRequired: $($SPOTenantGuestAccess.ExternalUserExpirationRequired); ExternalUserExpireInDays: $($SPOTenantGuestAccess.ExternalUserExpireInDays)"
        $auditResult.FailureReason = if (-not $isGuestAccessExpirationConfiguredCorrectly) { "Guest access expiration is not configured to automatically expire within 30 days or less." } else { "N/A" }
        $auditResult.Status = if ($isGuestAccessExpirationConfiguredCorrectly) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
