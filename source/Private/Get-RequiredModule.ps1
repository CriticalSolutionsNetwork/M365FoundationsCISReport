function Get-RequiredModule {
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
