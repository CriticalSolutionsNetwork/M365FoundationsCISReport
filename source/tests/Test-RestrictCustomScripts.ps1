function Test-RestrictCustomScripts {
    [CmdletBinding()]
    param (
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        # . .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "7.3.4"
    }

    process {

        try {
            # 7.3.4 (L1) Ensure custom script execution is restricted on site collections

            # Retrieve all site collections and select necessary properties
            $SPOSitesCustomScript = Get-SPOSite -Limit All | Select-Object Title, Url, DenyAddAndCustomizePages

            # Replace 'sharepoint.com' with '<sptld>'
            $processedUrls = $SPOSitesCustomScript | ForEach-Object {
                $_.Url = $_.Url -replace 'sharepoint\.com', '<sptld>'
                $_
            }

            # Extract hostnames and find the most used one
            $hostnames = $processedUrls.Url | ForEach-Object { $_ -match '^https://([^\.]+)\.' | Out-Null; $matches[1] }
            $mostUsedHostname = $hostnames | Group-Object | Sort-Object Count -Descending | Select-Object -First 1 -ExpandProperty Name

            # Compliance is true if no sites allow custom scripts
            $customScriptAllowedSites = $processedUrls | Where-Object { $_.DenyAddAndCustomizePages -ne 'Enabled' }
            $complianceResult = $customScriptAllowedSites.Count -eq 0

            # Gather details for non-compliant sites (where custom scripts are allowed)
            $nonCompliantSiteDetails = $customScriptAllowedSites | ForEach-Object {
                $url = $_.Url -replace [regex]::Escape($mostUsedHostname), "<corp>"
                "$(if ($_.Title) {$_.Title} else {"NoTitle"})|$url|$true"
            }

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $complianceResult) {
                "Title|Url|CustomScriptAllowed`n" + ($nonCompliantSiteDetails -join "`n")
            }
            else {
                "N/A"
            }

            $details = if ($complianceResult) {
                "All site collections have custom script execution restricted"
            }
            else {
                "Some site collections are not restricting custom script execution. Review FailureReason property for sites that are not aligned with the benchmark."
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec            = $recnum
                Result         = $complianceResult
                Status         = if ($complianceResult) { "Pass" } else { "Fail" }
                Details        = $details
                FailureReason  = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            Write-Error "An error occurred during the test: $_"

            # Retrieve the description from the test definitions
            $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
            $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }

            $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
