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
            Write-Information "Installing $ModuleName module..." -InformationAction Continue
            Install-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force -AllowClobber -Scope CurrentUser | Out-Null
        }
        elseif ($module.Version -lt [version]$RequiredVersion) {
            Write-Information "Updating $ModuleName module to required version..." -InformationAction Continue
            Update-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force | Out-Null
        }
        else {
            Write-Information "$ModuleName module is already at required version or newer." -InformationAction Continue
        }

        if ($SubModules.Count -gt 0) {
            foreach ($subModule in $SubModules) {
                Write-Information "Importing submodule $ModuleName.$subModule..." -InformationAction Continue
                Import-Module -Name "$ModuleName.$subModule" -RequiredVersion $RequiredVersion -ErrorAction Stop | Out-Null
            }
        } else {
            Write-Information "Importing module $ModuleName..." -InformationAction Continue
            Import-Module -Name $ModuleName -RequiredVersion $RequiredVersion -ErrorAction Stop | Out-Null
        }
    }
    catch {
        Write-Warning "An error occurred with module $ModuleName`: $_"
    }
}
