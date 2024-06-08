function Test-MailboxAuditingE3 {
    [CmdletBinding()]
    param (
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
