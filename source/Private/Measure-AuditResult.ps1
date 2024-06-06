function Measure-AuditResult {
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
    Write-Host "Audit completed. $passedTests out of $totalTests tests passed." -ForegroundColor Cyan
    Write-Host "Your passing percentage is $passPercentage%."

    # Display details of failed tests
    if ($FailedTests.Count -gt 0) {
        Write-Host "The following tests failed to complete:" -ForegroundColor Red
        foreach ($failedTest in $FailedTests) {
            Write-Host "Test: $($failedTest.Test)" -ForegroundColor Yellow
            Write-Host "Error: $($failedTest.Error)" -ForegroundColor Yellow
        }
    }
}
