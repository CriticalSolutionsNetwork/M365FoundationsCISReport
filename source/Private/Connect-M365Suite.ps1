function Connect-M365Suite {
    [CmdletBinding()]
    param (
        # Parameter to specify the SharePoint Online Tenant Admin URL
        [Parameter(Mandatory)]
        [string]$TenantAdminUrl
    )
$VerbosePreference = "SilentlyContinue"
    try {

        # Attempt to connect to Azure Active Directory
        Write-Host "Connecting to Azure Active Directory..." -ForegroundColor Cyan
        Connect-AzureAD | Out-Null
        Write-Host "Successfully connected to Azure Active Directory." -ForegroundColor Green

        # Attempt to connect to Exchange Online
        Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
        Connect-ExchangeOnline | Out-Null
        Write-Host "Successfully connected to Exchange Online." -ForegroundColor Green
        try {
            # Attempt to connect to Microsoft Graph with specified scopes
            Write-Host "Connecting to Microsoft Graph with scopes: Directory.Read.All, Domain.Read.All, Policy.Read.All, Organization.Read.All" -ForegroundColor Cyan
            Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -NoWelcome | Out-Null
            Write-Host "Successfully connected to Microsoft Graph with specified scopes." -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to connect o MgGraph, attempting device auth." -ForegroundColor Yellow
            # Attempt to connect to Microsoft Graph with specified scopes
            Write-Host "Connecting to Microsoft Graph using device auth with scopes: Directory.Read.All, Domain.Read.All, Policy.Read.All, Organization.Read.All" -ForegroundColor Cyan
            Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -UseDeviceCode -NoWelcome | Out-Null
            Write-Host "Successfully connected to Microsoft Graph with specified scopes." -ForegroundColor Green
        }

        # Validate SharePoint Online Tenant Admin URL
        if (-not $TenantAdminUrl) {
            throw "SharePoint Online Tenant Admin URL is required."
        }

        # Attempt to connect to SharePoint Online
        Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan
        Connect-SPOService -Url $TenantAdminUrl | Out-Null
        Write-Host "Successfully connected to SharePoint Online." -ForegroundColor Green

        # Attempt to connect to Microsoft Teams
        Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
        Connect-MicrosoftTeams | Out-Null
        Write-Host "Successfully connected to Microsoft Teams." -ForegroundColor Green
    }
    catch {
        $VerbosePreference = "Continue"
        Write-Host "There was an error establishing one or more connections: $_" -ForegroundColor Red
        throw $_
    }
    $VerbosePreference = "Continue"
}

