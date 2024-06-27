---
external help file: M365FoundationsCISReport-help.xml
Module Name: M365FoundationsCISReport
online version: https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Grant-M365SecurityAuditConsent
schema: 2.0.0
---

# Grant-M365SecurityAuditConsent

## SYNOPSIS
Grants Microsoft Graph permissions for an auditor.

## SYNTAX

```
Grant-M365SecurityAuditConsent [-UserPrincipalNameForConsent] <String> [-SkipGraphConnection]
 [-SkipModuleCheck] [-SuppressRevertOutput] [-DoNotDisconnect] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function grants the specified Microsoft Graph permissions to a user, allowing the user to perform audits.
It connects to Microsoft Graph, checks if a service principal exists for the client application, creates it if it does not exist, and then grants the specified permissions.
Finally, it assigns the app to the user.

## EXAMPLES

### EXAMPLE 1
```
Grant-M365SecurityAuditConsent -UserPrincipalNameForConsent user@example.com
```

Grants Microsoft Graph permissions to user@example.com for the client application with the specified Application ID.

### EXAMPLE 2
```
Grant-M365SecurityAuditConsent -UserPrincipalNameForConsent user@example.com -SkipGraphConnection
```

Grants Microsoft Graph permissions to user@example.com, skipping the connection to Microsoft Graph.

## PARAMETERS

### -DoNotDisconnect
If specified, does not disconnect from Microsoft Graph after granting consent.

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

### -SkipGraphConnection
If specified, skips connecting to Microsoft Graph.

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

### -SkipModuleCheck
If specified, skips the check for the Microsoft.Graph module.

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

### -SuppressRevertOutput
If specified, suppresses the output of the revert commands.

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

### -UserPrincipalNameForConsent
Specify the UPN of the user to grant consent for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Void
## NOTES
This function requires the Microsoft.Graph module version 2.4.0 or higher.

## RELATED LINKS

[https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Grant-M365SecurityAuditConsent](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Grant-M365SecurityAuditConsent)

