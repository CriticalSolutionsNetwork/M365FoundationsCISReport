function Assert-ModuleAvailability {
    [OutputType([void]) ]
    param(
        [string]$ModuleName,
        [string]$RequiredVersion,
        [string[]]$SubModules = @()
    )

    try {
        $module = Get-Module -ListAvailable -Name $ModuleName | Where-Object { $_.Version -ge [version]$RequiredVersion }

        if ($null -eq $module) {
            Write-Host "Installing $ModuleName module..." -ForegroundColor Yellow
            Install-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force -AllowClobber -Scope CurrentUser | Out-Null
        }
        elseif ($module.Version -lt [version]$RequiredVersion) {
            Write-Host "Updating $ModuleName module to required version..." -ForegroundColor Yellow
            Update-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force | Out-Null
        }
        else {
            Write-Host "$ModuleName module is already at required version or newer." -ForegroundColor Gray
        }

        if ($SubModules.Count -gt 0) {
            foreach ($subModule in $SubModules) {
                Write-Host "Importing submodule $ModuleName.$subModule..." -ForegroundColor DarkGray
                Import-Module -Name "$ModuleName.$subModule" -RequiredVersion $RequiredVersion -ErrorAction Stop | Out-Null
            }
        } else {
            Write-Host "Importing module $ModuleName..." -ForegroundColor DarkGray
            Import-Module -Name $ModuleName -RequiredVersion $RequiredVersion -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
        }
    }
    catch {
        Write-Warning "An error occurred with module $ModuleName`: $_"
    }
}
