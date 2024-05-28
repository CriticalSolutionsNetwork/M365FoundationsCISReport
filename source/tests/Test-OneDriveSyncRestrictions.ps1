function Test-OneDriveSyncRestrictions {
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
        # 7.3.2 (L2) Ensure OneDrive sync is restricted for unmanaged devices

        # Retrieve OneDrive sync client restriction settings
        $SPOTenantSyncClientRestriction = Get-SPOTenantSyncClientRestriction | Select-Object TenantRestrictionEnabled, AllowedDomainList
        $isSyncRestricted = $SPOTenantSyncClientRestriction.TenantRestrictionEnabled -and $SPOTenantSyncClientRestriction.AllowedDomainList

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $isSyncRestricted) {
            "OneDrive sync is not restricted to managed devices. TenantRestrictionEnabled should be True and AllowedDomainList should contain trusted domains GUIDs."
        }
        else {
            "N/A"
        }

        $details = if ($isSyncRestricted) {
            "OneDrive sync is restricted for unmanaged devices."
        }
        else {
            "TenantRestrictionEnabled: $($SPOTenantSyncClientRestriction.TenantRestrictionEnabled); AllowedDomainList: $($SPOTenantSyncClientRestriction.AllowedDomainList -join ', ')"
        }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "7.3.2"
            Result         = $isSyncRestricted
            Status         = if ($isSyncRestricted) { "Pass" } else { "Fail" }
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
