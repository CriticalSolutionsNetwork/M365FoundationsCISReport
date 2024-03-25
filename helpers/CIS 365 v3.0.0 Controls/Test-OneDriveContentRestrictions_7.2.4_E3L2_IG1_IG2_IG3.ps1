function Test-OneDriveContentRestrictions_7.2.4_E3L2_IG1_IG2_IG3 {
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
        # 7.2.4 (L2) Ensure OneDrive content sharing is restricted
        $SPOTenant = Get-SPOTenant | Select-Object OneDriveSharingCapability
        $isOneDriveSharingRestricted = $SPOTenant.OneDriveSharingCapability -eq 'Disabled'

        # Populate the auditResult object with the required properties
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"

        $auditResult.Rec = "7.2.4"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L2"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Ensure OneDrive content sharing is restricted"

        $auditResult.Result = $isOneDriveSharingRestricted
        $auditResult.Details = "OneDriveSharingCapability: $($SPOTenant.OneDriveSharingCapability)"
        $auditResult.FailureReason = if (-not $isOneDriveSharingRestricted) { "OneDrive content sharing is not restricted to 'Disabled'. Current setting: $($SPOTenant.OneDriveSharingCapability)" } else { "N/A" }
        $auditResult.Status = if ($isOneDriveSharingRestricted) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
