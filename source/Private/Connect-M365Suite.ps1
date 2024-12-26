function Connect-M365Suite {
    [OutputType([void])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $false
        )]
        [string]$TenantAdminUrl,
        [Parameter(
            Mandatory = $false
        )]
        [CISAuthenticationParameters]$AuthParams, # Custom authentication parameters
        [Parameter(
            Mandatory
        )]
        [string[]]$RequiredConnections,
        [Parameter(
            Mandatory = $false
        )]
        [switch]$SkipConfirmation
    )
    if (!$SkipConfirmation) {
        $VerbosePreference = "Continue"
    }
    else {
        $VerbosePreference = "SilentlyContinue"
    }
    $tenantInfo = @()
    $connectedServices = @()
    try {
        if ($RequiredConnections -contains "Microsoft Graph" -or $RequiredConnections -contains "EXO | Microsoft Graph") {
            Write-Verbose "Connecting to Microsoft Graph"
            if ($AuthParams) {
                # Use application-based authentication
                Connect-MgGraph -CertificateThumbprint $AuthParams.ClientCertThumbPrint -AppId $AuthParams.ClientId -TenantId $AuthParams.TenantId -NoWelcome | Out-Null
            }
            else {
                # Use interactive authentication with scopes
                Connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -NoWelcome | Out-Null
            }
            $graphOrgDetails = Get-MgOrganization
            $tenantInfo += [PSCustomObject]@{
                Service    = "Microsoft Graph"
                TenantName = $graphOrgDetails.DisplayName
                TenantID   = $graphOrgDetails.Id
            }
            $connectedServices += "Microsoft Graph"
            Write-Verbose "Successfully connected to Microsoft Graph.`n"
        }
        if ($RequiredConnections -contains "EXO" -or $RequiredConnections -contains "AzureAD | EXO" -or $RequiredConnections -contains "Microsoft Teams | EXO" -or $RequiredConnections -contains "EXO | Microsoft Graph") {
            Write-Verbose "Connecting to Exchange Online..."
            if ($AuthParams) {
                # Use application-based authentication
                Connect-ExchangeOnline -AppId $AuthParams.ClientId -CertificateThumbprint $AuthParams.ClientCertThumbPrint -Organization $AuthParams.OnMicrosoftUrl -ShowBanner:$false | Out-Null
            }
            else {
                # Use interactive authentication
                Connect-ExchangeOnline -ShowBanner:$false | Out-Null
            }
            $exoTenant = (Get-OrganizationConfig).Identity
            $tenantInfo += [PSCustomObject]@{
                Service    = "Exchange Online"
                TenantName = $exoTenant
                TenantID   = "N/A"
            }
            $connectedServices += "EXO"
            Write-Verbose "Successfully connected to Exchange Online.`n"
        }
        if ($RequiredConnections -contains "SPO") {
            Write-Verbose "Connecting to SharePoint Online..."
            if ($AuthParams) {
                # Use application-based authentication
                Connect-PnPOnline -Url $AuthParams.SpAdminUrl -ClientId $AuthParams.ClientId -Tenant $AuthParams.OnMicrosoftUrl -Thumbprint $AuthParams.ClientCertThumbPrint | Out-Null
            }
            else {
                # Use interactive authentication
                Connect-SPOService -Url $TenantAdminUrl | Out-Null
            }
            # Assuming that Get-SPOCrossTenantHostUrl and Get-UrlLine are valid commands in your context
            if ($AuthParams) {
                $spoContext = Get-PnPSite
                $tenantName = $spoContext.Url
            }
            else {
                $spoContext = Get-SPOCrossTenantHostUrl
                $tenantName = Get-UrlLine -Output $spoContext
            }
            $tenantInfo += [PSCustomObject]@{
                Service    = "SharePoint Online"
                TenantName = $tenantName
            }
            $connectedServices += "SPO"
            Write-Verbose "Successfully connected to SharePoint Online.`n"
        }
        if ($RequiredConnections -contains "Microsoft Teams" -or $RequiredConnections -contains "Microsoft Teams | EXO") {
            Write-Verbose "Connecting to Microsoft Teams..."
            if ($AuthParams) {
                # Use application-based authentication
                Connect-MicrosoftTeams -TenantId $AuthParams.TenantId -CertificateThumbprint $AuthParams.ClientCertThumbPrint -ApplicationId $AuthParams.ClientId | Out-Null
            }
            else {
                # Use interactive authentication
                Connect-MicrosoftTeams | Out-Null
            }
            $teamsTenantDetails = Get-CsTenant
            $tenantInfo += [PSCustomObject]@{
                Service    = "Microsoft Teams"
                TenantName = $teamsTenantDetails.DisplayName
                TenantID   = $teamsTenantDetails.TenantId
            }
            $connectedServices += "Microsoft Teams"
            Write-Verbose "Successfully connected to Microsoft Teams.`n"
        }
        # Display tenant information and confirm with the user
        if (-not $SkipConfirmation) {
            Write-Verbose "Connected to the following tenants:"
            foreach ($tenant in $tenantInfo) {
                Write-Verbose "Service: $($tenant.Service)"
                Write-Verbose "Tenant Context: $($tenant.TenantName)`n"
                #Write-Verbose "Tenant ID: $($tenant.TenantID)"
            }
            if ($script:PnpAuth) {
                Write-Warning "`n!!!!!!!!!!!!Important!!!!!!!!!!!!!!`nIf you use auth tokens, you will need to kill the current session before subsequent runs as the PNP.Powershell module has conflicts with MgGraph!`n!!!!!!!!!!!!Important!!!!!!!!!!!!!!"
            }
            $confirmation = Read-Host "Do you want to proceed with these connections? (Y/N)"
            if ($confirmation -notLike 'Y') {
                Write-Verbose "Connection setup aborted by user."
                Disconnect-M365Suite -RequiredConnections $connectedServices
                throw "User aborted connection setup."
            }
        }
    }
    catch {
        $CatchError = $_
        $VerbosePreference = "Continue"
        throw $CatchError
    }
    $VerbosePreference = "Continue"
}
