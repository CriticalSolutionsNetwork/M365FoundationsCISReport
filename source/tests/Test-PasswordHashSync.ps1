function Test-PasswordHashSync {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 5.1.8.1 (L1) Ensure password hash sync is enabled for hybrid deployments
        # Pass if OnPremisesSyncEnabled is True. Fail otherwise.

        # Retrieve password hash sync status
        $passwordHashSync = Get-MgOrganization | Select-Object -ExpandProperty OnPremisesSyncEnabled
        $hashSyncResult = $passwordHashSync

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $hashSyncResult) {
            "Password hash sync for hybrid deployments is not enabled"
        }
        else {
            "N/A"
        }

        $details = "OnPremisesSyncEnabled: $($passwordHashSync)"

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "5.1.8.1"
            Result         = $hashSyncResult
            Status         = if ($hashSyncResult) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure password hash sync is enabled for hybrid deployments"
            CISControl     = "6.7"
            CISDescription = "Centralize Access Control"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
