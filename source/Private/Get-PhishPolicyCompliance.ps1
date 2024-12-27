function Get-PhishPolicyCompliance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Policy
    )
    # Define the compliance criteria for an anti-phishing policy
    $complianceCriteria = @{
        Enabled                             = $true                            # Policy must be enabled
        EnableTargetedUserProtection        = $true                            # Targeted user protection must be enabled
        EnableOrganizationDomainsProtection = $true                            # Organization domains protection must be enabled
        EnableMailboxIntelligence           = $true                            # Mailbox intelligence must be enabled
        EnableMailboxIntelligenceProtection = $true                            # Mailbox intelligence protection must be enabled
        EnableSpoofIntelligence             = $true                            # Spoof intelligence must be enabled
        TargetedUserProtectionAction        = 'Quarantine'                     # Actions for targeted user protection must be 'Quarantine'
        TargetedDomainProtectionAction      = 'Quarantine'                     # Actions for targeted domain protection must be 'Quarantine'
        MailboxIntelligenceProtectionAction = 'Quarantine'                     # Actions for mailbox intelligence protection must be 'Quarantine'
        EnableFirstContactSafetyTips        = $true                            # First contact safety tips must be enabled
        EnableSimilarUsersSafetyTips        = $true                            # Similar users safety tips must be enabled
        EnableSimilarDomainsSafetyTips      = $true                            # Similar domains safety tips must be enabled
        EnableUnusualCharactersSafetyTips   = $true                            # Unusual characters safety tips must be enabled
        HonorDmarcPolicy                    = $true                            # Honor DMARC policy must be enabled
    }
    # Initialize compliance state and a list to track non-compliance reasons
    $isCompliant = $true
    $nonCompliantReasons = @()
    # Iterate through the compliance criteria and check each property of the policy
    foreach ($key in $complianceCriteria.Keys) {
        if ($Policy.PSObject.Properties[$key] -and $Policy.$key -ne $complianceCriteria[$key]) {
            $isCompliant = $false                                              # Mark as non-compliant if the value doesn't match
            $nonCompliantReasons += "$key`: Expected $($complianceCriteria[$key]), Found $($Policy.$key)" # Record the discrepancy
        }
    }
    # Special case: Ensure PhishThresholdLevel is at least 3
    if ($Policy.PSObject.Properties['PhishThresholdLevel'] -and $Policy.PhishThresholdLevel -lt 3) {
        $isCompliant = $false                                                  # Mark as non-compliant if threshold is below 3
        $nonCompliantReasons += "PhishThresholdLevel: Expected at least 3, Found $($Policy.PhishThresholdLevel)" # Record the issue
    }
    # Log the reasons for non-compliance if the policy is not compliant
    if (-not $isCompliant) {
        Write-Verbose "Policy $($Policy.Name) is not compliant. Reasons: $($nonCompliantReasons -join '; ')"
    }
    # Return whether the policy is compliant
    return $isCompliant
}