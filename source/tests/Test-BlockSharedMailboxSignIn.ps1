function Test-BlockSharedMailboxSignIn {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 1.2.2 (L1) Ensure sign-in to shared mailboxes is blocked
        # Pass if all shared mailboxes have AccountEnabled set to False.
        # Fail if any shared mailbox has AccountEnabled set to True.
        # Review: Details property - Add verbosity.

        $MBX = Get-EXOMailbox -RecipientTypeDetails SharedMailbox
        $sharedMailboxDetails = $MBX | ForEach-Object { Get-AzureADUser -ObjectId $_.ExternalDirectoryObjectId }
        $enabledMailboxes = $sharedMailboxDetails | Where-Object { $_.AccountEnabled } | ForEach-Object { $_.DisplayName }
        $allBlocked = $enabledMailboxes.Count -eq 0

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # Control is explicitly not mapped
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "1.2.2"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Control is not mapped, hence IG1 is false
        $auditResult.IG2 = $false # Control is not mapped, hence IG2 is false
        $auditResult.IG3 = $false # Control is not mapped, hence IG3 is false
        $auditResult.RecDescription = "Ensure sign-in to shared mailboxes is blocked"
        $auditResult.Result = $allBlocked
        $auditResult.Details = "Enabled Mailboxes: $($enabledMailboxes -join ', ')"
        $auditResult.FailureReason = if ($allBlocked) { "N/A" } else { "Some mailboxes have sign-in enabled: $($enabledMailboxes -join ', ')" }
        $auditResult.Status = if ($allBlocked) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
