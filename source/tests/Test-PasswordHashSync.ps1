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
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($hashSyncResult) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "5.1.8.1"
        $auditResult.RecDescription = "Ensure password hash sync is enabled for hybrid deployments"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "6.7"
        $auditResult.CISDescription = "Centralize Access Control"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $hashSyncResult
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
