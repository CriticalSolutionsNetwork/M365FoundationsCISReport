function Measure-AuditResult {
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$AllAuditResults,

        [Parameter(Mandatory = $false)]
        [System.Collections.ArrayList]$FailedTests
    )

    # Calculate the total number of tests
    $totalTests = $AllAuditResults.Count

    # Calculate the number of passed tests
    $passedTests = $AllAuditResults.ToArray() | Where-Object { $_.Result -eq $true } | Measure-Object | Select-Object -ExpandProperty Count

    # Calculate the pass percentage
    $passPercentage = if ($totalTests -eq 0) { 0 } else { [math]::Round(($passedTests / $totalTests) * 100, 2) }

    # Display the pass percentage to the user
    Write-Information "Audit completed. $passedTests out of $totalTests tests passed."
    Write-Information "Your passing percentage is $passPercentage%."

    # Display details of failed tests
    if ($FailedTests.Count -gt 0) {
        Write-Verbose "The following tests failed to complete:"
        foreach ($failedTest in $FailedTests) {
            Write-Verbose "Test: $($failedTest.Test)"
            Write-Verbose "Error: $($failedTest.Error)"
        }
    }
}
