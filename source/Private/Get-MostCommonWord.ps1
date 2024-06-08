function Get-MostCommonWord {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$InputStrings
    )

    # Combine all strings into one large string
    $allText = $InputStrings -join ' '

    # Split the large string into words
    $words = $allText -split '\s+'

    # Group words and count occurrences
    $wordGroups = $words | Group-Object | Sort-Object Count -Descending

    # Return the most common word if it occurs at least 3 times
    if ($wordGroups.Count -gt 0 -and $wordGroups[0].Count -ge 3) {
        return $wordGroups[0].Name
    } else {
        return $null
    }
}