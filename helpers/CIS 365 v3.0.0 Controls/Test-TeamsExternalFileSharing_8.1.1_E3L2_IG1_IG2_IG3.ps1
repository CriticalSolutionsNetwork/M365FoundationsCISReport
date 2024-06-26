function Test-TeamsExternalFileSharing_8.1.1_E3L2_IG1_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Parameters can be added here if needed
    )

    begin {
        # Dot source the class script
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResults = @()
    }

    process {
        # 8.1.1 (L2) Ensure external file sharing in Teams is enabled for only approved cloud storage services
        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        # Assuming that 'approvedProviders' is a list of approved cloud storage service names
        # This list must be defined according to your organization's approved cloud storage services
        $approvedProviders = @("AllowDropBox", "AllowBox", "AllowGoogleDrive", "AllowShareFile", "AllowEgnyte")
        $clientConfig = Get-CsTeamsClientConfiguration

        $isCompliant = $true
        $nonCompliantProviders = @()

        foreach ($provider in $approvedProviders) {
            if (-not $clientConfig.$provider) {
                $isCompliant = $false
                $nonCompliantProviders += $provider
            }
        }

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"
        $auditResult.Rec = "8.1.1"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L2"
        $auditResult.IG1 = $true # Set based on the benchmark
        $auditResult.IG2 = $true # Set based on the benchmark
        $auditResult.IG3 = $true # Set based on the benchmark
        $auditResult.RecDescription = "Ensure external file sharing in Teams is enabled for only approved cloud storage services"
        $auditResult.Result = $isCompliant
        $auditResult.Details = if (-not $isCompliant) { "Non-approved providers enabled: $($nonCompliantProviders -join ', ')" } else { "All cloud storage services are approved providers" }
        $auditResult.FailureReason = if (-not $isCompliant) { "The following non-approved providers are enabled: $($nonCompliantProviders -join ', ')" } else { "N/A" }
        $auditResult.Status = if ($isCompliant) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}