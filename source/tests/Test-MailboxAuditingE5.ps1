function Test-MailboxAuditingE5 {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
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
        $recnum = "6.1.3"
    }

    process {
        try {
            foreach ($user in $allUsers) {
                if ($processedUsers.ContainsKey($user.UserPrincipalName)) {
                    Write-Verbose "Skipping already processed user: $($user.UserPrincipalName)"
                    continue
                }

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

                        if ($missingActions.Count -gt 0) {
                            $formattedActions = Format-MissingActions -missingActions $missingActions
                            $allFailures += "$userUPN|True|$($formattedActions.Admin)|$($formattedActions.Delegate)|$($formattedActions.Owner)"
                        }
                    }
                    else {
                        $allFailures += "$userUPN|False|||"
                    }

                    # Mark the user as processed
                    $processedUsers[$user.UserPrincipalName] = $true
                }
            }

            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($allFailures.Count -eq 0) { "N/A" } else { "Audit issues detected." }
            $details = if ($allFailures.Count -eq 0) {
                "All Office E5 users have correct mailbox audit settings."
            }
            else {
                "UserPrincipalName|AuditEnabled|AdminActionsMissing|DelegateActionsMissing|OwnerActionsMissing`n" + ($allFailures -join "`n")
            }

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

            # Retrieve the description from the test definitions
            $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
            $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }

            $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        #$verbosePreference = 'Continue'
        $detailsLength = $details.Length
        Write-Verbose "Character count of the details: $detailsLength"

        if ($detailsLength -gt 32767) {
            Write-Verbose "Warning: The character count exceeds the limit for Excel cells."
        }
        #$verbosePreference = 'SilentlyContinue'
        return $auditResult
    }
}
