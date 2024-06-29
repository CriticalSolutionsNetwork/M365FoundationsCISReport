function Test-PhishPolicyCompliance {
    param ($policy)
    return ($policy.Enabled -eq $true -and
        $policy.PhishThresholdLevel -ge 2 -and
        $policy.EnableMailboxIntelligenceProtection -eq $true -and
        $policy.EnableMailboxIntelligence -eq $true -and
        $policy.EnableSpoofIntelligence -eq $true)
}