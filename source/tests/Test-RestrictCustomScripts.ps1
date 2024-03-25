function Test-RestrictCustomScripts {
    [CmdletBinding()]
    param (
        # Define your parameters here if needed
    )
#Limit All
    begin {
        # .TODO Test behavior in Prod
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # CIS 2.7 Ensure custom script execution is restricted on site collections
        # Pass if DenyAddAndCustomizePages is set to true (Enabled). Fail otherwise.

        # Get all site collections and select necessary properties
        $SPOSitesCustomScript = Get-SPOSite -Limit All | Select-Object Title, Url, DenyAddAndCustomizePages

        # Find sites where custom scripts are allowed (DenyAddAndCustomizePages is not 'Enabled')
        $customScriptAllowedSites = $SPOSitesCustomScript | Where-Object { $_.DenyAddAndCustomizePages -ne 'Enabled' }

        # Compliance is true if no sites allow custom scripts
        $complianceResult = $customScriptAllowedSites.Count -eq 0

        # Gather details for non-compliant sites (where custom scripts are allowed)
        $nonCompliantSiteDetails = $customScriptAllowedSites | ForEach-Object {
            "$($_.Title) ($($_.Url)): Custom Script Allowed"
        }

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "2.7"
        $auditResult.CISDescription = "Allowlist Authorized Scripts"
        $auditResult.Rec = "7.3.4"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Ensure custom script execution is restricted on site collections"
        $auditResult.Result = $complianceResult
        $auditResult.Details = if (-not $complianceResult) {
            $nonCompliantSiteDetails -join "; "
        } else {
            "All site collections have custom script execution restricted"
        }
        $auditResult.FailureReason = if (-not $complianceResult) {
            "The following site collections allow custom script execution: " + ($nonCompliantSiteDetails -join "; ")
        } else {
            "N/A"
        }
        $auditResult.Status = if ($complianceResult) {
            "Pass"
        } else {
            "Fail"
        }

        $auditResults += $auditResult
    }



    end {
        # Return auditResults
        return $auditResults
    }
}
