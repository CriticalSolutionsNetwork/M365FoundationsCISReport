function Get-ScopeOverlap {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Policy,                      # The primary policy whose scope we are evaluating
        [Parameter(Mandatory = $true)]
        [PSCustomObject[]]$OtherPolicies              # A list of other policies to compare for scope overlap
    )
    # Write a verbose message indicating the policy being evaluated for overlap
    Write-Verbose "Checking for scope overlap with $($Policy.Name)..."
    # Initialize variables to track overlap status and overlapping entities
    $overlapDetected = $false                         # Tracks if any overlap is detected
    $overlappingEntities = @()                        # Stores details of overlapping entities for logging
    # Build the scope string of the current policy by concatenating users, groups, and domains
    $policyScope = @(
        $Policy.Users -join ',',                      # Users within the policy's scope
        $Policy.Groups -join ',',                     # Groups within the policy's scope
        $Policy.Domains -join ','                     # Domains within the policy's scope
    ) -join ','                                       # Combine all into a single string
    # Iterate through each policy in the list of other policies
    foreach ($otherPolicy in $OtherPolicies) {
        if ($null -ne $otherPolicy) {                 # Skip null or empty policies
            # Build the scope string for the other policy
            $otherScope = @(
                $otherPolicy.Users -join ',',         # Users within the other policy's scope
                $otherPolicy.Groups -join ',',        # Groups within the other policy's scope
                $otherPolicy.Domains -join ','        # Domains within the other policy's scope
            ) -join ','                               # Combine all into a single string
            # Check if the current policy's scope matches any part of the other policy's scope
            if ($policyScope -match $otherScope) {
                $overlapDetected = $true             # Mark overlap as detected
                # Log overlapping entities for clarity
                $overlappingEntities += @(
                    "Users: $($otherPolicy.Users)",
                    "Groups: $($otherPolicy.Groups)",
                    "Domains: $($otherPolicy.Domains)"
                )
                Write-Verbose "Overlap detected between $($Policy.Name) and $($otherPolicy.Name)." # Log the overlap
            }
        }
    }
    # If overlap is detected, log the specific overlapping entities
    if ($overlapDetected) {
        Write-Verbose "Overlapping entities: $($overlappingEntities -join '; ')" # Log overlapping users, groups, or domains
    }
    # Return whether overlap was detected (true/false)
    return $overlapDetected
}
