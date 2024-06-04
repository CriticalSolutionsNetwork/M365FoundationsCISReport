function Test-BlockSharedMailboxSignIn {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "1.2.2"
    }

    process {

        try {
            # 1.2.2 (L1) Ensure sign-in to shared mailboxes is blocked

            # Retrieve shared mailbox details
            $MBX = Get-EXOMailbox -RecipientTypeDetails SharedMailbox
            $sharedMailboxDetails = $MBX | ForEach-Object { Get-AzureADUser -ObjectId $_.ExternalDirectoryObjectId }
            $enabledMailboxes = $sharedMailboxDetails | Where-Object { $_.AccountEnabled } | ForEach-Object { $_.DisplayName }
            $allBlocked = $enabledMailboxes.Count -eq 0

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $allBlocked) {
                "Some mailboxes have sign-in enabled: $($enabledMailboxes -join ', ')"
            }
            else {
                "N/A"
            }

            $details = if ($allBlocked) {
                "All shared mailboxes have sign-in blocked."
            }
            else {
                "Enabled Mailboxes: $($enabledMailboxes -join ', ')"
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $allBlocked
                Status        = if ($allBlocked) { "Pass" } else { "Fail" }
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
        # Return the audit result
        return $auditResult
    }
}
