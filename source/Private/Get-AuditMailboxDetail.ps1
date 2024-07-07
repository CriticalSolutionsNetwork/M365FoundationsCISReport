function Get-AuditMailboxDetail {
    [cmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Details,
        [Parameter(Mandatory = $true)]
        [String]$Version
    )
    process {
        switch ($Version) {
            "6.1.2" { [string]$VersionText = "No M365 E3 licenses found."}
            "6.1.3" { [string]$VersionText = "No M365 E5 licenses found."}
        }
        if ($details -ne $VersionText ) {
            $csv = $details | ConvertFrom-Csv -Delimiter '|'
        }
        else {
            $csv = $null
        }
        if ($null -ne $csv) {
            foreach ($row in $csv) {
                $row.AdminActionsMissing = (Get-Action -AbbreviatedActions $row.AdminActionsMissing.Split(',') -ReverseActionType Admin -Version $Version) -join ','
                $row.DelegateActionsMissing = (Get-Action -AbbreviatedActions $row.DelegateActionsMissing.Split(',') -ReverseActionType Delegate -Version $Version ) -join ','
                $row.OwnerActionsMissing = (Get-Action -AbbreviatedActions $row.OwnerActionsMissing.Split(',') -ReverseActionType Owner -Version $Version ) -join ','
            }
            $newObjectDetails = $csv
        }
        else {
            $newObjectDetails = $details
        }
        return $newObjectDetails
    }
}