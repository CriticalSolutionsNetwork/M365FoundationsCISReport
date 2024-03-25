function Test-OneDriveSyncRestrictions_7.3.2_E3L2 {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {
        # Initialization code
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 7.3.2 (L2) Ensure OneDrive sync is restricted for unmanaged devices
        $SPOTenantSyncClientRestriction = Get-SPOTenantSyncClientRestriction | Select-Object TenantRestrictionEnabled, AllowedDomainList
        $isSyncRestricted = $SPOTenantSyncClientRestriction.TenantRestrictionEnabled -and $SPOTenantSyncClientRestriction.AllowedDomainList

        # Populate the auditResult object with the required properties
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"
        $auditResult.CISDescription = "Explicitly Not Mapped"

        $auditResult.Rec = "7.3.2"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L2"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.RecDescription = "Ensure OneDrive sync is restricted for unmanaged devices"

        $auditResult.Result = $isSyncRestricted
        $auditResult.Details = "TenantRestrictionEnabled: $($SPOTenantSyncClientRestriction.TenantRestrictionEnabled); AllowedDomainList: $($SPOTenantSyncClientRestriction.AllowedDomainList -join ', ')"
        $auditResult.FailureReason = if (-not $isSyncRestricted) { "OneDrive sync is not restricted to managed devices. TenantRestrictionEnabled should be True and AllowedDomainList should contain trusted domains GUIDs." } else { "N/A" }
        $auditResult.Status = if ($isSyncRestricted) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
