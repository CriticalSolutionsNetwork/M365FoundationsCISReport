function Test-OneDriveContentRestrictions {
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
        # 7.2.4 (L2) Ensure OneDrive content sharing is restricted

        # Retrieve OneDrive sharing capability settings
        $SPOTenant = Get-SPOTenant | Select-Object OneDriveSharingCapability
        $isOneDriveSharingRestricted = $SPOTenant.OneDriveSharingCapability -eq 'Disabled'

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $isOneDriveSharingRestricted) {
            "OneDrive content sharing is not restricted to 'Disabled'. Current setting: $($SPOTenant.OneDriveSharingCapability)"
        }
        else {
            "N/A"
        }

        $details = if ($isOneDriveSharingRestricted) {
            "OneDrive content sharing is restricted."
        }
        else {
            "OneDriveSharingCapability: $($SPOTenant.OneDriveSharingCapability)"
        }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "7.2.4"
            Result         = $isOneDriveSharingRestricted
            Status         = if ($isOneDriveSharingRestricted) { "Pass" } else { "Fail" }
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
