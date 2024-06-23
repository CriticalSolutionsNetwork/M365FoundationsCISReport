function Test-MailboxAuditingE5 {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Conditions for 6.1.3 (L1) Ensure mailbox auditing for E5 users is Enabled
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: Mailbox auditing is enabled for E5 users.
        #   - Condition B: AuditAdmin actions include ApplyRecord, Create, HardDelete, MailItemsAccessed, MoveToDeletedItems, Send, SendAs, SendOnBehalf, SoftDelete, Update, UpdateCalendarDelegation, UpdateFolderPermissions, UpdateInboxRules.
        #   - Condition C: AuditDelegate actions include ApplyRecord, Create, HardDelete, MailItemsAccessed, MoveToDeletedItems, SendAs, SendOnBehalf, SoftDelete, Update, UpdateFolderPermissions, UpdateInboxRules.
        #   - Condition D: AuditOwner actions include ApplyRecord, HardDelete, MailItemsAccessed, MoveToDeletedItems, Send, SoftDelete, Update, UpdateCalendarDelegation, UpdateFolderPermissions, UpdateInboxRules.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: Mailbox auditing is not enabled for E5 users.
        #   - Condition B: AuditAdmin actions do not include all of the following: ApplyRecord, Create, HardDelete, MailItemsAccessed, MoveToDeletedItems, Send, SendAs, SendOnBehalf, SoftDelete, Update, UpdateCalendarDelegation, UpdateFolderPermissions, UpdateInboxRules.
        #   - Condition C: AuditDelegate actions do not include all of the following: ApplyRecord, Create, HardDelete, MailItemsAccessed, MoveToDeletedItems, SendAs, SendOnBehalf, SoftDelete, Update, UpdateFolderPermissions, UpdateInboxRules.
        #   - Condition D: AuditOwner actions do not include all of the following: ApplyRecord, HardDelete, MailItemsAccessed, MoveToDeletedItems, Send, SoftDelete, Update, UpdateCalendarDelegation, UpdateFolderPermissions, UpdateInboxRules.

        $actionDictionaries = Get-Action -Dictionaries
        $AdminActions = $actionDictionaries.AdminActions.Keys
        $DelegateActions = $actionDictionaries.DelegateActions.Keys
        $OwnerActions = $actionDictionaries.OwnerActions.Keys

        $allFailures = @()
        $processedUsers = @{}
        $recnum = "6.1.3"
        $allUsers = Get-MgOutput -Rec $recnum
    }

    process {
        if ($null -ne $allUsers) {
            $mailboxes = Get-ExoOutput -Rec $recnum
            try {
                foreach ($user in $allUsers) {
                    if ($processedUsers.ContainsKey($user.UserPrincipalName)) {
                        Write-Verbose "Skipping already processed user: $($user.UserPrincipalName)"
                        continue
                    }

                    $mailbox = $mailboxes | Where-Object { $_.UserPrincipalName -eq $user.UserPrincipalName }
                    $userUPN = $user.UserPrincipalName

                    $missingAdminActions = @()
                    $missingDelegateActions = @()
                    $missingOwnerActions = @()

                    if ($mailbox.AuditEnabled) {
                        # Validate Admin actions
                        foreach ($action in $AdminActions) {
                            if ($mailbox.AuditAdmin -notcontains $action) {
                                $missingAdminActions += (Get-Action -Actions $action -ActionType "Admin") # Condition B
                            }
                        }
                        # Validate Delegate actions
                        foreach ($action in $DelegateActions) {
                            if ($mailbox.AuditDelegate -notcontains $action) {
                                $missingDelegateActions += (Get-Action -Actions $action -ActionType "Delegate") # Condition C
                            }
                        }
                        # Validate Owner actions
                        foreach ($action in $OwnerActions) {
                            if ($mailbox.AuditOwner -notcontains $action) {
                                $missingOwnerActions += (Get-Action -Actions $action -ActionType "Owner") # Condition D
                            }
                        }

                        if ($missingAdminActions.Count -gt 0 -or $missingDelegateActions.Count -gt 0 -or $missingOwnerActions.Count -gt 0) {
                            $allFailures += "$userUPN|True|$($missingAdminActions -join ',')|$($missingDelegateActions -join ',')|$($missingOwnerActions -join ',')"
                        }
                    }
                    else {
                        $allFailures += "$userUPN|False|||" # Condition A for fail
                    }

                    # Mark the user as processed
                    $processedUsers[$user.UserPrincipalName] = $true
                }

                # Prepare failure reasons and details based on compliance
                if ($allFailures.Count -eq 0) {
                    $failureReasons = "N/A"
                }
                else {
                    $failureReasons = "Audit issues detected."
                }
                $details = if ($allFailures.Count -eq 0) {
                    "All Office E5 users have correct mailbox audit settings." # Condition A for pass
                }
                else {
                    "UserPrincipalName|AuditEnabled|AdminActionsMissing|DelegateActionsMissing|OwnerActionsMissing`n" + ($allFailures -join "`n") # Condition A for fail
                }
                # $details = Initialize-LargeTestTable -lineCount 3000 # Adjust the lineCount to exceed 32,000 characters
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
        else {
            $params = @{
                Rec           = $recnum
                Result        = $false
                Status        = "Fail"
                Details       = "No M365 E5 licenses found."
                FailureReason = "The audit is for M365 E5 licenses, but no such licenses were found."
            }
            $auditResult = Initialize-CISAuditResult @params
        }
    }

    end {
        $detailsLength = $details.Length
        Write-Verbose "Character count of the details: $detailsLength"

        if ($detailsLength -gt 32767) {
            Write-Verbose "Warning: The character count exceeds the limit for Excel cells."
        }

        return $auditResult
    }
}