function Disconnect-M365Suite {
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [string[]]$RequiredConnections
    )

    # Clean up sessions
    try {
        if ($RequiredConnections -contains "EXO" -or $RequiredConnections -contains "AzureAD | EXO" -or $RequiredConnections -contains "Microsoft Teams | EXO") {
            Write-Verbose "Disconnecting from Exchange Online..."
            Disconnect-ExchangeOnline -Confirm:$false | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from Exchange Online: $_"
    }

    try {
        if ($RequiredConnections -contains "AzureAD" -or $RequiredConnections -contains "AzureAD | EXO") {
            Write-Verbose "Disconnecting from Azure AD..."
            Disconnect-AzureAD | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from Azure AD: $_"
    }

    try {
        if ($RequiredConnections -contains "Microsoft Graph") {
            Write-Verbose "Disconnecting from Microsoft Graph..."
            Disconnect-MgGraph | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from Microsoft Graph: $_"
    }

    try {
        if ($RequiredConnections -contains "SPO") {
            Write-Verbose "Disconnecting from SharePoint Online..."
            Disconnect-SPOService | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from SharePoint Online: $_"
    }

    try {
        if ($RequiredConnections -contains "Microsoft Teams" -or $RequiredConnections -contains "Microsoft Teams | EXO") {
            Write-Verbose "Disconnecting from Microsoft Teams..."
            Disconnect-MicrosoftTeams | Out-Null
        }
    }
    catch {
        Write-Warning "Failed to disconnect from Microsoft Teams: $_"
    }
    Write-Verbose "All necessary sessions have been disconnected."
}