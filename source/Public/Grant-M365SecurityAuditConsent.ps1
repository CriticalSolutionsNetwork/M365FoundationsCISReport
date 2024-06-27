<#
    .SYNOPSIS
    Grants Microsoft Graph permissions for an auditor.
    .DESCRIPTION
        This function grants the specified Microsoft Graph permissions to a user, allowing the user to perform audits. It connects to Microsoft Graph, checks if a service principal exists for the client application, creates it if it does not exist, and then grants the specified permissions. Finally, it assigns the app to the user.
    .PARAMETER UserPrincipalNameForConsent
        The UPN or ID of the user to grant consent for.
    .PARAMETER SkipGraphConnection
        If specified, skips connecting to Microsoft Graph.
    .PARAMETER DoNotDisconnect
        If specified, does not disconnect from Microsoft Graph after granting consent.
    .PARAMETER SkipModuleCheck
        If specified, skips the check for the Microsoft.Graph module.
    .PARAMETER SuppressRevertOutput
        If specified, suppresses the output of the revert commands.
    .EXAMPLE
        Grant-M365SecurityAuditConsent -UserPrincipalNameForConsent user@example.com

        Grants Microsoft Graph permissions to user@example.com for the client application with the specified Application ID.
    .EXAMPLE
        Grant-M365SecurityAuditConsent -UserPrincipalNameForConsent user@example.com -SkipGraphConnection

        Grants Microsoft Graph permissions to user@example.com, skipping the connection to Microsoft Graph.
    .NOTES
        This function requires the Microsoft.Graph module version 2.4.0 or higher.
    .LINK
        https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Grant-M365SecurityAuditConsent
#>
function Grant-M365SecurityAuditConsent {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    [OutputType([void])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Specify the UPN of the user to grant consent for.'
        )]
        [ValidatePattern('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')]
        [String]$UserPrincipalNameForConsent,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip connecting to Microsoft Graph.'
        )]
        [switch]$SkipGraphConnection,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip the check for the Microsoft.Graph module.'
        )]
        [switch]$SkipModuleCheck,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Suppress the output of the revert commands.'
        )]
        [switch]$SuppressRevertOutput,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not disconnect from Microsoft Graph after granting consent.'
        )]
        [switch]$DoNotDisconnect
    )
    begin {
        if (!($SkipModuleCheck)) {
            Assert-ModuleAvailability -ModuleName Microsoft.Graph -RequiredVersion "2.4.0"
        }
        # Adjusted from: https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/grant-consent-single-user?pivots=msgraph-powershell
        # Needed: A user account with a Privileged Role Administrator, Application Administrator, or Cloud Application Administrator
        # The app for which consent is being granted.
        $clientAppId = "14d82eec-204b-4c2f-b7e8-296a70dab67e" # Microsoft Graph PowerShell
        # The API to which access will be granted. Microsoft Graph PowerShell makes API
        # requests to the Microsoft Graph API, so we'll use that here.
        $resourceAppId = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API
        # The permissions to grant.
        $permissions = @("Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All")
        # The user on behalf of whom access will be granted. The app will be able to access
        # the API on behalf of this user.
        $userUpnOrId = $UserPrincipalNameForConsent
    }
    process {
        try {
            if (-not $SkipGraphConnection -and $PSCmdlet.ShouldProcess("Scopes: User.ReadBasic.All, Application.ReadWrite.All, DelegatedPermissionGrant.ReadWrite.All, AppRoleAssignment.ReadWrite.All", "Connect-MgGraph")) {
                # Step 0. Connect to Microsoft Graph PowerShell. We need User.ReadBasic.All to get
                #    users' IDs, Application.ReadWrite.All to list and create service principals,
                #    DelegatedPermissionGrant.ReadWrite.All to create delegated permission grants,
                #    and AppRoleAssignment.ReadWrite.All to assign an app role.
                #    WARNING: These are high-privilege permissions!
                Write-Host "Connecting to Microsoft Graph with scopes: User.ReadBasic.All, Application.ReadWrite.All, DelegatedPermissionGrant.ReadWrite.All, AppRoleAssignment.ReadWrite.All" -ForegroundColor Yellow
                Connect-MgGraph -Scopes ("User.ReadBasic.All Application.ReadWrite.All " + "DelegatedPermissionGrant.ReadWrite.All " + "AppRoleAssignment.ReadWrite.All") -NoWelcome
                $context = Get-MgContext
                Write-Host "Connected to Microsoft Graph with user: $(($context.Account)) with the authtype `"$($context.AuthType)`" for the `"$($context.Environment)`" environment." -ForegroundColor Green
            }
        }
        catch {
            throw "Connection execution aborted: $_"
            break
        }
        try {
            if ($PSCmdlet.ShouldProcess("Create Microsoft Graph API service princial if not found", "New-MgServicePrincipal")) {
                # Step 1. Check if a service principal exists for the client application.
                #     If one doesn't exist, create it.
                $clientSp = Get-MgServicePrincipal -Filter "appId eq '$($clientAppId)'" -ErrorAction SilentlyContinue
                if (-not $clientSp) {
                    Write-Host "Client service principal not found. Creating one." -ForegroundColor Yellow
                    $clientSp = New-MgServicePrincipal -AppId $clientAppId
                }
                $user = Get-MgUser -UserId $userUpnOrId
                if (!($user)) {
                    throw "User with UPN or ID `"$userUpnOrId`" not found."
                }
                Write-Verbose "User: $($user.UserPrincipalName) Found!"
                $resourceSp = Get-MgServicePrincipal -Filter "appId eq '$($resourceAppId)'"
                $scopeToGrant = $permissions -join " "
                $existingGrant = Get-MgOauth2PermissionGrant -Filter "clientId eq '$($clientSp.Id)' and principalId eq '$($user.Id)' and resourceId eq '$($resourceSp.Id)'"
            }
            if (-not $existingGrant -and $PSCmdlet.ShouldProcess("User: $userUpnOrId for Microsoft Graph PowerShell Scopes: $($permissions -join ', ')", "New-MgOauth2PermissionGrant: Granting Consent")) {
                # Step 2. Create a delegated permission that grants the client app access to the
                #     API, on behalf of the user.
                $grant = New-MgOauth2PermissionGrant -ResourceId $resourceSp.Id -Scope $scopeToGrant -ClientId $clientSp.Id -ConsentType "Principal" -PrincipalId $user.Id
                Write-Host "Consent granted to user $($user.UserPrincipalName) for Microsoft Graph API with scopes: $((($grant.Scope) -split ' ') -join ', ')" -ForegroundColor Green
            }
            if ($existingGrant -and $PSCmdlet.ShouldProcess("Update existing Microsoft Graph permissions for user $userUpnOrId", "Update-MgOauth2PermissionGrant")) {
                # Step 2. Update the existing permission grant with the new scopes.
                Write-Host "Updating existing permission grant for user $($user.UserPrincipalName)." -ForegroundColor Yellow
                $updatedGrant = Update-MgOauth2PermissionGrant -PermissionGrantId $existingGrant.Id -Scope $scopeToGrant -Confirm:$false
                Write-Host "Updated permission grant with ID $($updatedGrant.Id) for scopes: $scopeToGrant" -ForegroundColor Green
            }
            if ($PSCmdlet.ShouldProcess("Assigning app to user $userUpnOrId", "New-MgServicePrincipalAppRoleAssignedTo")) {
                # Step 3. Assign the app to the user. This ensures that the user can sign in if assignment
                #     is required, and ensures that the app shows up under the user's My Apps portal.
                if ($clientSp.AppRoles | Where-Object { $_.AllowedMemberTypes -contains "User" }) {
                    Write-Warning "A default app role assignment cannot be created because the client application exposes user-assignable app roles. You must assign the user a specific app role for the app to be listed in the user's My Apps access panel."
                }
                else {
                    # The app role ID 00000000-0000-0000-0000-000000000000 is the default app role
                    # indicating that the app is assigned to the user, but not for any specific
                    # app role.
                    $assignment = New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $clientSp.Id -ResourceId $clientSp.Id -PrincipalId $user.Id -AppRoleId "00000000-0000-0000-0000-000000000000"
                    # $assignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $assignment.ResourceId -All -WhatIf
                }
            }
        }
        catch {
            throw "An error occurred while granting consent:`n$_"
        }
        finally {
            if (!($DoNotDisconnect) -and $PSCmdlet.ShouldProcess("Disconnect from Microsoft Graph", "Disconnect")) {
                # Clean up sessions
                Write-Host "Disconnecting from Microsoft Graph." -ForegroundColor Yellow
                Disconnect-MgGraph | Out-Null
            }
        }
    }
    end {
        if (-not $SuppressRevertOutput -and $PSCmdlet.ShouldProcess("Instructions to undo this change", "Generate Revert Commands")) {
            <#
                # Instructions to revert the changes made by this script
                $resourceAppId = "00000003-0000-0000-c000-000000000000"
                $clientAppId = "14d82eec-204b-4c2f-b7e8-296a70dab67e"
                # Get the user object
                #$user = Get-MgUser -UserId "user@example.com"
                $resourceSp = Get-MgServicePrincipal -Filter "appId eq '$($resourceAppId)'"
                # Get the service principal using $clientAppId
                $clientSp = Get-MgServicePrincipal -Filter "appId eq '$($clientAppId)'"
                $existingGrant = Get-MgOauth2PermissionGrant -Filter "clientId eq '$($clientSp.Id)' and principalId eq '$($user.Id)' and resourceId eq '$($resourceSp.Id)'"
                # Get all app role assignments for the service principal
                $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $clientSp.Id -All
                # At index of desired user assignment
                Remove-MgServicePrincipalAppRoleAssignedTo -AppRoleAssignmentId $appRoleAssignments[1].Id -ServicePrincipalId $clientSp.Id
                Remove-MgOAuth2PermissionGrant -OAuth2PermissionGrantId  $existingGrant.Id
            #>
            Write-Host "App assigned to user $($assignment.PrincipalDisplayName) for $($assignment.ResourceDisplayName) at $($assignment.CreatedDateTime)." -ForegroundColor Green
            Write-Host "If you made a mistake and would like to remove the assignement for `"$($user.UserPrincipalName)`", you can run the following:`n" -ForegroundColor Yellow
            Write-Host "Connect-MgGraph -Scopes (`"User.ReadBasic.All Application.ReadWrite.All `" + `"DelegatedPermissionGrant.ReadWrite.All `" + `"AppRoleAssignment.ReadWrite.All`")" -ForegroundColor Cyan
            Write-Host "Remove-MgServicePrincipalAppRoleAssignedTo -AppRoleAssignmentId `"$($assignment.Id)`" -ServicePrincipalId `"$($assignment.ResourceId)`"" -ForegroundColor Cyan
            Write-Host "Remove-MgOAuth2PermissionGrant -OAuth2PermissionGrantId `"$($grant.Id)`"" -ForegroundColor Cyan
        }
    }
}
