# Automation Candidates

## 5.1.1.1 (L1) Ensure Security Defaults is disabled on Azure Active Directory

- `Connect-MgGraph -Scopes "Policy.Read.All"`
- `Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy | ft IsEnabled`

## 5.1.2.1 (L1) Ensure 'Per-user MFA' is disabled

- `Connect-MsolService`
- Commands:

```powershell
$UserList = Get-MsolUser -All | Where-Object { $_.UserType -eq 'Member' }
$Report = @()
foreach ($user in $UserList) {
    $PerUserMFAState = $null
    if ($user.StrongAuthenticationRequirements) {
        $PerUserMFAState = $user.StrongAuthenticationRequirements.State
    }
    else {
        $PerUserMFAState = 'Disabled'
    }
    $obj = [pscustomobject][ordered]@{
        UserPrincipalName = $User.UserPrincipalName
        DisplayName       = $User.DisplayName
        PerUserMFAState   = $PerUserMFAState
    }
    $Report += $obj
}
$Report
```

## 5.1.3.1 (L1) Ensure a dynamic group for guest users is created

- `Connect-MgGraph -Scopes "Group.Read.All"`
- Commands:

```powershell
$groups = Get-MgGroup | Where-Object { $_.GroupTypes -contains "DynamicMembership" }
$groups | ft DisplayName,GroupTypes,MembershipRule
```

## 6.1.4 (L1) Ensure 'AuditBypassEnabled' is not enabled on mailboxes

- `Connect-ExchangeOnline`
- Commands:

```powershell
$MBX = Get-MailboxAuditBypassAssociation -ResultSize unlimited
$MBX | where {$_.AuditBypassEnabled -eq $true} | Format-Table Name,AuditBypassEnabled
```
