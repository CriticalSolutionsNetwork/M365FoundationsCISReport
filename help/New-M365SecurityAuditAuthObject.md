---
external help file: M365FoundationsCISReport-help.xml
Module Name: M365FoundationsCISReport
online version:
schema: 2.0.0
---

# New-M365SecurityAuditAuthObject

## SYNOPSIS
Creates a new CISAuthenticationParameters object for Microsoft 365 authentication.

## SYNTAX

```
New-M365SecurityAuditAuthObject [-ClientCertThumbPrint] <String> [-ClientId] <String> [-TenantId] <String>
 [-OnMicrosoftUrl] <String> [-SpAdminUrl] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The New-M365SecurityAuditAuthObject function constructs a new CISAuthenticationParameters object
containing the necessary credentials and URLs for authenticating to various Microsoft 365 services.
It validates input parameters to ensure they conform to expected formats and length requirements.
An app registration in Azure AD with the required permissions to EXO, SPO, MSTeams and MgGraph is needed.

## EXAMPLES

### EXAMPLE 1
```
$authParams = New-M365SecurityAuditAuthObject -ClientCertThumbPrint "ABCDEF1234567890ABCDEF1234567890ABCDEF12" `
                                                    -ClientId "12345678-1234-1234-1234-123456789012" `
                                                    -TenantId "12345678-1234-1234-1234-123456789012" `
                                                    -OnMicrosoftUrl "yourcompany.onmicrosoft.com" `
                                                    -SpAdminUrl "https://yourcompany-admin.sharepoint.com"
Creates a new CISAuthenticationParameters object with the specified credentials and URLs, validating each parameter's format and length.
```

## PARAMETERS

### -ClientCertThumbPrint
The thumbprint of the client certificate used for authentication.
It must be a 40-character hexadecimal string.
This certificate is used to authenticate the application in Azure AD.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
The Client ID (Application ID) of the Azure AD application.
It must be a valid GUID format.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
The Tenant ID of the Azure AD directory.
It must be a valid GUID format representing your Microsoft 365 tenant.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnMicrosoftUrl
The URL of your onmicrosoft.com domain.
It should be in the format 'example.onmicrosoft.com'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SpAdminUrl
The SharePoint admin URL, which should end with '-admin.sharepoint.com'.
This URL is used for connecting to SharePoint Online.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to this function.
## OUTPUTS

### CISAuthenticationParameters
### The function returns an instance of the CISAuthenticationParameters class containing the authentication details.
## NOTES
Requires PowerShell 7.0 or later.

## RELATED LINKS
