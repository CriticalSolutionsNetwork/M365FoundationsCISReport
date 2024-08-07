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
        $recnum = "6.1.2"
        $version = $recnum
        $actionDictionaries = Get-Action -Dictionaries -Version $version
        # E3 specific actions
        $AdminActions = $actionDictionaries.AdminActions.Keys
        $DelegateActions = $actionDictionaries.DelegateActions.Keys
        $OwnerActions = $actionDictionaries.OwnerActions.Keys
        $allFailures = @()

        Write-Verbose "Running Test-MailboxAuditingE3 for $recnum..."
        $allUsers = Get-CISMgOutput -Rec $recnum
        $processedUsers = @{}  # Dictionary to track processed users
    }
    process {
        if ($null -ne $allUsers) {
            $mailboxes = Get-CISExoOutput -Rec $recnum
            try {
                foreach ($user in $allUsers) {
                    if ($processedUsers.ContainsKey($user.UserPrincipalName)) {
                        Write-Verbose "Skipping already processed user: $($user.UserPrincipalName)"
                        continue
                    }
                    $userUPN = $user.UserPrincipalName
                    $mailbox = $mailboxes | Where-Object { $_.UserPrincipalName -eq $user.UserPrincipalName }
                    $missingAdminActions = @()
                    $missingDelegateActions = @()
                    $missingOwnerActions = @()
                    if ($mailbox.AuditEnabled) {
                        foreach ($action in $AdminActions) {
                            if ($mailbox.AuditAdmin -notcontains $action) {
                                $missingAdminActions += (Get-Action -Actions $action -ActionType "Admin" -Version $version)
                            }
                        }
                        foreach ($action in $DelegateActions) {
                            if ($mailbox.AuditDelegate -notcontains $action) {
                                $missingDelegateActions += (Get-Action -Actions $action -ActionType "Delegate" -Version $version)
                            }
                        }
                        foreach ($action in $OwnerActions) {
                            if ($mailbox.AuditOwner -notcontains $action) {
                                $missingOwnerActions += (Get-Action -Actions $action -ActionType "Owner" -Version $version)
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
                Write-Error "An error occurred during the test $recnum`:: $_"
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
        $detailsLength = $details.Length
        Write-Verbose "Character count of the details: $detailsLength"
        if ($detailsLength -gt 32767) {
            Write-Verbose "Warning: The character count exceeds the limit for Excel cells."
        }
        return $auditResult
    }
}
