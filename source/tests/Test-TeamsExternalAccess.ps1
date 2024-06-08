function Test-TeamsExternalAccess {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed

        $auditResult = [CISAuditResult]::new()
        $recnum = "8.2.1"
    }

    process {
        try {
            # 8.2.1 (L1) Ensure 'external access' is restricted in the Teams admin center

            # Connect to Teams PowerShell using Connect-MicrosoftTeams

            $externalAccessConfig = Get-CsTenantFederationConfiguration

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
