function Test-TeamsExternalAccess {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        # . .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "8.2.1"
    }

    process {
        try {
            # 8.2.1 (L1) Ensure 'external access' is restricted in the Teams admin center
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `AllowTeamsConsumer` setting is `False`.
            #   - Condition B: The `AllowPublicUsers` setting is `False`.
            #   - Condition C: The `AllowFederatedUsers` setting is `False` or, if `True`, the `AllowedDomains` contains only authorized domain names.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `AllowTeamsConsumer` setting is not `False`.
            #   - Condition B: The `AllowPublicUsers` setting is not `False`.
            #   - Condition C: The `AllowFederatedUsers` setting is `True` and the `AllowedDomains` contains unauthorized domain names or is not configured correctly.

            # Connect to Teams PowerShell using Connect-MicrosoftTeams

            $externalAccessConfig = Get-CISMSTeamsOutput -Rec $recnum

            $allowedDomainsLimited = $false
            if ($externalAccessConfig.AllowFederatedUsers -and $externalAccessConfig.AllowedDomains -and $externalAccessConfig.AllowedDomains.AllowedDomain.Count -gt 0) {
                $allowedDomainsLimited = $true
            }

            # Check if the configurations are as recommended
            $isCompliant = -not $externalAccessConfig.AllowTeamsConsumer -and -not $externalAccessConfig.AllowPublicUsers -and (-not $externalAccessConfig.AllowFederatedUsers -or $allowedDomainsLimited)

            # Create an instance of CISAuditResult and populate it
            $params = @{
                Rec           = $recnum
                Result        = $isCompliant
                Status        = if ($isCompliant) { "Pass" } else { "Fail" }
                Details       = "AllowTeamsConsumer: $($externalAccessConfig.AllowTeamsConsumer); AllowPublicUsers: $($externalAccessConfig.AllowPublicUsers); AllowFederatedUsers: $($externalAccessConfig.AllowFederatedUsers); AllowedDomains limited: $allowedDomainsLimited"
                FailureReason = if (-not $isCompliant) { "One or more external access configurations are not compliant." } else { "N/A" }
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
