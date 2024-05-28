function Test-MailboxAuditingE5 {
    [CmdletBinding()]
    param (
        # Aligned
        # Create Table for Details
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        $e5SkuPartNumbers = @("SPE_E5", "ENTERPRISEPREMIUM", "OFFICEE5")
        $AdminActions = @("ApplyRecord", "Copy", "Create", "FolderBind", "HardDelete", "MailItemsAccessed", "Move", "MoveToDeletedItems", "SendAs", "SendOnBehalf", "Send", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateFolderPermissions", "UpdateInboxRules")
        $DelegateActions = @("ApplyRecord", "Create", "FolderBind", "HardDelete", "MailItemsAccessed", "Move", "MoveToDeletedItems", "SendAs", "SendOnBehalf", "SoftDelete", "Update", "UpdateFolderPermissions", "UpdateInboxRules")
        $OwnerActions = @("ApplyRecord", "Create", "HardDelete", "MailboxLogin", "Move", "MailItemsAccessed", "MoveToDeletedItems", "Send", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateFolderPermissions", "UpdateInboxRules")



        $allFailures = @()
        $allUsers = Get-AzureADUser -All $true
        $processedUsers = @{}  # Dictionary to track processed users
    }

    process {
        foreach ($user in $allUsers) {
            if ($processedUsers.ContainsKey($user.UserPrincipalName)) {
                continue
            }

            try {
                $licenseDetails = Get-MgUserLicenseDetail -UserId $user.UserPrincipalName
                $hasOfficeE5 = ($licenseDetails | Where-Object { $_.SkuPartNumber -in $e5SkuPartNumbers }).Count -gt 0
                Write-Verbose "Evaluating user $($user.UserPrincipalName) for Office E5 license."
                if ($hasOfficeE5) {
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
                    else {
                        Write-Verbose "User $($user.UserPrincipalName) passed the mailbox audit checks."
                    }
                    $processedUsers[$user.UserPrincipalName] = $true
                }
                else {
                    # Adding verbose output to indicate the user does not have an E5 license
                    Write-Verbose "User $($user.UserPrincipalName) does not have an Office E5 license."
                }
            }
            catch {
                Write-Warning "Could not retrieve license details for user $($user.UserPrincipalName): $_"
            }
        }

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($allFailures.Count -eq 0) { "N/A" } else { "Audit issues detected." }
        $details = if ($allFailures.Count -eq 0) { "All Office E5 users have correct mailbox audit settings." } else { $allFailures -join " | " }

        # Populate the audit result
        $params = @{
            Rec            = "6.1.3"
            Result         = $allFailures.Count -eq 0
            Status         = if ($allFailures.Count -eq 0) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure mailbox auditing for Office E5 users is Enabled"
            CISControl     = "8.2"
            CISDescription = "Collect audit logs."
        }
        $auditResult = Initialize-CISAuditResult @params
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
