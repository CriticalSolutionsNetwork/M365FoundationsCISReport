function Test-TeamsExternalFileSharing {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed

        $auditResult = [CISAuditResult]::new()
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
        $params = @{
            Rec            = "8.1.1"
            Result         = $isCompliant
            Status         = if ($isCompliant) { "Pass" } else { "Fail" }
            Details        = if (-not $isCompliant) { "Non-approved providers enabled: $($nonCompliantProviders -join ', ')" } else { "All cloud storage services are approved providers" }
            FailureReason  = if (-not $isCompliant) { "The following non-approved providers are enabled: $($nonCompliantProviders -join ', ')" } else { "N/A" }
            RecDescription = "Ensure external file sharing in Teams is enabled for only approved cloud storage services"
            CISControl     = "3.3"
            CISDescription = "Configure Data Access Control Lists"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
