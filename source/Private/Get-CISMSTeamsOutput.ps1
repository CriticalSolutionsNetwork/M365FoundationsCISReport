<#
    .SYNOPSIS
        This is a sample Private function only visible within the module.
    .DESCRIPTION
        This sample function is not exported to the module and only return the data passed as parameter.
    .EXAMPLE
        $null = Get-CISMSTeamsOutput -PrivateData 'NOTHING TO SEE HERE'
    .PARAMETER PrivateData
        The PrivateData parameter is what will be returned without transformation.
#>
function Get-CISMSTeamsOutput {
    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Rec
    )
    begin {
        # Begin Block #
        <#
            # Tests
            8.1.1
            8.1.2
            8.2.1
            8.5.1
            8.5.2
            8.5.3
            8.5.4
            8.5.5
            8.5.6
            8.5.7
            8.6.1
            # Test number array
            $testNumbers = @('8.1.1', '8.1.2', '8.2.1', '8.5.1', '8.5.2', '8.5.3', '8.5.4', '8.5.5', '8.5.6', '8.5.7', '8.6.1')
        #>
    }
    process {
        Write-Verbose "Get-CISMSTeamsOutput: Retuning data for Rec: $Rec"
        switch ($Rec) {
            '8.1.1' {
                # Test-TeamsExternalFileSharing.ps1
                # 8.1.1 (L2) Ensure external file sharing in Teams is enabled for only approved cloud storage services
                # Connect to Teams PowerShell using Connect-MicrosoftTeams

                # Condition A: The `AllowDropbox` setting is set to `False`.
                # Condition B: The `AllowBox` setting is set to `False`.
                # Condition C: The `AllowGoogleDrive` setting is set to `False`.
                # Condition D: The `AllowShareFile` setting is set to `False`.
                # Condition E: The `AllowEgnyte` setting is set to `False`.

                # Assuming that 'approvedProviders' is a list of approved cloud storage service names
                # This list must be defined according to your organization's approved cloud storage services
                # Add option for approved providers.
                $clientConfig = Get-CsTeamsClientConfiguration
                return $clientConfig
            }
            '8.1.2' {
                # Test-BlockChannelEmails.ps1
                # 8.1.2 (L1) Ensure users can't send emails to a channel email address
                #
                # Validate test for a pass:
                # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
                # - Specific conditions to check:
                #   - Condition A: The `AllowEmailIntoChannel` setting in Teams is set to `False`.
                #   - Condition B: The setting `Users can send emails to a channel email address` is set to `Off` in the Teams admin center.
                #   - Condition C: Verification using PowerShell confirms that the `AllowEmailIntoChannel` setting is disabled.
                #
                # Validate test for a fail:
                # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
                # - Specific conditions to check:
                #   - Condition A: The `AllowEmailIntoChannel` setting in Teams is not set to `False`.
                #   - Condition B: The setting `Users can send emails to a channel email address` is not set to `Off` in the Teams admin center.
                #   - Condition C: Verification using PowerShell indicates that the `AllowEmailIntoChannel` setting is enabled.

                # Retrieve Teams client configuration
                $teamsClientConfig = Get-CsTeamsClientConfiguration -Identity Global
                return $teamsClientConfig
            }
            '8.2.1' {
                # Test-TeamsExternalAccess.ps1
                # 8.2.1 (L1) Ensure 'external access' is restricted in the Teams admin center
                #
                # Validate test for a pass:
                # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
                # - Specific conditions to check:
                #   - Condition A: The `AllowTeamsConsumer` setting is `False`.
                #   - Condition B: The `AllowPublicUsers` setting is `False`.
                #   - Condition C: The `AllowFederatedUsers` setting is `False` or, if `True`, the `AllowedDomains` contains only authorized domain names.
                #
                # Validate test for a fail:
                # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
                # - Specific conditions to check:
                #   - Condition A: The `AllowTeamsConsumer` setting is not `False`.
                #   - Condition B: The `AllowPublicUsers` setting is not `False`.
                #   - Condition C: The `AllowFederatedUsers` setting is `True` and the `AllowedDomains` contains unauthorized domain names or is not configured correctly.
                # Connect to Teams PowerShell using Connect-MicrosoftTeams
                # $externalAccessConfig Mock Object
                <#
                    $externalAccessConfig = [PSCustomObject]@{
                        Identity                                    = 'Global'
                        AllowedDomains                              = 'AllowAllKnownDomains'
                        BlockedDomains                              = @()
                        AllowFederatedUsers                         = $true
                        AllowPublicUsers                            = $true
                        AllowTeamsConsumer                          = $true
                        AllowTeamsConsumerInbound                   = $true
                    }
                    $ApprovedFederatedDomains = @('msn.com', 'google.com')
                    $externalAccessConfig = [PSCustomObject]@{
                        Identity                                    = 'Global'
                        AllowedDomains                              = @('msn.com', 'google.com')
                        BlockedDomains                              = @()
                        AllowFederatedUsers                         = $true
                        AllowPublicUsers                            = $false
                        AllowTeamsConsumer                          = $false
                        AllowTeamsConsumerInbound                   = $true
                    }
                #>
                $externalAccessConfig = Get-CsTenantFederationConfiguration
                return $externalAccessConfig
            }
            '8.5.1' {
                # Test-NoAnonymousMeetingJoin.ps1
                # 8.5.1 (L2) Ensure anonymous users can't join a meeting
                #
                # Validate test for a pass:
                # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
                # - Specific conditions to check:
                #   - Condition A: `AllowAnonymousUsersToJoinMeeting` is set to `False`.
                #   - Condition B: Verification using the UI confirms that `Anonymous users can join a meeting` is set to `Off` in the Global meeting policy.
                #   - Condition C: PowerShell command output indicates that anonymous users are not allowed to join meetings.
                #
                # Validate test for a fail:
                # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
                # - Specific conditions to check:
                #   - Condition A: `AllowAnonymousUsersToJoinMeeting` is not set to `False`.
                #   - Condition B: Verification using the UI shows that `Anonymous users can join a meeting` is not set to `Off` in the Global meeting policy.
                #   - Condition C: PowerShell command output indicates that anonymous users are allowed to join meetings.

                # Connect to Teams PowerShell using Connect-MicrosoftTeams
                # $teamsMeetingPolicy Mock Object
                <#
                    $teamsMeetingPolicy = [PSCustomObject]@{
                        AllowAnonymousUsersToJoinMeeting            = $true
                    }
                #>
                $teamsMeetingPolicy = Get-CsTeamsMeetingPolicy -Identity Global
                return $teamsMeetingPolicy
            }
            '8.5.2' {
                # Test-NoAnonymousMeetingStart.ps1
                # 8.5.2 (L1) Ensure anonymous users and dial-in callers can't start a meeting
                #
                # Validate test for a pass:
                # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
                # - Specific conditions to check:
                #   - Condition A: The `AllowAnonymousUsersToStartMeeting` setting in the Teams admin center is set to `False`.
                #   - Condition B: The setting for anonymous users and dial-in callers starting a meeting is configured to ensure they must wait in the lobby.
                #   - Condition C: Verification using the UI confirms that the setting `Anonymous users and dial-in callers can start a meeting` is set to `Off`.
                #
                # Validate test for a fail:
                # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
                # - Specific conditions to check:
                #   - Condition A: The `AllowAnonymousUsersToStartMeeting` setting in the Teams admin center is not set to `False`.
                #   - Condition B: The setting for anonymous users and dial-in callers starting a meeting allows them to bypass the lobby.
                #   - Condition C: Verification using the UI indicates that the setting `Anonymous users and dial-in callers can start a meeting` is not set to `Off`.
                # Connect to Teams PowerShell using Connect-MicrosoftTeams
                # $teamsMeetingPolicy Mock Object
                <#
                    $CsTeamsMeetingPolicyAnonymous = [PSCustomObject]@{
                        AllowAnonymousUsersToStartMeeting           = $true
                    }
                #>
                # Retrieve the Teams meeting policy for the global scope and check if anonymous users can start meetings
                $CsTeamsMeetingPolicyAnonymous = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AllowAnonymousUsersToStartMeeting
                return $CsTeamsMeetingPolicyAnonymous
            }
            '8.5.3' {
                # Test-OrgOnlyBypassLobby.ps1
                # 8.5.3 (L1) Ensure only people in my org can bypass the lobby
                #
                # Validate test for a pass:
                # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
                # - Specific conditions to check:
                #   - Condition A: The `AutoAdmittedUsers` setting in the Teams meeting policy is set to `EveryoneInCompanyExcludingGuests`.
                #   - Condition B: The setting for "Who can bypass the lobby" is configured to "People in my org" using the UI.
                #   - Condition C: Verification using the Microsoft Teams admin center confirms that the meeting join & lobby settings are configured as recommended.
                #
                # Validate test for a fail:
                # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
                # - Specific conditions to check:
                #   - Condition A: The `AutoAdmittedUsers` setting in the Teams meeting policy is not set to `EveryoneInCompanyExcludingGuests`.
                #   - Condition B: The setting for "Who can bypass the lobby" is not configured to "People in my org" using the UI.
                #   - Condition C: Verification using the Microsoft Teams admin center indicates that the meeting join & lobby settings are not configured as recommended.

                # Connect to Teams PowerShell using Connect-MicrosoftTeams

                # Retrieve the Teams meeting policy for lobby bypass settings
                $CsTeamsMeetingPolicyLobby = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AutoAdmittedUsers
                return $CsTeamsMeetingPolicyLobby
            }
            '8.5.4' {
                # Test-DialInBypassLobby.ps1
                # 8.5.4 (L1) Ensure users dialing in can't bypass the lobby
                #
                # Validate test for a pass:
                # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
                # - Specific conditions to check:
                #   - Condition A: The `AllowPSTNUsersToBypassLobby` setting in the Global Teams meeting policy is set to `False`.
                #   - Condition B: Verification using the UI in the Microsoft Teams admin center confirms that "People dialing in can't bypass the lobby" is set to `Off`.
                #   - Condition C: Ensure that individuals who dial in by phone must wait in the lobby until admitted by a meeting organizer, co-organizer, or presenter.
                #
                # Validate test for a fail:
                # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
                # - Specific conditions to check:
                #   - Condition A: The `AllowPSTNUsersToBypassLobby` setting in the Global Teams meeting policy is not set to `False`.
                #   - Condition B: Verification using the UI in the Microsoft Teams admin center shows that "People dialing in can't bypass the lobby" is not set to `Off`.
                #   - Condition C: Individuals who dial in by phone are able to join the meeting directly without waiting in the lobby.

                # Retrieve Teams meeting policy for PSTN users
                $CsTeamsMeetingPolicyPSTN = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AllowPSTNUsersToBypassLobby
                return $CsTeamsMeetingPolicyPSTN
            }
            '8.5.5' {
                # Test-MeetingChatNoAnonymous.ps1
                # 8.5.5 (L2) Ensure meeting chat does not allow anonymous users
                #
                # Validate test for a pass:
                # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
                # - Specific conditions to check:
                #   - Condition A: The `MeetingChatEnabledType` setting in Teams is set to `EnabledExceptAnonymous`.
                #   - Condition B: The setting for meeting chat is configured to allow chat for everyone except anonymous users.
                #   - Condition C: Verification using the Teams Admin Center confirms that the meeting chat settings are configured as recommended.
                #
                # Validate test for a fail:
                # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
                # - Specific conditions to check:
                #   - Condition A: The `MeetingChatEnabledType` setting in Teams is not set to `EnabledExceptAnonymous`.
                #   - Condition B: The setting for meeting chat allows chat for anonymous users.
                #   - Condition C: Verification using the Teams Admin Center indicates that the meeting chat settings are not configured as recommended.

                # Retrieve the Teams meeting policy for meeting chat
                $CsTeamsMeetingPolicyChat = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property MeetingChatEnabledType
                return $CsTeamsMeetingPolicyChat
            }
            '8.5.6' {
                # Test-OrganizersPresent.ps1
                # 8.5.6 (L2) Ensure only organizers and co-organizers can present
                #
                # Validate test for a pass:
                # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
                # - Specific conditions to check:
                #   - Condition A: The `DesignatedPresenterRoleMode` setting in the Teams meeting policy is set to `OrganizerOnlyUserOverride`.
                #   - Condition B: Verification using the Teams admin center confirms that the setting "Who can present" is configured to "Only organizers and co-organizers".
                #   - Condition C: Verification using PowerShell confirms that the `DesignatedPresenterRoleMode` is set to `OrganizerOnlyUserOverride`.
                #
                # Validate test for a fail:
                # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
                # - Specific conditions to check:
                #   - Condition A: The `DesignatedPresenterRoleMode` setting in the Teams meeting policy is not set to `OrganizerOnlyUserOverride`.
                #   - Condition B: Verification using the Teams admin center indicates that the setting "Who can present" is not configured to "Only organizers and co-organizers".
                #   - Condition C: Verification using PowerShell indicates that the `DesignatedPresenterRoleMode` is not set to `OrganizerOnlyUserOverride`.

                # Retrieve the Teams meeting policy for presenters
                $CsTeamsMeetingPolicyPresenters = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property DesignatedPresenterRoleMode
                return $CsTeamsMeetingPolicyPresenters
            }
            '8.5.7' {
                # Test-ExternalNoControl.ps1
                # 8.5.7 (L1) Ensure external participants can't give or request control
                #
                # Validate test for a pass:
                # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
                # - Specific conditions to check:
                #   - Condition A: Ensure the `AllowExternalParticipantGiveRequestControl` setting in Teams is set to `False`.
                #   - Condition B: The setting is verified through the Microsoft Teams admin center or via PowerShell command.
                #   - Condition C: Verification using the UI confirms that external participants are unable to give or request control.
                #
                # Validate test for a fail:
                # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
                # - Specific conditions to check:
                #   - Condition A: The `AllowExternalParticipantGiveRequestControl` setting in Teams is not set to `False`.
                #   - Condition B: The setting is verified through the Microsoft Teams admin center or via PowerShell command.
                #   - Condition C: Verification using the UI indicates that external participants can give or request control.

                # Retrieve Teams meeting policy for external participant control
                $CsTeamsMeetingPolicyControl = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -Property AllowExternalParticipantGiveRequestControl
                return $CsTeamsMeetingPolicyControl
            }
            '8.6.1' {
                # Test-ReportSecurityInTeams.ps1
                # 8.6.1 (L1) Ensure users can report security concerns in Teams

                # Retrieve the necessary settings for Teams and Exchange Online
                # Condition A: Ensure the 'Report a security concern' setting in the Teams admin center is set to 'On'.
                $CsTeamsMessagingPolicy = Get-CsTeamsMessagingPolicy -Identity Global | Select-Object -Property AllowSecurityEndUserReporting
                return $CsTeamsMessagingPolicy
            }
            default { throw "No match found for test: $Rec" }
        }
    }
    end {
        Write-Verbose "Retuning data for Rec: $Rec"
    }
} # end function Get-CISMSTeamsOutput

