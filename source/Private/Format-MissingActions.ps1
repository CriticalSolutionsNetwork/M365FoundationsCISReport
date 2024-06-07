function Format-MissingActions {
    param ([array]$missingActions)

    $actionGroups = @{
        "Admin"    = @()
        "Delegate" = @()
        "Owner"    = @()
    }

    foreach ($action in $missingActions) {
        if ($action -match "(Admin|Delegate|Owner) action '([^']+)' missing") {
            $type = $matches[1]
            $actionName = $matches[2]
            $actionGroups[$type] += $actionName
        }
    }

    $formattedResults = @{
        Admin    = $actionGroups["Admin"] -join ', '
        Delegate = $actionGroups["Delegate"] -join ', '
        Owner    = $actionGroups["Owner"] -join ', '
    }

    return $formattedResults
}