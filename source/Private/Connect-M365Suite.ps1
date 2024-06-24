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

    $VerbosePreference = "SilentlyContinue"
    $tenantInfo = @()
    $connectedServices = @()

    try {
        if ($RequiredConnections -contains "AzureAD" -or $RequiredConnections -contains "AzureAD | EXO" -or $RequiredConnections -contains "AzureAD | EXO | Microsoft Graph") {
            Write-Host "Connecting to Azure Active Directory..." -ForegroundColor Yellow
            Connect-AzureAD -WarningAction SilentlyContinue | Out-Null
            $tenantDetails = Get-AzureADTenantDetail -WarningAction SilentlyContinue
            $tenantInfo += [PSCustomObject]@{
                Service = "Azure Active Directory"
                TenantName = $tenantDetails.DisplayName
                TenantID = $tenantDetails.ObjectId
            }
            $connectedServices += "AzureAD"
            Write-Host "Successfully connected to Azure Active Directory." -ForegroundColor Green
        }

        if ($RequiredConnections -contains "Microsoft Graph" -or $RequiredConnections -contains "EXO | Microsoft Graph") {
            Write-Host "Connecting to Microsoft Graph with scopes: Directory.Read.All, Domain.Read.All, Policy.Read.All, Organization.Read.All" -ForegroundColor Yellow
            try {
                Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -NoWelcome | Out-Null
                $graphOrgDetails = Get-MgOrganization
                $tenantInfo += [PSCustomObject]@{
                    Service = "Microsoft Graph"
                    TenantName = $graphOrgDetails.DisplayName
                    TenantID = $graphOrgDetails.Id
                }
                $connectedServices += "Microsoft Graph"
                Write-Host "Successfully connected to Microsoft Graph with specified scopes." -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to connect to MgGraph, attempting device auth." -ForegroundColor Yellow
                Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -UseDeviceCode -NoWelcome | Out-Null
                $graphOrgDetails = Get-MgOrganization
                $tenantInfo += [PSCustomObject]@{
                    Service = "Microsoft Graph"
                    TenantName = $graphOrgDetails.DisplayName
                    TenantID = $graphOrgDetails.Id
                }
                $connectedServices += "Microsoft Graph"
                Write-Host "Successfully connected to Microsoft Graph with specified scopes." -ForegroundColor Green
            }
        }

        if ($RequiredConnections -contains "EXO" -or $RequiredConnections -contains "AzureAD | EXO" -or $RequiredConnections -contains "Microsoft Teams | EXO" -or $RequiredConnections -contains "EXO | Microsoft Graph") {
            Write-Host "Connecting to Exchange Online..." -ForegroundColor Yellow
            Connect-ExchangeOnline -ShowBanner:$false | Out-Null
            $exoTenant = (Get-OrganizationConfig).Identity
            $tenantInfo += [PSCustomObject]@{
                Service = "Exchange Online"
                TenantName = $exoTenant
                TenantID = "N/A"
            }
            $connectedServices += "EXO"
            Write-Host "Successfully connected to Exchange Online." -ForegroundColor Green
        }

        if ($RequiredConnections -contains "SPO") {
            Write-Host "Connecting to SharePoint Online..." -ForegroundColor Yellow
            Connect-SPOService -Url $TenantAdminUrl | Out-Null
            $spoContext = Get-SPOCrossTenantHostUrl
            $tenantName = Get-UrlLine -Output $spoContext
            $tenantInfo += [PSCustomObject]@{
                Service = "SharePoint Online"
                TenantName = $tenantName
            }
            $connectedServices += "SPO"
            Write-Host "Successfully connected to SharePoint Online." -ForegroundColor Green
        }

        if ($RequiredConnections -contains "Microsoft Teams" -or $RequiredConnections -contains "Microsoft Teams | EXO") {
            Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Yellow
            Connect-MicrosoftTeams | Out-Null
            $teamsTenantDetails = Get-CsTenant
            $tenantInfo += [PSCustomObject]@{
                Service = "Microsoft Teams"
                TenantName = $teamsTenantDetails.DisplayName
                TenantID = $teamsTenantDetails.TenantId
            }
            $connectedServices += "Microsoft Teams"
            Write-Host "Successfully connected to Microsoft Teams." -ForegroundColor Green
        }

        # Display tenant information and confirm with the user
        if (-not $SkipConfirmation) {
            Write-Host "Connected to the following tenants:" -ForegroundColor Yellow
            foreach ($tenant in $tenantInfo) {
                Write-Host "Service: $($tenant.Service)" -ForegroundColor Cyan
                Write-Host "Tenant Context: $($tenant.TenantName)`n" -ForegroundColor Green
                #Write-Host "Tenant ID: $($tenant.TenantID)"
            }
            $confirmation = Read-Host "Do you want to proceed with these connections? (Y/N)"
            if ($confirmation -notlike 'Y') {
                Write-Host "Connection setup aborted by user." -ForegroundColor Red
                Disconnect-M365Suite -RequiredConnections $connectedServices
                throw "User aborted connection setup."
            }
        }
    }
    catch {
        $VerbosePreference = "Continue"
        Write-Host "There was an error establishing one or more connections: $_" -ForegroundColor Red
        throw $_
    }

    $VerbosePreference = "Continue"
}
