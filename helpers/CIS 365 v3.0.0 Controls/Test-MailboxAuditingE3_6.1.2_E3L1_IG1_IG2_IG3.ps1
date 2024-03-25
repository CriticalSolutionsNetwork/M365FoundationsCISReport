function Test-MailboxAuditingE3_6.1.2_E3L1_IG1_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        . ".\source\Classes\CISAuditResult.ps1"
        $e3SkuPartNumbers = @("ENTERPRISEPACK", "OFFICESUBSCRIPTION")
        $AdminActions = @("ApplyRecord", "Copy", "Create", "FolderBind", "HardDelete", "Move", "MoveToDeletedItems", "SendAs", "SendOnBehalf", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateFolderPermissions", "UpdateInboxRules")
        $DelegateActions = @("ApplyRecord", "Create", "FolderBind", "HardDelete", "Move", "MoveToDeletedItems", "SendAs", "SendOnBehalf", "SoftDelete", "Update", "UpdateFolderPermissions", "UpdateInboxRules")
        $OwnerActions = @("ApplyRecord", "Create", "HardDelete", "MailboxLogin", "Move", "MoveToDeletedItems", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateFolderPermissions", "UpdateInboxRules")
        $auditResult = [CISAuditResult]::new()
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L1"
        $auditResult.Rec = "6.1.2"
        $auditResult.RecDescription = "Ensure mailbox auditing for Office E3 users is Enabled"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "8.2"
        $auditResult.CISDescription = "Collect audit logs."
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true

        $allFailures = @()
        $allUsers = Get-AzureADUser -All $true
        $processedUsers = @{}  # Dictionary to track processed users
    }

    process {
        foreach ($user in $allUsers) {
            if ($processedUsers.ContainsKey($user.UserPrincipalName)) {
                Write-Verbose "Skipping already processed user: $($user.UserPrincipalName)"
                continue
            }
            try {
                $licenseDetails = Get-MgUserLicenseDetail -UserId $user.UserPrincipalName
                $hasOfficeE3 = ($licenseDetails | Where-Object { $_.SkuPartNumber -in $e3SkuPartNumbers }).Count -gt 0
                Write-Verbose "Evaluating user $($user.UserPrincipalName) for Office E3 license."

                if ($hasOfficeE3) {
                    $userUPN = $user.UserPrincipalName
                    $mailbox = Get-EXOMailbox -Identity $userUPN -PropertySets Audit

                    $missingActions = @()
                    if ($mailbox.AuditEnabled) {
                        foreach ($action in $AdminActions) {
                            if ($mailbox.AuditAdmin -notcontains $action) { $missingActions += "Admin action '$action' missing" }
                        }
                        foreach ($action in $DelegateActions) {
                            if ($mailbox.AuditDelegate -notcontains $action) { $missingActions += "Delegate action '$action' missing" }
                        }
                        foreach ($action in $OwnerActions) {
                            if ($mailbox.AuditOwner -notcontains $action) { $missingActions += "Owner action '$action' missing" }
                        }
                    }
                    else {
                        $allFailures += "$userUPN`: AuditEnabled - False"
                        continue
                    }

                    if ($missingActions) {
                        $formattedActions = Format-MissingActions $missingActions
                        $allFailures += "$userUPN`: AuditEnabled - True; $formattedActions"
                    }
                    # Mark the user as processed
                    $processedUsers[$user.UserPrincipalName] = $true
                }
            }
            catch {
                Write-Warning "Could not retrieve license details for user $($user.UserPrincipalName): $_"
            }
        }

        $auditResult.Result = $allFailures.Count -eq 0
        $auditResult.Status = if ($auditResult.Result) { "Pass" } else { "Fail" }
        $auditResult.Details = if ($auditResult.Result) { "All Office E3 users have correct mailbox audit settings." } else { $allFailures -join " | " }
        $auditResult.FailureReason = if (-not $auditResult.Result) { "Audit issues detected." } else { "N/A" }
    }

    end {
        return $auditResult
    }
}

function Format-MissingActions {
    param ([array]$missingActions)

    $actionGroups = @{
        "Admin"    = @()
        "Delegate" = @()
        "Owner"    = @()
    }

    foreach ($action in $missingActions) {
        if ($action -match "(Admin|Delegate|Owner) action '([^']+)' missing") {
            $type = $matches[1]
            $actionName = $matches[2]
            $actionGroups[$type] += $actionName
        }
    }

    $formattedResults = @()
    foreach ($type in $actionGroups.Keys) {
        if ($actionGroups[$type].Count -gt 0) {
            $formattedResults += "$($type) actions missing: $($actionGroups[$type] -join ', ')"
        }
    }

    return $formattedResults -join '; '
}
