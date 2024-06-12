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

        <#
        Conditions for 6.2.2 (L1) Ensure mail transport rules do not whitelist specific domains (Automated)

        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
          - Condition A: No mail transport rules whitelist any specific domains.
          - Condition B: Verification of mail transport rules using PowerShell shows no domains are whitelisted.
          - Condition C: Manual review in Exchange Online admin center confirms no whitelisted domains in transport rules.

        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
          - Condition A: One or more mail transport rules whitelist specific domains.
          - Condition B: Verification of mail transport rules using PowerShell shows one or more domains are whitelisted.
          - Condition C: Manual review in Exchange Online admin center shows whitelisted domains in transport rules.
        #>
    }

    process {
        try {
            # 6.2.2 (L1) Ensure mail transport rules do not whitelist specific domains

            # Retrieve transport rules that whitelist specific domains
            # Condition A: Checking for transport rules that whitelist specific domains
            $whitelistedRules = Get-TransportRule | Where-Object { $_.SetSCL -eq -1 -and $null -ne $_.SenderDomainIs }

            # Prepare failure reasons and details based on compliance
            # Condition B: Prepare failure reasons based on the presence of whitelisted rules
            $failureReasons = if ($whitelistedRules) {
                "There are transport rules whitelisting specific domains."
            }
            else {
                "N/A"
            }

            # Condition C: Prepare details about the whitelisted rules if found
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
