<#
    .SYNOPSIS
        This is a sample Private function only visible within the module.
    .DESCRIPTION
        This sample function is not exported to the module and only return the data passed as parameter.
    .EXAMPLE
        $null = Get-Get-CISAadOutput -PrivateData 'NOTHING TO SEE HERE'
    .PARAMETER PrivateData
        The PrivateData parameter is what will be returned without transformation.
#>
function Get-CISAadOutput {
    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Rec
    )
    begin {
        # Begin Block #
    <#
        # Tests
        1.2.2
        # Test number
        $testNumbers ="1.2.2"
    #>
    }
    process {
        switch ($Rec) {
            '1.2.2' {
                # Test-BlockSharedMailboxSignIn.ps1
                $users = Get-AzureADUser
            }
            default { throw "No match found for test: $Rec" }
        }
    }
    end {
        Write-Verbose "Get-CISAadOutput: Retuning data for Rec: $Rec"
        return $users
    }
} # end function Get-CISAadOutput
