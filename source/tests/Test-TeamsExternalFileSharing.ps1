function Test-TeamsExternalFileSharing {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        [Parameter(Mandatory = $false)]
        [string[]]$ApprovedCloudStorageProviders
    )
    begin {
        # Dot source the class script if necessary
        # . .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "8.1.1"
        Write-Verbose "Running Test-TeamsExternalFileSharing for $recnum..."
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
            # Retrieve the current Teams client configuration
            $clientConfig = Get-CISMSTeamsOutput -Rec $recnum
            # Testing
            #$clientconfig.AllowGoogleDrive = $false
            #$clientconfig.AllowBox = $false
            #$clientconfig.AllowShareFile = $false
            #$clientconfig.AllowEgnyte = $false
            #$clientconfig.AllowDropBox = $false
            # Define all possible cloud storage providers
            $allProviders = @("AllowDropBox", "AllowBox", "AllowGoogleDrive", "AllowShareFile", "AllowEgnyte")
            # If ApprovedCloudStorageProviders is provided, map it to the corresponding settings
            if ($PSBoundParameters.ContainsKey('ApprovedCloudStorageProviders')) {
                $approvedProviders = @()
                foreach ($provider in $ApprovedCloudStorageProviders) {
                    $approvedProviders += "Allow$provider"
                }
            } else {
                # Default approved providers
                $approvedProviders = @()
            }
            $isCompliant = $true
            $nonCompliantProviders = @()
            foreach ($provider in $allProviders) {
                if ($clientConfig.$provider -and -not $approvedProviders.Contains($provider)) {
                    $isCompliant = $false
                    $nonCompliantProviders += $provider
                }
            }
            $basePassDetails = "All cloud storage services are approved providers"
            if ($ApprovedCloudStorageProviders) {
                $basePassDetails = "Approved cloud storage services: $($ApprovedCloudStorageProviders -join ', ')"
            }
            # Create an instance of CISAuditResult and populate it
            $params = @{
                Rec           = $recnum
                Result        = $isCompliant
                Status        = if ($isCompliant) { "Pass" } else { "Fail" }
                Details       = if (-not $isCompliant) { "Non-approved providers enabled: $($nonCompliantProviders -join ', ')" } else { $basePassDetails }
                FailureReason = if (-not $isCompliant) { "The following non-approved providers are enabled: $($nonCompliantProviders -join ', ')" } else { "N/A" }
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
