function Test-MailboxAuditingE3 {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Parameters can be added if needed
    )

    begin {
        <#
        Conditions for 6.1.2 (L1) Ensure mailbox auditing for E3 users is Enabled

        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
          - Condition A: Mailbox audit logging is enabled for all user mailboxes.
          - Condition B: The `AuditAdmin` actions include `ApplyRecord`, `Create`, `HardDelete`, `MoveToDeletedItems`, `SendAs`, `SendOnBehalf`, `SoftDelete`, `Update`, `UpdateCalendarDelegation`, `UpdateFolderPermissions`, and `UpdateInboxRules`.
          - Condition C: The `AuditDelegate` actions include `ApplyRecord`, `Create`, `HardDelete`, `MoveToDeletedItems`, `SendAs`, `SendOnBehalf`, `SoftDelete`, `Update`, `UpdateFolderPermissions`, and `UpdateInboxRules`.
          - Condition D: The `AuditOwner` actions include `ApplyRecord`, `HardDelete`, `MoveToDeletedItems`, `SoftDelete`, `Update`, `UpdateCalendarDelegation`, `UpdateFolderPermissions`, and `UpdateInboxRules`.

        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
          - Condition A: Mailbox audit logging is not enabled for all user mailboxes.
          - Condition B: The `AuditAdmin` actions do not include `ApplyRecord`, `Create`, `HardDelete`, `MoveToDeletedItems`, `SendAs`, `SendOnBehalf`, `SoftDelete`, `Update`, `UpdateCalendarDelegation`, `UpdateFolderPermissions`, and `UpdateInboxRules`.
          - Condition C: The `AuditDelegate` actions do not include `ApplyRecord`, `Create`, `HardDelete`, `MoveToDeletedItems`, `SendAs`, `SendOnBehalf`, `SoftDelete`, `Update`, `UpdateFolderPermissions`, and `UpdateInboxRules`.
          - Condition D: The `AuditOwner` actions do not include `ApplyRecord`, `HardDelete`, `MoveToDeletedItems`, `SoftDelete`, `Update`, `UpdateCalendarDelegation`, `UpdateFolderPermissions`, and `UpdateInboxRules`.
        #>

        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        $e3SkuPartNumber = "SPE_E3"
        $AdminActions = @("ApplyRecord", "Copy", "Create", "FolderBind", "HardDelete", "Move", "MoveToDeletedItems", "SendAs", "SendOnBehalf", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateFolderPermissions", "UpdateInboxRules")
        $DelegateActions = @("ApplyRecord", "Create", "FolderBind", "HardDelete", "Move", "MoveToDeletedItems", "SendAs", "SendOnBehalf", "SoftDelete", "Update", "UpdateFolderPermissions", "UpdateInboxRules")
        $OwnerActions = @("ApplyRecord", "Create", "HardDelete", "MailboxLogin", "Move", "MoveToDeletedItems", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateFolderPermissions", "UpdateInboxRules")

        $allFailures = @()
        #$allUsers = Get-AzureADUser -All $true
        $founde3Sku = Get-MgSubscribedSku -All | Where-Object {$_.SkuPartNumber -eq $e3SkuPartNumber}
        $processedUsers = @{}  # Dictionary to track processed users
        $recnum = "6.1.2"
    }


    process {
        if (($founde3Sku.count)-ne 0) {
            $allUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($founde3Sku.SkuId) )" -All
            $mailboxes = Get-EXOMailbox -PropertySets Audit
            try {
                foreach ($user in $allUsers) {
                    if ($processedUsers.ContainsKey($user.UserPrincipalName)) {
                        Write-Verbose "Skipping already processed user: $($user.UserPrincipalName)"
                        continue
                    }

                    #$licenseDetails = Get-MgUserLicenseDetail -UserId $user.UserPrincipalName
                    #$hasOfficeE3 = ($licenseDetails | Where-Object { $_.SkuPartNumber -in $e3SkuPartNumbers }).Count -gt 0
                    #Write-Verbose "Evaluating user $($user.UserPrincipalName) for Office E3 license."

                    $userUPN = $user.UserPrincipalName
                    $mailbox = $mailboxes | Where-Object { $_.UserPrincipalName -eq $user.UserPrincipalName }

                    $missingActions = @()
                    if ($mailbox.AuditEnabled) {
                        foreach ($action in $AdminActions) {
                            # Condition B: Checking if the `AuditAdmin` actions include required actions
                            if ($mailbox.AuditAdmin -notcontains $action) { $missingActions += "Admin action '$action' missing" }
                        }
                        foreach ($action in $DelegateActions) {
                            # Condition C: Checking if the `AuditDelegate` actions include required actions
                            if ($mailbox.AuditDelegate -notcontains $action) { $missingActions += "Delegate action '$action' missing" }
                        }
                        foreach ($action in $OwnerActions) {
                            # Condition D: Checking if the `AuditOwner` actions include required actions
                            if ($mailbox.AuditOwner -notcontains $action) { $missingActions += "Owner action '$action' missing" }
                        }

                        if ($missingActions.Count -gt 0) {
                            $formattedActions = Format-MissingAction -missingActions $missingActions
                            $allFailures += "$userUPN|True|$($formattedActions.Admin)|$($formattedActions.Delegate)|$($formattedActions.Owner)"
                        }
                    }
                    else {
                        # Condition A: Checking if mailbox audit logging is enabled
                        $allFailures += "$userUPN|False|||"
                    }

                    # Mark the user as processed
                    $processedUsers[$user.UserPrincipalName] = $true
                }

                # Prepare failure reasons and details based on compliance
                $failureReasons = if ($allFailures.Count -eq 0) { "N/A" } else { "Audit issues detected." }
                $details = if ($allFailures.Count -eq 0) {
                    "All Office E3 users have correct mailbox audit settings."
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
        else {
            $params = @{
                Rec           = $recnum
                Result        = $false
                Status        = "Fail"
                Details       = "No M365 E3 licenses found."
                FailureReason = "The audit is for M365 E3 licenses, but no such licenses were found."
            }
            $auditResult = Initialize-CISAuditResult @params
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
