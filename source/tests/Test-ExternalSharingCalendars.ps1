function Test-ExternalSharingCalendars {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $RecNum = "1.3.3"

        # Conditions for 1.3.3 (L2) Ensure 'External sharing' of calendars is not available (Automated)
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: In the Microsoft 365 admin center, external calendar sharing is disabled.
        #   - Condition B: Using the Exchange Online PowerShell Module, the `OrganizationConfig` property `ExternalSharingEnabled` is set to `False`.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: In the Microsoft 365 admin center, external calendar sharing is enabled.
        #   - Condition B: Using the Exchange Online PowerShell Module, the `OrganizationConfig` property `ExternalSharingEnabled` is set to `True`.
    }

    process {
        try {
            # Step: Retrieve sharing policies related to calendar sharing
            $sharingPolicies = Get-CISExoOutput -Rec $RecNum

            # Step (Condition A & B: Pass/Fail): Check if calendar sharing is disabled in all applicable policies
            $isExternalSharingDisabled = $true
            $sharingPolicyDetails = @()
            foreach ($policy in $sharingPolicies) {
                if ($policy.Enabled -eq $true) {
                    $isExternalSharingDisabled = $false
                    $sharingPolicyDetails += "$($policy.Name): Enabled"
                }
            }
            $failureRemediation = @'
# Get all mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Initialize a hashtable to store calendar folder names
$calendarFolders = @{}
# Get the default calendar folder names for all mailboxes
$mailboxes | ForEach-Object {
    $calendarFolderName = [string](Get-EXOMailboxFolderStatistics $_.PrimarySmtpAddress -FolderScope Calendar | Where-Object { $_.FolderType -eq 'Calendar' }).Name
    $calendarFolders[$_.PrimarySmtpAddress] = $calendarFolderName
}
# Get the calendar folder settings for each mailbox
foreach ($mailbox in $mailboxes) {
    $primarySmtpAddress = $mailbox.PrimarySmtpAddress
    $calendarFolder = $calendarFolders[$primarySmtpAddress]
    # Get users calendar folder settings for their default Calendar folder
    $calendar = Get-MailboxCalendarFolder -Identity "$primarySmtpAddress:\$calendarFolder"
    # Check if calendar publishing is enabled and display a message
    if ($calendar.PublishEnabled) {
        Write-Host -ForegroundColor Yellow "Calendar publishing is enabled for $primarySmtpAddress on $($calendar.PublishedCalendarUrl)"
    }
}
'@
            # Step: Prepare failure reasons and details based on compliance (Condition A & B: Fail)
            $failureReasons = if (-not $isExternalSharingDisabled) {
                "Calendar sharing with external users is enabled in one or more policies.`n`n" + `
                "Use the following command to verify which users are sharing calendars prior to disabling:`n`n" + `
                $failureRemediation
            }
            else {
                "N/A"
            }

            # Step: Prepare details for the audit result (Condition A & B: Pass/Fail)
            $details = if ($isExternalSharingDisabled) {
                "Calendar sharing with external users is disabled."
            }
            else {
                "Enabled Sharing Policies: $($sharingPolicyDetails -join ', ')"
            }

            # Step: Create and populate the CISAuditResult object
            $params = @{
                Rec           = $RecNum
                Result        = $isExternalSharingDisabled
                Status        = if ($isExternalSharingDisabled) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -RecNum $RecNum
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
