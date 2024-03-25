function Assert-ModuleAvailability {
    param(
        [string]$ModuleName,
        [string]$RequiredVersion,
        [string]$SubModuleName
    )

    try {
        $module = Get-Module -ListAvailable -Name $ModuleName | Where-Object { $_.Version -ge [version]$RequiredVersion }

        if ($null -eq $module) {$auditResult.Profile
            Write-Host "Installing $ModuleName module..."
            Install-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force -AllowClobber -Scope CurrentUser | Out-Null
        }
        elseif ($module.Version -lt [version]$RequiredVersion) {
            Write-Host "Updating $ModuleName module to required version..."
            Update-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force | Out-Null
        }
        else {
            Write-Host "$ModuleName module is already at required version or newer."
        }

        if ($SubModuleName) {
            Import-Module -Name "$ModuleName.$SubModuleName" -RequiredVersion $RequiredVersion -ErrorAction Stop | Out-Null
        }
        else {
            Import-Module -Name $ModuleName -RequiredVersion $RequiredVersion -ErrorAction Stop | Out-Null
        }
    }
    catch {
        Write-Warning "An error occurred with module $ModuleName`: $_"
    }
}