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
    }

    process {
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
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"  # Control is explicitly not mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "1.2.2"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false  # Control is not mapped, hence IG1 is false
        $auditResult.IG2 = $false  # Control is not mapped, hence IG2 is false
        $auditResult.IG3 = $false  # Control is not mapped, hence IG3 is false
        $auditResult.RecDescription = "Ensure sign-in to shared mailboxes is blocked"
        $auditResult.Result = $allBlocked
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if ($allBlocked) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
