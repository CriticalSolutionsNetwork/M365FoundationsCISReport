function Get-TestDefinition {
    param (
        [string]$Version
    )
    # Load test definitions from CSV
    $testDefinitionsPath = Join-Path -Path $PSScriptRoot -ChildPath 'helper\TestDefinitions.csv'
    $testDefinitions = Import-Csv -Path $testDefinitionsPath
    # ################ Check for $Version -eq '4.0.0' ################
    if ($Version -eq '4.0.0') {
        $script:Version400 = $true
        $testDefinitionsV4Path = Join-Path -Path $PSScriptRoot -ChildPath 'helper\TestDefinitions-v4.0.0.csv'
        $testDefinitionsV4 = Import-Csv -Path $testDefinitionsV4Path
        # Merge the definitions, prioritizing version 4.0.0
        $mergedDefinitions = @{ }
        foreach ($test in $testDefinitions) {
            $mergedDefinitions[$test.Rec] = $test
        }
        foreach ($testV4 in $testDefinitionsV4) {
            $mergedDefinitions[$testV4.Rec] = $testV4  # Overwrite if Rec exists
        }
        # Convert back to an array
        $testDefinitions = $mergedDefinitions.Values
        Write-Verbose "Total tests after merging: $(($testDefinitions).Count)"
        $overwrittenTests = $testDefinitionsV4 | Where-Object { $testDefinitions[$_.Rec] }
        Write-Verbose "Overwritten tests: $($overwrittenTests.Rec -join ', ')"
    }
    return $testDefinitions
}
