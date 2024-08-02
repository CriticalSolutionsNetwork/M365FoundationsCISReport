function Connect-M365Suite {
    [OutputType([void])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$TenantAdminUrl,

        [Parameter(Mandatory)]
        [string[]]$RequiredConnections,

        [Parameter(Mandatory = $false)]
        [switch]$SkipConfirmation
    )
    if (!$SkipConfirmation) {
        $VerbosePreference = "Continue"
    }
    else {
        $VerbosePreference = "SilentlyContinue"
    }
    $tenantInfo = @()
    $connectedServices = @()

    try {
        if ($RequiredConnections -contains "AzureAD" -or $RequiredConnections -contains "AzureAD | EXO" -or $RequiredConnections -contains "AzureAD | EXO | Microsoft Graph") {
            Write-Verbose "Connecting to Azure Active Directory..."
            Connect-AzureAD -WarningAction SilentlyContinue | Out-Null
            $tenantDetails = Get-AzureADTenantDetail -WarningAction SilentlyContinue
            $tenantInfo += [PSCustomObject]@{
                Service = "Azure Active Directory"
                TenantName = $tenantDetails.DisplayName
                TenantID = $tenantDetails.ObjectId
            }
            $connectedServices += "AzureAD"
            Write-Verbose "Successfully connected to Azure Active Directory."
        }

        if ($RequiredConnections -contains "Microsoft Graph" -or $RequiredConnections -contains "EXO | Microsoft Graph") {
            Write-Verbose "Connecting to Microsoft Graph with scopes: Directory.Read.All, Domain.Read.All, Policy.Read.All, Organization.Read.All"
            try {
                Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -NoWelcome | Out-Null
                $graphOrgDetails = Get-MgOrganization
                $tenantInfo += [PSCustomObject]@{
                    Service = "Microsoft Graph"
                    TenantName = $graphOrgDetails.DisplayName
                    TenantID = $graphOrgDetails.Id
                }
                $connectedServices += "Microsoft Graph"
                Write-Verbose "Successfully connected to Microsoft Graph with specified scopes."
            }
            catch {
                Write-Verbose "Failed to connect to MgGraph, attempting device auth."
                Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -UseDeviceCode -NoWelcome | Out-Null
                $graphOrgDetails = Get-MgOrganization
                $tenantInfo += [PSCustomObject]@{
                    Service = "Microsoft Graph"
                    TenantName = $graphOrgDetails.DisplayName
                    TenantID = $graphOrgDetails.Id
                }
                $connectedServices += "Microsoft Graph"
                Write-Verbose "Successfully connected to Microsoft Graph with specified scopes."
            }
        }

        if ($RequiredConnections -contains "EXO" -or $RequiredConnections -contains "AzureAD | EXO" -or $RequiredConnections -contains "Microsoft Teams | EXO" -or $RequiredConnections -contains "EXO | Microsoft Graph") {
            Write-Verbose "Connecting to Exchange Online..."
            Connect-ExchangeOnline -ShowBanner:$false | Out-Null
            $exoTenant = (Get-OrganizationConfig).Identity
            $tenantInfo += [PSCustomObject]@{
                Service = "Exchange Online"
                TenantName = $exoTenant
                TenantID = "N/A"
            }
            $connectedServices += "EXO"
            Write-Verbose "Successfully connected to Exchange Online."
        }

        if ($RequiredConnections -contains "SPO") {
            Write-Verbose "Connecting to SharePoint Online..."
            Connect-SPOService -Url $TenantAdminUrl | Out-Null
            $spoContext = Get-SPOCrossTenantHostUrl
            $tenantName = Get-UrlLine -Output $spoContext
            $tenantInfo += [PSCustomObject]@{
                Service = "SharePoint Online"
                TenantName = $tenantName
            }
            $connectedServices += "SPO"
            Write-Verbose "Successfully connected to SharePoint Online."
        }

        if ($RequiredConnections -contains "Microsoft Teams" -or $RequiredConnections -contains "Microsoft Teams | EXO") {
            Write-Verbose "Connecting to Microsoft Teams..."
            Connect-MicrosoftTeams | Out-Null
            $teamsTenantDetails = Get-CsTenant
            $tenantInfo += [PSCustomObject]@{
                Service = "Microsoft Teams"
                TenantName = $teamsTenantDetails.DisplayName
                TenantID = $teamsTenantDetails.TenantId
            }
            $connectedServices += "Microsoft Teams"
            Write-Verbose "Successfully connected to Microsoft Teams."
        }

        # Display tenant information and confirm with the user
        if (-not $SkipConfirmation) {
            Write-Verbose "Connected to the following tenants:"
            foreach ($tenant in $tenantInfo) {
                Write-Verbose "Service: $($tenant.Service)"
                Write-Verbose "Tenant Context: $($tenant.TenantName)`n"
                #Write-Verbose "Tenant ID: $($tenant.TenantID)"
            }
            $confirmation = Read-Host "Do you want to proceed with these connections? (Y/N)"
            if ($confirmation -notlike 'Y') {
                Write-Verbose "Connection setup aborted by user."
                Disconnect-M365Suite -RequiredConnections $connectedServices
                throw "User aborted connection setup."
            }
        }
    }
    catch {
        $VerbosePreference = "Continue"
        Write-Verbose "There was an error establishing one or more connections: $_"
        throw $_
    }

    $VerbosePreference = "Continue"
}
