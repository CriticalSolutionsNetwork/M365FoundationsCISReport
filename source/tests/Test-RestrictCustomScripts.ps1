function Test-RestrictCustomScripts {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
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
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `DenyAddAndCustomizePages` setting is set to `Enabled` for each site collection.
            #   - Condition B: The setting is validated through PowerShell commands ensuring the correct state.
            #   - Condition C: Verification using the SharePoint Admin Center confirms the `DenyAddAndCustomizePages` setting is enforced.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `DenyAddAndCustomizePages` setting is not set to `Enabled` for any site collection.
            #   - Condition B: The setting is not validated through PowerShell commands, indicating misconfiguration.
            #   - Condition C: Verification using the SharePoint Admin Center indicates that the `DenyAddAndCustomizePages` setting is not enforced.

            # Retrieve all site collections and select necessary properties
            $SPOSitesCustomScript = Get-CISSpoOutput -Rec $recnum

            # Process URLs to replace 'sharepoint.com' with '<SPUrl>'
            $processedUrls = $SPOSitesCustomScript | ForEach-Object {
                $_.Url = $_.Url -replace 'sharepoint\.com', '<SPUrl>'
                $_
            }

            # Find sites where custom scripts are allowed
            $customScriptAllowedSites = $processedUrls | Where-Object { $_.DenyAddAndCustomizePages -ne 'Enabled' }
            #$verbosePreference = 'Continue'
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
            #$verbosePreference = 'SilentlyContinue'
            # Compliance is true if no sites allow custom scripts
            $complianceResult = $customScriptAllowedSites.Count -eq 0

            # Gather details for non-compliant sites (where custom scripts are allowed)
            $nonCompliantSiteDetails = $customScriptAllowedSites | ForEach-Object {
                $url = $_.Url
                if ($null -ne $mostUsedHostname -and $url -match "^https://$mostUsedHostname\.<SPUrl>") {
                    $url = $url -replace "^https://$mostUsedHostname\.<SPUrl>", "https://<corp>.<SPUrl>"
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

            # Convert details to PSObject and check length
            $detailsPSObject = $details | ConvertFrom-Csv -Delimiter '|'
            $detailsLength = ($detailsPSObject | ForEach-Object { $_.Url }).Length

            if ($detailsLength -gt 32767) {
                # Create a preview of the first 10 results
                $preview = $detailsPSObject | Select-Object -First 10 | ForEach-Object { "$($_.Title)|$($_.Url)" }
                $details = "The output is too large. Here is a preview of the first 10 results:`n`n" + ($preview -join "`n") + "`n`nPlease run the test with the following commands to get the full details:`n`nGet-SPOSite -Limit All | Where-Object { `$.DenyAddAndCustomizePages -ne 'Enabled' } | Select-Object Title, Url"
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
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }

    end {
        # Measure the character count of the details
        #$verbosePreference = 'Continue'
        $detailsLength = $details.Length
        Write-Verbose "Character count of the details: $detailsLength"

        if ($detailsLength -gt 32767) {
            Write-Verbose "Warning: The character count exceeds the limit for Excel cells."
        }
        #$verbosePreference = 'SilentlyContinue'
        # Return auditResult
        return $auditResult
    }
}
