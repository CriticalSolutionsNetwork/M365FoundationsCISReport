function Test-PasswordHashSync {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 5.1.8.1 (L1) Ensure password hash sync is enabled for hybrid deployments
        # Pass if OnPremisesSyncEnabled is True. Fail otherwise.
        $passwordHashSync = Get-MgOrganization | Select-Object OnPremisesSyncEnabled
        $hashSyncResult = $passwordHashSync.OnPremisesSyncEnabled

        # Create an instance of CISAuditResult and populate it
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
        $auditResult.Details = "OnPremisesSyncEnabled: $($passwordHashSync.OnPremisesSyncEnabled)"
        $auditResult.FailureReason = if (-not $hashSyncResult) { "Password hash sync for hybrid deployments is not enabled" } else { "N/A" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
