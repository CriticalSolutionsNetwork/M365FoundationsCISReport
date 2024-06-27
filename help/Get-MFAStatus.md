---
external help file: M365FoundationsCISReport-help.xml
Module Name: M365FoundationsCISReport
online version: https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-MFAStatus
schema: 2.0.0
---

# Get-MFAStatus

## SYNOPSIS
Retrieves the MFA (Multi-Factor Authentication) status for Azure Active Directory users.

## SYNTAX

```
Get-MFAStatus [[-UserId] <String>] [-SkipMSOLConnectionChecks] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-MFAStatus function connects to Microsoft Online Service and retrieves the MFA status for all Azure Active Directory users, excluding guest accounts.
Optionally, you can specify a single user by their User Principal Name (UPN) to get their MFA status.

## EXAMPLES

### EXAMPLE 1
```
Get-MFAStatus
Retrieves the MFA status for all Azure Active Directory users.
```

### EXAMPLE 2
```
Get-MFAStatus -UserId "example@domain.com"
Retrieves the MFA status for the specified user with the UPN "example@domain.com".
```

## PARAMETERS

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

### -SkipMSOLConnectionChecks
{{ Fill SkipMSOLConnectionChecks Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserId
The User Principal Name (UPN) of a specific user to retrieve MFA status for.
If not provided, the function retrieves MFA status for all users.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object
### Returns a sorted list of custom objects containing the following properties:
### - UserPrincipalName
### - DisplayName
### - MFAState
### - MFADefaultMethod
### - MFAPhoneNumber
### - PrimarySMTP
### - Aliases
## NOTES
The function requires the MSOL module to be installed and connected to your tenant.
Ensure that you have the necessary permissions to read user and MFA status information.

## RELATED LINKS

[https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-MFAStatus](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-MFAStatus)

