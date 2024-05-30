function Get-TestDefinitionsObject {
    param (
        [Parameter(Mandatory = $true)]
        [object[]]$TestDefinitions,

        [Parameter(Mandatory = $true)]
        [string]$ParameterSetName,

        [string]$ELevel,
        [string]$ProfileLevel,
        [string[]]$IncludeRecommendation,
        [string[]]$SkipRecommendation
    )

    Write-Verbose "Initial test definitions count: $($TestDefinitions.Count)"

    switch ($ParameterSetName) {
        'ELevelFilter' {
            Write-Verbose "Applying ELevelFilter"
            if ($null -ne $ELevel -and $null -ne $ProfileLevel) {
                Write-Verbose "Filtering on ELevel = $ELevel and ProfileLevel = $ProfileLevel"
                $TestDefinitions = $TestDefinitions | Where-Object {
                    $_.ELevel -eq $ELevel -and $_.ProfileLevel -eq $ProfileLevel
                }
            }
            elseif ($null -ne $ELevel) {
                Write-Verbose "Filtering on ELevel = $ELevel"
                $TestDefinitions = $TestDefinitions | Where-Object {
                    $_.ELevel -eq $ELevel
                }
            }
            elseif ($null -ne $ProfileLevel) {
                Write-Verbose "Filtering on ProfileLevel = $ProfileLevel"
                $TestDefinitions = $TestDefinitions | Where-Object {
                    $_.ProfileLevel -eq $ProfileLevel
                }
            }
        }
        'IG1Filter' {
            Write-Verbose "Applying IG1Filter"
            $TestDefinitions = $TestDefinitions | Where-Object { $_.IG1 -eq 'TRUE' }
        }
        'IG2Filter' {
            Write-Verbose "Applying IG2Filter"
            $TestDefinitions = $TestDefinitions | Where-Object { $_.IG2 -eq 'TRUE' }
        }
        'IG3Filter' {
            Write-Verbose "Applying IG3Filter"
            $TestDefinitions = $TestDefinitions | Where-Object { $_.IG3 -eq 'TRUE' }
        }
        'RecFilter' {
            Write-Verbose "Applying RecFilter"
            $TestDefinitions = $TestDefinitions | Where-Object { $IncludeRecommendation -contains $_.Rec }
        }
        'SkipRecFilter' {
            Write-Verbose "Applying SkipRecFilter"
            $TestDefinitions = $TestDefinitions | Where-Object { $SkipRecommendation -notcontains $_.Rec }
        }
    }

    Write-Verbose "Filtered test definitions count: $($TestDefinitions.Count)"
    return $TestDefinitions
}