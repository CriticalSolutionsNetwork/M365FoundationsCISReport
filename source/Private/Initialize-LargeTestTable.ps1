<#
    .SYNOPSIS
    This function generates a large table with the specified number of lines.
    .DESCRIPTION
    This function generates a large table with the specified number of lines. The table has a header and each line has the same format.
    .EXAMPLE
    Initialize-LargeTestTable -lineCount 1000
    .PARAMETER lineCount
    The number of lines to generate.
    .INPUTS
    System.Int32
    .OUTPUTS
    System.String
    .NOTES
    The function is intended for testing purposes.
#>
function Initialize-LargeTestTable {
    [cmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter()]
        [int]$lineCount = 1000 # Number of lines to generate
    )
    process {
        $header = "UserPrincipalName|AuditEnabled|AdminActionsMissing|DelegateActionsMissing|OwnerActionsMissing"
        $lineTemplate = "user{0}@contosonorthwind.net|True|FB,CP,MV|FB,MV|ML,MV,CR"
        # Generate the header and lines
        $lines = @($header)
        for ($i = 1; $i -le $lineCount; $i++) {
            $lines += [string]::Format($lineTemplate, $i)
        }
        $output = $lines -join "`n"
        Write-Host "Details character count: $($output.Length)"
        return $output
    }
}