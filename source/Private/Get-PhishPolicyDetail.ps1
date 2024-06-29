function Get-PhishPolicyDetail {
    param (
        [Parameter(Mandatory = $true)]
        [pscustomobject]$policy,

        [Parameter(Mandatory = $true)]
        [bool]$isCompliant
    )

    return "Policy: $($policy.Identity)`n" +
    "Enabled: $($policy.Enabled)`n" +
    "PhishThresholdLevel: $($policy.PhishThresholdLevel)`n" +
    "MailboxIntelligenceProtection: $($policy.EnableMailboxIntelligenceProtection)`n" +
    "MailboxIntelligence: $($policy.EnableMailboxIntelligence)`n" +
    "SpoofIntelligence: $($policy.EnableSpoofIntelligence)`n" +
    "TargetedUsersToProtect: $($policy.TargetedUsersToProtect -join ', ')`n" +
    "IsCompliant: $isCompliant"
}