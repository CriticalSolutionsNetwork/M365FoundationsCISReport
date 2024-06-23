<#
    .SYNOPSIS
        This is a sample Private function only visible within the module.
    .DESCRIPTION
        This sample function is not exported to the module and only return the data passed as parameter.
    .EXAMPLE
        $null = Get-ExoOutput -PrivateData 'NOTHING TO SEE HERE'
    .PARAMETER PrivateData
        The PrivateData parameter is what will be returned without transformation.
#>
function Get-ExoOutput {
    [cmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $Rec
    )
    begin {
        # Begin Block #
        <#
        1.2.2
        1.3.3
        1.3.6
        2.1.1
        2.1.2
        2.1.3
        2.1.4
        2.1.5
        2.1.6
        2.1.7
        2.1.9
        3.1.1
        6.1.1
        6.1.2
        6.1.3
        6.2.1
        6.2.2
        6.2.3
        6.3.1
        6.5.1
        6.5.2
        6.5.3
        8.6.1

        $testNumbers = @('1.2.2', '1.3.3', '1.3.6', '2.1.1', '2.1.2', '2.1.3', '2.1.4', '2.1.5', '2.1.6', '2.1.7', '2.1.9', '3.1.1', '6.1.1', '6.1.2', '6.1.3', '6.2.1', '6.2.2', '6.2.3', '6.3.1', '6.5.1', '6.5.2', '6.5.3', '8.6.1')
    #>
    }
    process {
        switch ($Rec) {
            '1.2.2' {
                # Test-BlockSharedMailboxSignIn.ps1
                $MBX = Get-EXOMailbox -RecipientTypeDetails SharedMailbox
                # [object[]]
                return $MBX
            }
            '1.3.3' {
                # Test-ExternalSharingCalendars.ps1
                # Step: Retrieve sharing policies related to calendar sharing
                $sharingPolicies = Get-SharingPolicy | Where-Object { $_.Domains -like '*CalendarSharing*' }
                # [psobject[]]
                return $sharingPolicies
            }
            '1.3.6' {
                # Test-CustomerLockbox.ps1
                # Step: Retrieve the organization configuration (Condition C: Pass/Fail)
                $orgConfig = Get-OrganizationConfig | Select-Object CustomerLockBoxEnabled
                $customerLockboxEnabled = $orgConfig.CustomerLockBoxEnabled
                # [bool]
                return $customerLockboxEnabled
            }
            '2.1.1' {
                # Test-SafeLinksOfficeApps.ps1
                if (Get-Command Get-SafeLinksPolicy -ErrorAction SilentlyContinue) {
                    # 2.1.1 (L2) Ensure Safe Links for Office Applications is Enabled
                    # Retrieve all Safe Links policies
                    $policies = Get-SafeLinksPolicy
                    # Initialize the details collection
                    $misconfiguredDetails = @()
                    foreach ($policy in $policies) {
                        # Get the detailed configuration of each policy
                        $policyDetails = Get-SafeLinksPolicy -Identity $policy.Name
                        # Check each required property and record failures
                        # Condition A: Checking policy settings
                        $failures = @()
                        if ($policyDetails.EnableSafeLinksForEmail -ne $true) { $failures += "EnableSafeLinksForEmail: False" } # Email: On
                        if ($policyDetails.EnableSafeLinksForTeams -ne $true) { $failures += "EnableSafeLinksForTeams: False" } # Teams: On
                        if ($policyDetails.EnableSafeLinksForOffice -ne $true) { $failures += "EnableSafeLinksForOffice: False" } # Office 365 Apps: On
                        if ($policyDetails.TrackClicks -ne $true) { $failures += "TrackClicks: False" } # Click protection settings: On
                        if ($policyDetails.AllowClickThrough -ne $false) { $failures += "AllowClickThrough: True" } # Do not track when users click safe links: Off
                        # Only add details for policies that have misconfigurations
                        if ($failures.Count -gt 0) {
                            $misconfiguredDetails += "Policy: $($policy.Name); Failures: $($failures -join ', ')"
                        }
                    }
                    # [object[]]
                    return $misconfiguredDetails
                }
                else {
                    return 1
                }
            }
            '2.1.2' {
                # Test-CommonAttachmentFilter.ps1
                # 2.1.2 (L1) Ensure the Common Attachment Types Filter is enabled
                # Condition A: The Common Attachment Types Filter is enabled in the Microsoft 365 Security & Compliance Center.
                # Condition B: Using Exchange Online PowerShell, verify that the `EnableFileFilter` property of the default malware filter policy is set to `True`.
                # Retrieve the attachment filter policy
                $attachmentFilter = Get-MalwareFilterPolicy -Identity Default | Select-Object EnableFileFilter
                $result = $attachmentFilter.EnableFileFilter
                # [bool]
                return $result
            }
            '2.1.3' {
                # Test-NotifyMalwareInternal.ps1
                # 2.1.3 Ensure notifications for internal users sending malware is Enabled
                # Retrieve all 'Custom' malware filter policies and check notification settings
                $malwareNotifications = Get-MalwareFilterPolicy | Where-Object { $_.RecommendedPolicyType -eq 'Custom' }
                # [object[]]
                return $malwareNotifications
            }
            '2.1.4' {
                # Test-SafeAttachmentsPolicy.ps1
                if (Get-Command Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue) {
                    # Retrieve all Safe Attachment policies where Enable is set to True
                    # Check if ErrorAction needed below
                    $safeAttachmentPolicies = Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Enable -eq $true }
                    # [object[]]
                    return $safeAttachmentPolicies
                    else {
                        return 1
                    }
                }
            }
            '2.1.5' {
                # Test-SafeAttachmentsTeams.ps1
                if (Get-Command Get-AtpPolicyForO365 -ErrorAction SilentlyContinue) {
                    # 2.1.5 (L2) Ensure Safe Attachments for SharePoint, OneDrive, and Microsoft Teams is Enabled
                    # Retrieve the ATP policies for Office 365 and check Safe Attachments settings
                    $atpPolicies = Get-AtpPolicyForO365
                    # Check if the required ATP policies are enabled
                    $atpPolicyResult = $atpPolicies | Where-Object {
                        $_.EnableATPForSPOTeamsODB -eq $true -and
                        $_.EnableSafeDocs -eq $true -and
                        $_.AllowSafeDocsOpen -eq $false
                    }
                    # [psobject[]]
                    return $atpPolicyResult
                }
                else {
                    return 1
                }
            }
            '2.1.6' {
                # Test-SpamPolicyAdminNotify.ps1
                # Retrieve the default hosted outbound spam filter policy
                $hostedOutboundSpamFilterPolicy = Get-HostedOutboundSpamFilterPolicy | Where-Object { $_.IsDefault -eq $true }
                return $hostedOutboundSpamFilterPolicy
            }
            '2.1.7' {
                # Test-AntiPhishingPolicy.ps1
                # Condition A: Ensure that an anti-phishing policy has been created
                $antiPhishPolicies = Get-AntiPhishPolicy
                return $antiPhishPolicies
            }
            '2.1.9' {
                # Test-EnableDKIM.ps1
                # 2.1.9 (L1) Ensure DKIM is enabled for all Exchange Online Domains
                # Retrieve DKIM configuration for all domains
                $dkimConfig = Get-DkimSigningConfig | Select-Object Domain, Enabled
                # [object[]]
                return $dkimConfig
            }
            '3.1.1' {
                # Test-AuditLogSearch.ps1
                # 3.1.1 (L1) Ensure Microsoft 365 audit log search is Enabled
                # Retrieve the audit log configuration
                $auditLogConfig = Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled
                #
                $auditLogResult = $auditLogConfig.UnifiedAuditLogIngestionEnabled
                # [bool]
                return $auditLogResult
            }
            '6.1.1' {
                # Test-AuditDisabledFalse.ps1
                # 6.1.1 (L1) Ensure 'AuditDisabled' organizationally is set to 'False'
                # Retrieve the AuditDisabled configuration (Condition B)
                $auditDisabledConfig = Get-OrganizationConfig | Select-Object AuditDisabled
                # [bool]
                $auditNotDisabled = -not $auditDisabledConfig.AuditDisabled
                return $auditNotDisabled
            }
            '6.1.2' {
                # Test-MailboxAuditingE3.ps1
                $mailboxes = Get-EXOMailbox -PropertySets Audit
                # [object[]]
                return $mailboxes
            }
            '6.1.3' {
                # Test-MailboxAuditingE5.ps1
                $mailboxes = Get-EXOMailbox -PropertySets Audit
                # [object[]]
                return $mailboxes
            }
            '6.2.1' {
                # Test-BlockMailForwarding.ps1
                # 6.2.1 (L1) Ensure all forms of mail forwarding are blocked and/or disabled
                # Step 1: Retrieve the transport rules that redirect messages
                $transportRules = Get-TransportRule | Where-Object { $null -ne $_.RedirectMessageTo }
                if ($null -eq $transportRules) {
                    $transportRules = 1
                }
                # Step 2: Check all anti-spam outbound policies
                $outboundSpamPolicies = Get-HostedOutboundSpamFilterPolicy
                $nonCompliantSpamPolicies = $outboundSpamPolicies | Where-Object { $_.AutoForwardingMode -ne 'Off' }
                return $transportRules, $nonCompliantSpamPolicies
            }
            '6.2.2' {
                # Test-NoWhitelistDomains.ps1
                # 6.2.2 (L1) Ensure mail transport rules do not whitelist specific domains
                # Retrieve transport rules that whitelist specific domains
                # Condition A: Checking for transport rules that whitelist specific domains
                # [object[]]
                $whitelistedRules = Get-TransportRule | Where-Object { $_.SetSCL -eq -1 -and $null -ne $_.SenderDomainIs }
                return $whitelistedRules
            }
            '6.2.3' {
                # Test-IdentifyExternalEmail.ps1
                # 6.2.3 (L1) Ensure email from external senders is identified
                # Retrieve external sender tagging configuration
                # [object[]]
                $externalInOutlook = Get-ExternalInOutlook
                return $externalInOutlook
            }
            '6.3.1' {
                # Test-RestrictOutlookAddins.ps1
                # 6.3.1 (L2) Ensure users installing Outlook add-ins is not allowed
                $customPolicyFailures = @()
                # Check all mailboxes for custom policies with unallowed add-ins
                $roleAssignmentPolicies = Get-EXOMailbox | Select-Object -Unique RoleAssignmentPolicy
                if ($roleAssignmentPolicies.RoleAssignmentPolicy) {
                    foreach ($policy in $roleAssignmentPolicies) {
                        if ($policy.RoleAssignmentPolicy) {
                            $rolePolicyDetails = Get-RoleAssignmentPolicy -Identity $policy.RoleAssignmentPolicy
                            $foundRoles = $rolePolicyDetails.AssignedRoles | Where-Object { $_ -in $relevantRoles }
                            # Condition B: Using PowerShell, verify that MyCustomApps, MyMarketplaceApps, and MyReadWriteMailboxApps are not assigned to users.
                            if ($foundRoles) {
                                $customPolicyFailures += "Policy: $($policy.RoleAssignmentPolicy): Roles: $($foundRoles -join ', ')"
                            }
                        }
                    }
                }
                # Check Default Role Assignment Policy
                $defaultPolicy = Get-RoleAssignmentPolicy "Default Role Assignment Policy"
                return $customPolicyFailures, $defaultPolicy
            }
            '6.5.1' {
                # Test-ModernAuthExchangeOnline.ps1
                # Ensuring the ExchangeOnlineManagement module is available
                # 6.5.1 (L1) Ensure modern authentication for Exchange Online is enabled
                # Check modern authentication setting in Exchange Online configuration (Condition A and B)
                $orgConfig = Get-OrganizationConfig | Select-Object -Property Name, OAuth2ClientProfileEnabled
                return $orgConfig
            }
            '6.5.2' {
                # Test-MailTipsEnabled.ps1
                # 6.5.2 (L2) Ensure MailTips are enabled for end users
                # Retrieve organization configuration for MailTips settings
                # [object]
                $orgConfig = Get-OrganizationConfig | Select-Object MailTipsAllTipsEnabled, MailTipsExternalRecipientsTipsEnabled, MailTipsGroupMetricsEnabled, MailTipsLargeAudienceThreshold
                return $orgConfig
            }
            '6.5.3' {
                # Test-RestrictStorageProvidersOutlook.ps1
                # 6.5.3 (L2) Ensure additional storage providers are restricted in Outlook on the web
                # Retrieve all OwaMailbox policies
                # [object[]]
                $owaPolicies = Get-OwaMailboxPolicy
                return $owaPolicies
            }
            '8.6.1' {
                # Test-ReportSecurityInTeams.ps1
                # 8.6.1 (L1) Ensure users can report security concerns in Teams
                # Retrieve the necessary settings for Teams and Exchange Online
                # Condition B: Verify that 'Monitor reported messages in Microsoft Teams' is checked in the Microsoft 365 Defender portal.
                # Condition C: Ensure the 'Send reported messages to' setting in the Microsoft 365 Defender portal is set to 'My reporting mailbox only' with the correct report email addresses.
                $ReportSubmissionPolicy = Get-ReportSubmissionPolicy | Select-Object -Property ReportJunkToCustomizedAddress, ReportNotJunkToCustomizedAddress, ReportPhishToCustomizedAddress, ReportChatMessageToCustomizedAddressEnabled
                return $ReportSubmissionPolicy
            }
            default { throw "No match found for test: $Rec" }
        }
    }
    end {
        Write-Verbose "Retuning data for Rec: $Rec"
    }
} # end function Get-MgOutput

