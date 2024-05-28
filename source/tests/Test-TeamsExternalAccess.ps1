function Test-TeamsExternalAccess {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed

        $auditResult = [CISAuditResult]::new()
    }

    process {
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
            Rec            = "8.2.1"
            Result         = $isCompliant
            Status         = if ($isCompliant) { "Pass" } else { "Fail" }
            Details        = "AllowTeamsConsumer: $($externalAccessConfig.AllowTeamsConsumer); AllowPublicUsers: $($externalAccessConfig.AllowPublicUsers); AllowFederatedUsers: $($externalAccessConfig.AllowFederatedUsers); AllowedDomains limited: $allowedDomainsLimited"
            FailureReason  = if (-not $isCompliant) { "One or more external access configurations are not compliant." } else { "N/A" }
            RecDescription = "Ensure 'external access' is restricted in the Teams admin center"
            CISControl     = "0.0"
            CISDescription = "Explicitly Not Mapped"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
