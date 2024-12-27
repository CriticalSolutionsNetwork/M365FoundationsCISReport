function Get-PhishPolicyCompliance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Policy
    )
    Write-Verbose "Starting compliance evaluation for policy: $($Policy.Name)"
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
    Write-Verbose "Evaluating compliance criteria for policy: $($Policy.Name)"
    # Iterate through the compliance criteria and check each property of the policy
    foreach ($key in $complianceCriteria.Keys) {
        Write-Verbose "Checking $key`: Expected $($complianceCriteria[$key])"
        if ($Policy.PSObject.Properties[$key] -and $Policy.$key -ne $complianceCriteria[$key]) {
            Write-Verbose "Non-compliance detected for $key. Found $($Policy.$key)"
            $isCompliant = $false                                              # Mark as non-compliant if the value doesn't match
            $nonCompliantReasons += "$key`: Expected $($complianceCriteria[$key]), Found $($Policy.$key)" # Record the discrepancy
        } else {
            Write-Verbose "$key is compliant."
        }
    }
    # Special case: Ensure PhishThresholdLevel is at least 3
    Write-Verbose "Checking PhishThresholdLevel: Expected at least 3"
    if ($Policy.PSObject.Properties['PhishThresholdLevel'] -and $Policy.PhishThresholdLevel -lt 3) {
        Write-Verbose "Non-compliance detected for PhishThresholdLevel. Found $($Policy.PhishThresholdLevel)"
        $isCompliant = $false                                                  # Mark as non-compliant if threshold is below 3
        $nonCompliantReasons += "PhishThresholdLevel: Expected at least 3, Found $($Policy.PhishThresholdLevel)" # Record the issue
    } else {
        Write-Verbose "PhishThresholdLevel is compliant."
    }
    # Log the reasons for non-compliance if the policy is not compliant
    if (-not $isCompliant) {
        Write-Verbose "Policy $($Policy.Name) is not compliant. Reasons: $($nonCompliantReasons -join '; ')"
    } else {
        Write-Verbose "Policy $($Policy.Name) is fully compliant."
    }
    # Return whether the policy is compliant
    return $isCompliant
}
