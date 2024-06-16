function Initialize-LargeTestTable {
    param (
        [int]$lineCount = 1000 # Number of lines to generate
    )
    $header = "UserPrincipalName|AuditEnabled|AdminActionsMissing|DelegateActionsMissing|OwnerActionsMissing"
    $lineTemplate = "user{0}@criticalsolutions.net|True|FB,CP,MV|FB,MV|ML,MV,CR"

    $lines = @($header)
    for ($i = 1; $i -le $lineCount; $i++) {
        $lines += [string]::Format($lineTemplate, $i)
    }
    $output = $lines -join "`n"
    Write-Host "Details character count: $($output.Length)"
    return $output
}