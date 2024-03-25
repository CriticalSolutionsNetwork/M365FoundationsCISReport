function Test-TeamsExternalAccess {
    [CmdletBinding()]
    param (
        # Parameters can be defined here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
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
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # The control is Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.2.1"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L2"
        $auditResult.IG1 = $false # Set based on the CIS Controls image
        $auditResult.IG2 = $false # Set based on the CIS Controls image
        $auditResult.IG3 = $false # Set based on the CIS Controls image
        $auditResult.RecDescription = "Ensure 'external access' is restricted in the Teams admin center"
        $auditResult.Result = $isCompliant
        $auditResult.Details = "AllowTeamsConsumer: $($externalAccessConfig.AllowTeamsConsumer); AllowPublicUsers: $($externalAccessConfig.AllowPublicUsers); AllowFederatedUsers: $($externalAccessConfig.AllowFederatedUsers); AllowedDomains limited: $allowedDomainsLimited"
        $auditResult.FailureReason = if (-not $isCompliant) { "One or more external access configurations are not compliant." } else { "N/A" }
        $auditResult.Status = if ($isCompliant) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
