function Test-RestrictExternalSharing {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 7.2.3 (L1) Ensure external content sharing is restricted

        # Retrieve the SharingCapability setting for the SharePoint tenant
        $SPOTenantSharingCapability = Get-SPOTenant | Select-Object SharingCapability
        $isRestricted = $SPOTenantSharingCapability.SharingCapability -in @('ExternalUserSharingOnly', 'ExistingExternalUserSharingOnly', 'Disabled')

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $isRestricted) {
            "External content sharing is not adequately restricted. Current setting: $($SPOTenantSharingCapability.SharingCapability)"
        }
        else {
            "N/A"
        }

        $details = "SharingCapability: $($SPOTenantSharingCapability.SharingCapability)"

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($isRestricted) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "7.2.3"
        $auditResult.RecDescription = "Ensure external content sharing is restricted"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $isRestricted
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
