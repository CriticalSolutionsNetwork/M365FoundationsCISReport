function Test-RestrictExternalSharing {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {
        # Initialization code

        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 7.2.3 (L1) Ensure external content sharing is restricted
        $SPOTenantSharingCapability = Get-SPOTenant | Select-Object SharingCapability
        $isRestricted = $SPOTenantSharingCapability.SharingCapability -in @('ExternalUserSharingOnly', 'ExistingExternalUserSharingOnly', 'Disabled')

        # Populate the auditResult object with the required properties
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"

        $auditResult.Rec = "7.2.3"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Ensure external content sharing is restricted"

        $auditResult.Result = $isRestricted
        $auditResult.Details = "SharingCapability: $($SPOTenantSharingCapability.SharingCapability)"
        $auditResult.FailureReason = if (-not $isRestricted) { "External content sharing is not adequately restricted. Current setting: $($SPOTenantSharingCapability.SharingCapability)" } else { "N/A" }
        $auditResult.Status = if ($isRestricted) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
