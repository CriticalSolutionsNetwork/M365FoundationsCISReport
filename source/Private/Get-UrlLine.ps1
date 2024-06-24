<#
    .SYNOPSIS
        This is a sample Private function only visible within the module.

    .DESCRIPTION
        This sample function is not exported to the module and only return the data passed as parameter.

    .EXAMPLE
        $null = Get-UrlLine -PrivateData 'NOTHING TO SEE HERE'

    .PARAMETER PrivateData
        The PrivateData parameter is what will be returned without transformation.
#>
function Get-UrlLine {
    [cmdletBinding()]
    [OutputType([string])]
        param (
            [Parameter(Mandatory=$true)]
            [string]$Output
        )
        # Split the output into lines
        $Lines = $Output -split "`n"
        # Iterate over each line
        foreach ($Line in $Lines) {
            # If the line starts with 'https', return it
            if ($Line.StartsWith('https')) {
                return $Line.Trim()
            }
        }
        # If no line starts with 'https', return an empty string
        return $null
    }