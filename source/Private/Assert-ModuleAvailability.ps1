function Assert-ModuleAvailability {
    [CmdletBinding()]
    [OutputType([void]) ]
    param(
        [string]$ModuleName,
        [string]$RequiredVersion,
        [string[]]$SubModules = @()
    )
    process {
        try {
                $module = Get-Module -ListAvailable -Name $ModuleName | Where-Object { $_.Version -ge [version]$RequiredVersion }
                if ($null -eq $module) {
                    Write-Verbose "Installing $ModuleName module..."
                    Install-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force -AllowClobber -Scope CurrentUser | Out-Null
                }
                elseif ($module.Version -lt [version]$RequiredVersion) {
                    Write-Verbose "Updating $ModuleName module to required version..."
                    Update-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force | Out-Null
                }
                else {
                    Write-Verbose "$ModuleName module is already at required version or newer."
                }
                if ($ModuleName -eq "Microsoft.Graph") {
                    # "Preloading Microsoft.Graph assembly to prevent type-loading issues..."
                    Write-Verbose "Preloading Microsoft.Graph assembly to prevent type-loading issues..."
                    try {
                        # Run a harmless cmdlet to preload the assembly
                        Get-MgGroup -Top 1 -ErrorAction SilentlyContinue | Out-Null
                    }
                    catch {
                        Write-Verbose "Could not preload Microsoft.Graph assembly. Error: $_"
                    }
                }
                if ($SubModules.Count -gt 0) {
                    foreach ($subModule in $SubModules) {
                        Write-Verbose "Importing submodule $ModuleName.$subModule..."
                        Get-Module "$ModuleName.$subModule" | Import-Module -RequiredVersion $RequiredVersion -ErrorAction Stop | Out-Null
                    }
                }
                else {
                    Write-Verbose "Importing module $ModuleName..."
                    Import-Module -Name $ModuleName -RequiredVersion $RequiredVersion -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
                }
        }
        catch {
            throw "Assert-ModuleAvailability:`n$_"
        }
    }
}