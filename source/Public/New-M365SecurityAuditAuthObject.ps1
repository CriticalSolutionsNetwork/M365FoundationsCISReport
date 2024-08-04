<#
    .SYNOPSIS
        Creates a new CISAuthenticationParameters object for Microsoft 365 authentication.
    .DESCRIPTION
        The New-M365SecurityAuditAuthObject function constructs a new CISAuthenticationParameters object
        containing the necessary credentials and URLs for authenticating to various Microsoft 365 services.
        It validates input parameters to ensure they conform to expected formats and length requirements.
        An app registration in Azure AD with the required permissions to EXO, SPO, MSTeams and MgGraph is needed.
    .PARAMETER ClientCertThumbPrint
        The thumbprint of the client certificate used for authentication. It must be a 40-character hexadecimal string.
        This certificate is used to authenticate the application in Azure AD.
    .PARAMETER ClientId
        The Client ID (Application ID) of the Azure AD application. It must be a valid GUID format.
    .PARAMETER TenantId
        The Tenant ID of the Azure AD directory. It must be a valid GUID format representing your Microsoft 365 tenant.
    .PARAMETER OnMicrosoftUrl
        The URL of your onmicrosoft.com domain. It should be in the format 'example.onmicrosoft.com'.
    .PARAMETER SpAdminUrl
        The SharePoint admin URL, which should end with '-admin.sharepoint.com'. This URL is used for connecting to SharePoint Online.
    .INPUTS
        None. You cannot pipe objects to this function.
    .OUTPUTS
        CISAuthenticationParameters
            The function returns an instance of the CISAuthenticationParameters class containing the authentication details.
    .EXAMPLE
        PS> $authParams = New-M365SecurityAuditAuthObject -ClientCertThumbPrint "ABCDEF1234567890ABCDEF1234567890ABCDEF12" `
                                                            -ClientId "12345678-1234-1234-1234-123456789012" `
                                                            -TenantId "12345678-1234-1234-1234-123456789012" `
                                                            -OnMicrosoftUrl "yourcompany.onmicrosoft.com" `
                                                            -SpAdminUrl "https://yourcompany-admin.sharepoint.com"
        Creates a new CISAuthenticationParameters object with the specified credentials and URLs, validating each parameter's format and length.
    .NOTES
        Requires PowerShell 7.0 or later.
#>
function New-M365SecurityAuditAuthObject {
    [CmdletBinding()]
    [OutputType([CISAuthenticationParameters])]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "The 40-character hexadecimal thumbprint of the client certificate.")]
        [ValidatePattern("^[0-9a-fA-F]{40}$")]  # Regex for a valid thumbprint format
        [ValidateLength(40, 40)]  # Enforce exact length
        [string]$ClientCertThumbPrint,
        [Parameter(Mandatory = $true, HelpMessage = "The Client ID (GUID format) of the Azure AD application.")]
        [ValidatePattern("^[0-9a-fA-F\-]{36}$")]  # Regex for a valid GUID
        [string]$ClientId,
        [Parameter(Mandatory = $true, HelpMessage = "The Tenant ID (GUID format) of the Azure AD directory.")]
        [ValidatePattern("^[0-9a-fA-F\-]{36}$")]  # Regex for a valid GUID
        [string]$TenantId,
        [Parameter(Mandatory = $true, HelpMessage = "The onmicrosoft.com domain URL (e.g., 'example.onmicrosoft.com').")]
        [ValidatePattern("^[a-zA-Z0-9]+\.onmicrosoft\.com$")]  # Regex for a valid onmicrosoft.com URL
        [string]$OnMicrosoftUrl,
        [Parameter(Mandatory = $true, HelpMessage = "The SharePoint admin URL ending with '-admin.sharepoint.com'.")]
        [ValidatePattern("^https:\/\/[a-zA-Z0-9\-]+\-admin\.sharepoint\.com$")]  # Regex for a valid SharePoint admin URL
        [string]$SpAdminUrl
    )
    # Create and return the authentication parameters object
    return [CISAuthenticationParameters]::new(
        $ClientCertThumbPrint,
        $ClientId,
        $TenantId,
        $OnMicrosoftUrl,
        $SpAdminUrl
    )
}