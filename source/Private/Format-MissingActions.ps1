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

    $formattedResults = @()
    foreach ($type in $actionGroups.Keys) {
        if ($actionGroups[$type].Count -gt 0) {
            $formattedResults += "$($type) actions missing: $($actionGroups[$type] -join ', ')"
        }
    }

    return $formattedResults -join '; '
}