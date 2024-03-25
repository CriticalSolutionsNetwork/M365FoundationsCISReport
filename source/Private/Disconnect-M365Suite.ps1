function Disconnect-M365Suite {
    # Clean up sessions
    try {
        Write-Host "Disconnecting from Exchange Online..." -ForegroundColor Green
        Disconnect-ExchangeOnline -Confirm:$false | Out-Null
    }
    catch {
        Write-Warning "Failed to disconnect from Exchange Online: $_"
    }
    try {
        Write-Host "Disconnecting from Azure AD..." -ForegroundColor Green
        Disconnect-AzureAD | Out-Null
    }
    catch {
        Write-Warning "Failed to disconnect from Azure AD: $_"
    }
    try {
        Write-Host "Disconnecting from Microsoft Graph..." -ForegroundColor Green
        Disconnect-MgGraph | Out-Null
    }
    catch {
        Write-Warning "Failed to disconnect from Microsoft Graph: $_"
    }
    try {
        Write-Host "Disconnecting from SharePoint Online..." -ForegroundColor Green
        Disconnect-SPOService | Out-Null
    }
    catch {
        Write-Warning "Failed to disconnect from SharePoint Online: $_"
    }
    try {
        Write-Host "Disconnecting from Microsoft Teams..." -ForegroundColor Green
        Disconnect-MicrosoftTeams | Out-Null
    }
    catch {
        Write-Warning "Failed to disconnect from Microsoft Teams: $_"
    }
    Write-Host "All sessions have been disconnected." -ForegroundColor Green
}