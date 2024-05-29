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
        $params = @{
            Rec            = "7.2.3"
            Result         = $isRestricted
            Status         = if ($isRestricted) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
