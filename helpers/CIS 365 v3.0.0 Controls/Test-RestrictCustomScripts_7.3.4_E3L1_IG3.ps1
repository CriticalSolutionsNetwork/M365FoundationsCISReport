function Test-RestrictCustomScripts_7.3.4_E3L1_IG3 {
    [CmdletBinding()]
    param (
        # Define your parameters here if needed
    )

    begin {
        # .TODO Test behavior in Prod
        # Dot source the class script
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResults = @()
    }

    process {
        # CIS 2.7 Ensure custom script execution is restricted on site collections
        # Pass if DenyAddAndCustomizePages is set to true. Fail otherwise.

        # Connect to SharePoint Online using Connect-SPOService

        $SPOSitesCustomScript = Get-SPOSite | Select-Object Title, Url, DenyAddAndCustomizePages
        $customScriptDisabledSites = $SPOSitesCustomScript | Where-Object { $_.DenyAddAndCustomizePages -eq 'Enabled' }
        $customScriptEnabledSites = $SPOSitesCustomScript | Where-Object { $_.DenyAddAndCustomizePages -ne 'Enabled' }
        $customScriptDisabledResult = $customScriptEnabledSites.Count -eq 0

        # Correctly gathering details for sites with custom scripts enabled
        $customScriptEnabledDetails = $customScriptEnabledSites | ForEach-Object { "$($_.Title) ($($_.Url)): Custom Script - $($_.DenyAddAndCustomizePages)" }

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "2.7"
        $auditResult.CISDescription = "Allowlist Authorized Scripts"
        $auditResult.Rec = "7.3.4"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L1"
        $auditResult.IG1 = $false # Set based on the benchmark
        $auditResult.IG2 = $false # Set based on the benchmark
        $auditResult.IG3 = $true # Set based on the benchmark
        $auditResult.RecDescription = "Ensure custom script execution is restricted on site collections"
        $auditResult.Result = $customScriptDisabledResult
        $auditResult.Details = if (-not $customScriptDisabledResult) { $customScriptEnabledDetails -join "; " } else { "All site collections have custom script execution restricted" }
        $auditResult.FailureReason = if (-not $customScriptDisabledResult) { "The following site collections have custom script execution enabled: " + ($customScriptEnabledDetails -join "; ") } else { "N/A" }
        $auditResult.Status = if ($customScriptDisabledResult) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
