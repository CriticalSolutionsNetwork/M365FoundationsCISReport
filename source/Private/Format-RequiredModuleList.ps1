function Format-RequiredModuleList {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]$RequiredModules
    )

    $requiredModulesFormatted = ""
    foreach ($module in $RequiredModules) {
        if ($module.SubModules -and $module.SubModules.Count -gt 0) {
            $subModulesFormatted = $module.SubModules -join ', '
            $requiredModulesFormatted += "$($module.ModuleName) (SubModules: $subModulesFormatted), "
        } else {
            $requiredModulesFormatted += "$($module.ModuleName), "
        }
    }
    return $requiredModulesFormatted.TrimEnd(", ")
}
