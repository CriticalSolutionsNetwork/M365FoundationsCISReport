function Test-NoWhitelistDomains {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "6.2.2"
    }

    process {
        try {
            # 6.2.2 (L1) Ensure mail transport rules do not whitelist specific domains

            # Retrieve transport rules that whitelist specific domains
            $whitelistedRules = Get-TransportRule | Where-Object { $_.SetSCL -eq -1 -and $null -ne $_.SenderDomainIs }

            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($whitelistedRules) {
                "There are transport rules whitelisting specific domains."
            }
            else {
                "N/A"
            }

            $details = if ($whitelistedRules) {
                $ruleDetails = $whitelistedRules | ForEach-Object { "{0}: {1}" -f $_.Name, ($_.SenderDomainIs -join ', ') }
                "Whitelisted Rules: $($ruleDetails -join '; ')"
            }
            else {
                "No transport rules whitelisting specific domains found."
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = -not $whitelistedRules
                Status        = if ($whitelistedRules) { "Fail" } else { "Pass" }
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
