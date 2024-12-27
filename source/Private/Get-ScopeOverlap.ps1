function Get-ScopeOverlap {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Policy,

        [Parameter(Mandatory = $true)]
        [PSCustomObject[]]$OtherPolicies
    )
    Write-Verbose "Checking for scope overlap with policy: $($Policy.Name)..."
    $overlapDetected = $false
    $overlappingDetails = @()
    # Extract the correct scope properties for the current policy
    $policyScope = @{
        Users  = $Policy.TargetedUsersToProtect
        Domains = $Policy.TargetedDomainsToProtect
    }
    # Log the current policy's scope
    foreach ($key in $policyScope.Keys) {
        Write-Verbose "Policy $($Policy.Name) $key scope: $($policyScope[$key] -join ', ')"
    }
    # Compare with the scope of other policies
    foreach ($otherPolicy in $OtherPolicies) {
        if ($null -ne $otherPolicy) {
            # Extract the correct scope properties for the other policy
            $otherScope = @{
                Users  = $otherPolicy.TargetedUsersToProtect
                Domains = $otherPolicy.TargetedDomainsToProtect
            }
            # Log the other policy's scope
            Write-Verbose "Comparing with policy: $($otherPolicy.Name)..."
            foreach ($key in $otherScope.Keys) {
                Write-Verbose "$($otherPolicy.Name) $key scope: $($otherScope[$key] -join ', ')"
            }
            # Compare scopes (intersection) and detect overlap
            foreach ($key in $policyScope.Keys) {
                $overlap = $policyScope[$key] | Where-Object { $otherScope[$key] -contains $_ }
                if ($overlap) {
                    $overlapDetected = $true
                    $overlappingDetails += "Overlap detected in $key between $($Policy.Name) and $($otherPolicy.Name): $($overlap -join ', ')"
                    Write-Verbose "Overlap detected in $key`: $($overlap -join ', ')"
                } else {
                    Write-Verbose "No overlap detected for $key between $($Policy.Name) and $($otherPolicy.Name)."
                }
            }
        }
    }
    # Provide a clear summary of overlapping details
    if ($overlapDetected) {
        Write-Verbose "Summary of overlaps for policy $($Policy.Name):"
        foreach ($detail in $overlappingDetails) {
            Write-Verbose "    $detail"
        }
    } else {
        Write-Verbose "No overlapping entities found for policy $($Policy.Name)."
    }
    return $overlapDetected
}
