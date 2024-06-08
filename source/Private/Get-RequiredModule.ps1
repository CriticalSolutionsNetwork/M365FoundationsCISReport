function Get-RequiredModule {
    [CmdletBinding(DefaultParameterSetName = 'AuditFunction')]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'AuditFunction')]
        [switch]$AuditFunction,

        [Parameter(Mandatory = $true, ParameterSetName = 'SyncFunction')]
        [switch]$SyncFunction
    )

    switch ($PSCmdlet.ParameterSetName) {
        'AuditFunction' {
            return @(
                @{ ModuleName = "ExchangeOnlineManagement"; RequiredVersion = "3.3.0" },
                @{ ModuleName = "AzureAD"; RequiredVersion = "2.0.2.182" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Authentication" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Users" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Groups" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "DirectoryObjects" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Domains" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Reports" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Mail" },
                @{ ModuleName = "Microsoft.Online.SharePoint.PowerShell"; RequiredVersion = "16.0.24009.12000" },
                @{ ModuleName = "MicrosoftTeams"; RequiredVersion = "5.5.0" }
            )
        }
        'SyncFunction' {
            return @(
                @{ ModuleName = "ImportExcel"; RequiredVersion = "7.8.9" }
            )
        }
        default {
            throw "Please specify either -AuditFunction or -SyncFunction switch."
        }
    }
}
