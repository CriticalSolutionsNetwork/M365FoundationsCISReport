function Disconnect-M365Suite {
    param (
        [Parameter(Mandatory)]
        [string[]]$RequiredConnections
    )

    # Clean up sessions
    try {
        if ($RequiredConnections -contains "EXO" -or $RequiredConnections -contains "AzureAD | EXO" -or $RequiredConnections -contains "Microsoft Teams | EXO") {
            Write-Host "Disconnecting from Exchange Online..." -ForegroundColor Green
            Disconnect-ExchangeOnline -Confirm:$false | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from Exchange Online: $_"
    }

    try {
        if ($RequiredConnections -contains "AzureAD" -or $RequiredConnections -contains "AzureAD | EXO") {
            Write-Host "Disconnecting from Azure AD..." -ForegroundColor Green
            Disconnect-AzureAD | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from Azure AD: $_"
    }

    try {
        if ($RequiredConnections -contains "Microsoft Graph") {
            Write-Host "Disconnecting from Microsoft Graph..." -ForegroundColor Green
            Disconnect-MgGraph | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from Microsoft Graph: $_"
    }

    try {
        if ($RequiredConnections -contains "SPO") {
            Write-Host "Disconnecting from SharePoint Online..." -ForegroundColor Green
            Disconnect-SPOService | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from SharePoint Online: $_"
    }

    try {
        if ($RequiredConnections -contains "Microsoft Teams" -or $RequiredConnections -contains "Microsoft Teams | EXO") {
            Write-Host "Disconnecting from Microsoft Teams..." -ForegroundColor Green
            Disconnect-MicrosoftTeams | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from Microsoft Teams: $_"
    }

    Write-Host "All necessary sessions have been disconnected." -ForegroundColor Green
}