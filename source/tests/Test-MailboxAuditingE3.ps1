function Test-MailboxAuditingE3 {
    [CmdletBinding()]
    param (
        # Aligned
        # Create Table for Details
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        $e3SkuPartNumbers = @("ENTERPRISEPACK", "OFFICESUBSCRIPTION")
        $AdminActions = @("ApplyRecord", "Copy", "Create", "FolderBind", "HardDelete", "Move", "MoveToDeletedItems", "SendAs", "SendOnBehalf", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateFolderPermissions", "UpdateInboxRules")
        $DelegateActions = @("ApplyRecord", "Create", "FolderBind", "HardDelete", "Move", "MoveToDeletedItems", "SendAs", "SendOnBehalf", "SoftDelete", "Update", "UpdateFolderPermissions", "UpdateInboxRules")
        $OwnerActions = @("ApplyRecord", "Create", "HardDelete", "MailboxLogin", "Move", "MoveToDeletedItems", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateFolderPermissions", "UpdateInboxRules")


        $allFailures = @()
        $allUsers = Get-AzureADUser -All $true
        $processedUsers = @{}  # Dictionary to track processed users
        $recnum = "6.1.2"
    }

    process {
        try {
            foreach ($user in $allUsers) {
                if ($processedUsers.ContainsKey($user.UserPrincipalName)) {
                    Write-Verbose "Skipping already processed user: $($user.UserPrincipalName)"
                    continue
                }

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

            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($allFailures.Count -eq 0) { "N/A" } else { "Audit issues detected." }
            $details = if ($allFailures.Count -eq 0) { "All Office E3 users have correct mailbox audit settings." } else { $allFailures -join " | " }

            # Populate the audit result
            $params = @{
                Rec           = $recnum
                Result        = $allFailures.Count -eq 0
                Status        = if ($allFailures.Count -eq 0) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params

        }
        catch {
            Write-Error "An error occurred during the test: $_"

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        return $auditResult
    }
}
