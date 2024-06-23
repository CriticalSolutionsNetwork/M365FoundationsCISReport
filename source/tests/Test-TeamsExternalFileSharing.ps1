function Test-TeamsExternalFileSharing {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added here if needed
    )

    begin {
        # Dot source the class script if necessary
        # . .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "8.1.1"
    }

    process {
        try {
            # 8.1.1 (L2) Ensure external file sharing in Teams is enabled for only approved cloud storage services
            # Connect to Teams PowerShell using Connect-MicrosoftTeams

            # Condition A: The `AllowDropbox` setting is set to `False`.
            # Condition B: The `AllowBox` setting is set to `False`.
            # Condition C: The `AllowGoogleDrive` setting is set to `False`.
            # Condition D: The `AllowShareFile` setting is set to `False`.
            # Condition E: The `AllowEgnyte` setting is set to `False`.

            # Assuming that 'approvedProviders' is a list of approved cloud storage service names
            # This list must be defined according to your organization's approved cloud storage services
            $clientConfig = Get-CISMSTeamsOutput -Rec $recnum
            $approvedProviders = @("AllowDropBox", "AllowBox", "AllowGoogleDrive", "AllowShareFile", "AllowEgnyte")
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
                Rec           = $recnum
                Result        = $isCompliant
                Status        = if ($isCompliant) { "Pass" } else { "Fail" }
                Details       = if (-not $isCompliant) { "Non-approved providers enabled: $($nonCompliantProviders -join ', ')" } else { "All cloud storage services are approved providers" }
                FailureReason = if (-not $isCompliant) { "The following non-approved providers are enabled: $($nonCompliantProviders -join ', ')" } else { "N/A" }
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
