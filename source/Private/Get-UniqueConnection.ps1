function Get-UniqueConnection {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Connections
    )

    $uniqueConnections = @()

    if ($Connections -contains "AzureAD" -or $Connections -contains "AzureAD | EXO" -or $Connections -contains "AzureAD | EXO | Microsoft Graph") {
        $uniqueConnections += "AzureAD"
    }
    if ($Connections -contains "Microsoft Graph" -or $Connections -contains "AzureAD | EXO | Microsoft Graph") {
        $uniqueConnections += "Microsoft Graph"
    }
    if ($Connections -contains "EXO" -or $Connections -contains "AzureAD | EXO" -or $Connections -contains "Microsoft Teams | EXO" -or $Connections -contains "AzureAD | EXO | Microsoft Graph") {
        $uniqueConnections += "EXO"
    }
    if ($Connections -contains "SPO") {
        $uniqueConnections += "SPO"
    }
    if ($Connections -contains "Microsoft Teams" -or $Connections -contains "Microsoft Teams | EXO") {
        $uniqueConnections += "Microsoft Teams"
    }

    return $uniqueConnections | Sort-Object -Unique
}
