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

            # Replace 'sharepoint.com' with '<SPtld>'
            $processedUrls = $SPOSitesCustomScript | ForEach-Object {
                $_.Url = $_.Url -replace 'sharepoint\.com', '<SPtld>'
                $_
            }

            # Find sites where custom scripts are allowed
            $customScriptAllowedSites = $processedUrls | Where-Object { $_.DenyAddAndCustomizePages -ne 'Enabled' }
            $verbosePreference = 'Continue'
            # Check the total length of URLs
            $totalUrlLength = ($customScriptAllowedSites.Url -join '').Length
            Write-Verbose "Total length of URLs: $totalUrlLength"

            # Extract hostnames from allowed sites if the total length exceeds the limit
            $mostUsedHostname = $null
            if ($totalUrlLength -gt 20000) {
                Write-Verbose "Extracting hostnames from URLs..."
                $hostnames = $customScriptAllowedSites.Url | ForEach-Object {
                    if ($_ -match '^https://([^\.]+)\.') {
                        $matches[1]
                    }
                }
                Write-Verbose "Extracted hostnames: $($hostnames -join ', ')"

                # Find the most used hostname using the Get-MostCommonWord function
                $mostUsedHostname = Get-MostCommonWord -InputStrings $hostnames
                Write-Verbose "Most used hostname: $mostUsedHostname"
            }
            $verbosePreference = 'SilentlyContinue'
            # Compliance is true if no sites allow custom scripts
            $complianceResult = $customScriptAllowedSites.Count -eq 0

            # Gather details for non-compliant sites (where custom scripts are allowed)
            $nonCompliantSiteDetails = $customScriptAllowedSites | ForEach-Object {
                $url = $_.Url
                if ($null -ne $mostUsedHostname -and $url -match "^https://$mostUsedHostname\.<SPtld>") {
                    $url = $url -replace "^https://$mostUsedHostname\.<SPtld>", "https://<corp>.<SPtld>"
                }
                "$(if ($_.Title) {$_.Title} else {"NoTitle"})|$url"
            }

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $complianceResult) {
                "Some site collections are not restricting custom script execution. Review Details property for sites that are not aligned with the benchmark."
            }
            else {
                "N/A"
            }

            $details = if ($complianceResult) {
                "All site collections have custom script execution restricted"
            }
            else {
                "Title|Url`n" + ($nonCompliantSiteDetails -join "`n")
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
        # Measure the character count of the details
        $verbosePreference = 'Continue'
        $detailsLength = $details.Length
        Write-Verbose "Character count of the details: $detailsLength"

        if ($detailsLength -gt 32767) {
            Write-Verbose "Warning: The character count exceeds the limit for Excel cells."
        }
        $verbosePreference = 'SilentlyContinue'
        # Return auditResult
        return $auditResult
    }
}
