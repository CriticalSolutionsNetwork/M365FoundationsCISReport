function Assert-ModuleAvailability {
    [CmdletBinding()]
    [OutputType([void]) ]
    param(
        [string]$ModuleName,
        [string]$RequiredVersion,
        [string[]]$SubModules = @()
    )
    process {
        # If $script:PnpAuth = $true, check for powershell version 7.x or higher or throw error
        if ($script:PnpAuth -and $PSVersionTable.PSVersion.Major -lt 7) {
            throw 'PnP.PowerShell module requires PowerShell 7.x or higher.'
        }
        try {
            switch ($ModuleName) {
                'Microsoft.Graph' {
                    if ($SubModules.Count -eq 0) { throw 'SubModules cannot be empty for Microsoft.Graph module.' }
                    try {
                        foreach ($subModule in $SubModules) {
                            if (Get-Module -Name "$ModuleName.$subModule" -ListAvailable -ErrorAction SilentlyContinue) {
                                Write-Verbose "Submodule $ModuleName.$subModule already loaded."
                            }
                            else {
                                Write-Verbose "Importing submodule $ModuleName.$subModule..."
                                Import-Module "$ModuleName.$subModule" -MinimumVersion $RequiredVersion -ErrorAction Stop | Out-Null
                            }
                        }
                        # Loading assembly to avoid conflict with other modules
                        Get-MgGroup -Top 1 -ErrorAction SilentlyContinue | Out-Null
                    }
                    catch [System.IO.FileNotFoundException] {
                        # Write the error class in verbose
                        Write-Verbose "Error importing submodule $ModuleName.$subModule`: $($_.Exception.GetType().FullName)"
                        Write-Verbose "Submodule $ModuleName.$subModule not found. Installing the module..."
                        foreach ($subModule in $SubModules) {
                            Write-Verbose "Installing submodule $ModuleName.$subModule..."
                            Install-Module -Name "$ModuleName.$subModule" -MinimumVersion $RequiredVersion -Force -AllowClobber -Scope CurrentUser | Out-Null
                            Write-Verbose "Successfully installed $ModuleName.$subModule module."
                        }
                        # Loading assembly to avoid conflict with other modules
                        Get-MgGroup -Top 1 -ErrorAction SilentlyContinue | Out-Null
                    }
                }
                default {
                    if (Get-Module -Name $ModuleName -ListAvailable -ErrorAction SilentlyContinue) {
                        Write-Verbose "$ModuleName module already loaded."
                        return
                    }
                    $module = Import-Module $ModuleName -PassThru -ErrorAction SilentlyContinue | Where-Object { $_.Version -ge $RequiredVersion }
                    if ($null -eq $module) {
                        Write-Verbose "Installing $ModuleName module..."
                        Install-Module -Name $ModuleName -MinimumVersion $RequiredVersion -Force -AllowClobber -Scope CurrentUser | Out-Null
                    }
                    elseif ($module.Version -lt $RequiredVersion) {
                        Write-Verbose "Updating $ModuleName module to required version..."
                        Update-Module -Name $ModuleName -MinimumVersion $RequiredVersion -Force | Out-Null
                    }
                    else {
                        Write-Verbose "$ModuleName module is already at required version or newer."
                    }
                }
            }
        }
        catch {
            Write-Verbose 'Assert-ModuleAvailability Error:'
            throw $_.Exception.Message
        }
    }
}