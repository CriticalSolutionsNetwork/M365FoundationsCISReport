BeforeAll {
    $script:moduleName = '<% $PLASTER_PARAM_ModuleName %>'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    # Re-import the module using force to get any code changes between runs.
    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}

Describe Get-Something {

    Context 'Return values' {
        BeforeEach {
            $return = Get-Something -Data 'value'
        }

        It 'Returns a single object' {
            ($return | Measure-Object).Count | Should -Be 1
        }

    }

    Context 'Pipeline' {
        It 'Accepts values from the pipeline by value' {
            $return = 'value1', 'value2' | Get-Something

            $return[0] | Should -Be 'value1'
            $return[1] | Should -Be 'value2'
        }

        It 'Accepts value from the pipeline by property name' {
            $return = 'value1', 'value2' | ForEach-Object {
                [PSCustomObject]@{
                    Data = $_
                    OtherProperty = 'other'
                }
            } | Get-Something


            $return[0] | Should -Be 'value1'
            $return[1] | Should -Be 'value2'
        }
    }

    Context 'ShouldProcess' {
        It 'Supports WhatIf' {
            (Get-Command Get-Something).Parameters.ContainsKey('WhatIf') | Should -Be $true
            { Get-Something -Data 'value' -WhatIf } | Should -Not -Throw
        }


    }
}

