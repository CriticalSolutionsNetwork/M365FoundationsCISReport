function Test-TeamsExternalAccess {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        [Parameter(Mandatory = $false, HelpMessage = "Specifies the approved federated domains for the audit. Accepts an array of allowed domain names.")]
        [string[]]$ApprovedFederatedDomains
    )
    begin {
        # Dot source the class script if necessary
        # . .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "8.2.1"
        Write-Verbose "Running Test-TeamsExternalAccess for $recnum..."
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
            # Connect to Teams PowerShell using Connect-MicrosoftTeams
            # $externalAccessConfig Mock Object
            <#
                $externalAccessConfig = [PSCustomObject]@{
                    Identity                                    = 'Global'
                    AllowedDomains                              = 'AllowAllKnownDomains'
                    BlockedDomains                              = @()
                    AllowFederatedUsers                         = $true
                    AllowPublicUsers                            = $true
                    AllowTeamsConsumer                          = $true
                    AllowTeamsConsumerInbound                   = $true
                }
                $ApprovedFederatedDomains = @('msn.com', 'google.com')
                $externalAccessConfig = [PSCustomObject]@{
                    Identity                                    = 'Global'
                    AllowedDomains                              = @('msn.com', 'google.com')
                    BlockedDomains                              = @()
                    AllowFederatedUsers                         = $true
                    AllowPublicUsers                            = $false
                    AllowTeamsConsumer                          = $false
                    AllowTeamsConsumerInbound                   = $true
                }
            #>
            $externalAccessConfig = Get-CISMSTeamsOutput -Rec $recnum
            # Testing
            #$externalAccessConfig.AllowedDomains = @("msn.com", "google.com")
            #$externalAccessConfig.AllowTeamsConsumer = $false
            #$externalAccessConfig.AllowPublicUsers = $false
            #$externalAccessConfig.AllowFederatedUsers = $true
            # The above is for testing and will be replaced with the actual values from the Teams PowerShell output in production.
            $allowedDomainsLimited = $false
            $allowedDomainsMatch = $false
            $invalidDomains = @()
            if ($externalAccessConfig.AllowFederatedUsers) {
                if ($externalAccessConfig.AllowedDomains -ne 'AllowAllKnownDomains' -and $externalAccessConfig.AllowedDomains.Count -gt 0) {
                    $allowedDomainsLimited = $true
                    if ($ApprovedFederatedDomains) {
                        $invalidDomains = $externalAccessConfig.AllowedDomains | Where-Object { $_ -notin $ApprovedFederatedDomains }
                        if ($invalidDomains.Count -eq 0) {
                            $invalidDomains = "None"
                        }
                        $allowedDomainsMatch = $invalidDomains.Count -eq 0
                    }
                }
            }
            # Check if the configurations are as recommended
            $isCompliant = -not $externalAccessConfig.AllowTeamsConsumer -and -not $externalAccessConfig.AllowPublicUsers -and (-not $externalAccessConfig.AllowFederatedUsers -or ($allowedDomainsLimited -and $allowedDomainsMatch))
            # Create an instance of CISAuditResult and populate it
            $params = @{
                Rec           = $recnum
                Result        = $isCompliant
                Status        = if ($isCompliant) { "Pass" } else { "Fail" }
                Details       = "AllowTeamsConsumer: $($externalAccessConfig.AllowTeamsConsumer); AllowPublicUsers: $($externalAccessConfig.AllowPublicUsers); AllowFederatedUsers: $($externalAccessConfig.AllowFederatedUsers); AllowedDomains limited: $allowedDomainsLimited; AllowedDomains match: $allowedDomainsMatch; Invalid Domains: $($invalidDomains -join ', ')"
                FailureReason = if (-not $isCompliant) { "One or more external access configurations are not compliant. Invalid domains found: $($invalidDomains -join ', ')" } else { "N/A" }
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }
    end {
        # Return auditResult
        return $auditResult
    }
}
