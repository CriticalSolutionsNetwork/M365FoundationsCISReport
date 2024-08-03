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
            if (($script:PnpAuth)) {
                return @(
                    @{ ModuleName = "ExchangeOnlineManagement"; RequiredVersion = "3.3.0"; SubModules = @() },
                    @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModules = @("DeviceManagement", "Users", "Identity.DirectoryManagement", "Identity.SignIns") },
                    @{ ModuleName = "PnP.PowerShell"; RequiredVersion = "2.5.0"; SubModules = @() },
                    @{ ModuleName = "MicrosoftTeams"; RequiredVersion = "5.5.0"; SubModules = @() }
                )
            }
            else {
                return @(
                    @{ ModuleName = "ExchangeOnlineManagement"; RequiredVersion = "3.3.0"; SubModules = @() },
                    @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModules = @("DeviceManagement", "Users", "Identity.DirectoryManagement", "Identity.SignIns") },
                    @{ ModuleName = "Microsoft.Online.SharePoint.PowerShell"; RequiredVersion = "16.0.24009.12000"; SubModules = @() },
                    @{ ModuleName = "MicrosoftTeams"; RequiredVersion = "5.5.0"; SubModules = @() }
                )
            }
        }
        'SyncFunction' {
            return @(
                @{ ModuleName = "ImportExcel"; RequiredVersion = "7.8.9"; SubModules = @() }
            )
        }
        default {
            throw "Please specify either -AuditFunction or -SyncFunction switch."
        }
    }
}
