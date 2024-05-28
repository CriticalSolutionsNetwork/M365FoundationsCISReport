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
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($isOneDriveSharingRestricted) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L2"
        $auditResult.Rec = "7.2.4"
        $auditResult.RecDescription = "Ensure OneDrive content sharing is restricted"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $isOneDriveSharingRestricted
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return auditResult
        return $auditResult
    }
}