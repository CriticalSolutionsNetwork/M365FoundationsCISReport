function Test-EnableDKIM {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 2.1.9 (L1) Ensure DKIM is enabled for all Exchange Online Domains
        # Pass if Enabled is True for all domains. Fail if any domain has Enabled set to False.
        $dkimConfig = Get-DkimSigningConfig | Select-Object Domain, Enabled
        $dkimResult = ($dkimConfig | ForEach-Object { $_.Enabled }) -notcontains $false
        $dkimFailedDomains = $dkimConfig | Where-Object { -not $_.Enabled } | ForEach-Object { $_.Domain }

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($dkimResult) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "2.1.9"
        $auditResult.RecDescription = "Ensure that DKIM is enabled for all Exchange Online Domains"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "9.5"
        $auditResult.CISDescription = "Implement DMARC"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $dkimResult
        $auditResult.Details = if (-not $dkimResult) { "DKIM not enabled for: $($dkimFailedDomains -join ', ')" } else { "All domains have DKIM enabled" }
        $auditResult.FailureReason = if (-not $dkimResult) { "DKIM is not enabled for some domains" } else { "N/A" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}