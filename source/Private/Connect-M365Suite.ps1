function Connect-M365Suite {
    [OutputType([void])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$TenantAdminUrl,

        [Parameter(Mandatory)]
        [string[]]$RequiredConnections
    )

    $VerbosePreference = "SilentlyContinue"

    try {
        if ($RequiredConnections -contains "AzureAD" -or $RequiredConnections -contains "AzureAD | EXO" -or $RequiredConnections -contains "AzureAD | EXO | Microsoft Graph") {
            Write-Host "Connecting to Azure Active Directory..." -ForegroundColor Cyan
            Connect-AzureAD | Out-Null
            Write-Host "Successfully connected to Azure Active Directory." -ForegroundColor Green
        }

        if ($RequiredConnections -contains "Microsoft Graph" -or $RequiredConnections -contains "EXO | Microsoft Graph") {
            Write-Host "Connecting to Microsoft Graph with scopes: Directory.Read.All, Domain.Read.All, Policy.Read.All, Organization.Read.All" -ForegroundColor Cyan
            try {
                Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -NoWelcome | Out-Null
                Write-Host "Successfully connected to Microsoft Graph with specified scopes." -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to connect to MgGraph, attempting device auth." -ForegroundColor Yellow
                Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -UseDeviceCode -NoWelcome | Out-Null
                Write-Host "Successfully connected to Microsoft Graph with specified scopes." -ForegroundColor Green
            }
        }

        if ($RequiredConnections -contains "EXO" -or $RequiredConnections -contains "AzureAD | EXO" -or $RequiredConnections -contains "Microsoft Teams | EXO" -or $RequiredConnections -contains "EXO | Microsoft Graph") {
            Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
            Connect-ExchangeOnline | Out-Null
            Write-Host "Successfully connected to Exchange Online." -ForegroundColor Green
        }

        if ($RequiredConnections -contains "SPO") {
            Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan
            Connect-SPOService -Url $TenantAdminUrl | Out-Null
            Write-Host "Successfully connected to SharePoint Online." -ForegroundColor Green
        }

        if ($RequiredConnections -contains "Microsoft Teams" -or $RequiredConnections -contains "Microsoft Teams | EXO") {
            Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
            Connect-MicrosoftTeams | Out-Null
            Write-Host "Successfully connected to Microsoft Teams." -ForegroundColor Green
        }
    }
    catch {
        $VerbosePreference = "Continue"
        Write-Host "There was an error establishing one or more connections: $_" -ForegroundColor Red
        throw $_
    }

    $VerbosePreference = "Continue"
}
