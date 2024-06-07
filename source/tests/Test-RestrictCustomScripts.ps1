function Test-RestrictCustomScripts {
    [CmdletBinding()]
    param (
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "7.3.4"
    }

    process {
        try {
            # 7.3.4 (L1) Ensure custom script execution is restricted on site collections

            # Retrieve all site collections and select necessary properties
            $SPOSitesCustomScript = Get-SPOSite -Limit All | Select-Object Title, Url, DenyAddAndCustomizePages

            # Find sites where custom scripts are allowed (DenyAddAndCustomizePages is not 'Enabled')
            $customScriptAllowedSites = $SPOSitesCustomScript | Where-Object { $_.DenyAddAndCustomizePages -ne 'Enabled' }

            # Compliance is true if no sites allow custom scripts
            $complianceResult = $customScriptAllowedSites.Count -eq 0

            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($complianceResult) {
                "N/A"
            } else {
                "The following site collections allow custom script execution:"
            }

            $details = if ($complianceResult) {
                "All site collections have custom script execution restricted"
            } else {
                # Create pipe-separated table for non-compliant sites
                $nonCompliantSiteDetails = $customScriptAllowedSites | ForEach-Object {
                    $title = if ($_.Title) { $_.Title } else { "No Title" }
                    "$title|$($_.Url)|True"
                }
                "Title|Url|CustomScriptAllowed`n" + ($nonCompliantSiteDetails -join "`n")
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $complianceResult
                Status        = if ($complianceResult) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
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
