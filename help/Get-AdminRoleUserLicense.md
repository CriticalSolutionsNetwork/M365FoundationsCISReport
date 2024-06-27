---
external help file: M365FoundationsCISReport-help.xml
Module Name: M365FoundationsCISReport
online version: https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-AdminRoleUserLicense
schema: 2.0.0
---

# Get-AdminRoleUserLicense

## SYNOPSIS
Retrieves user licenses and roles for administrative accounts from Microsoft 365 via the Graph API.

## SYNTAX

```
Get-AdminRoleUserLicense [-SkipGraphConnection] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-AdminRoleUserLicense function connects to Microsoft Graph and retrieves all users who are assigned administrative roles along with their user details and licenses.
This function is useful for auditing and compliance checks to ensure that administrators have appropriate licenses and role assignments.

## EXAMPLES

### EXAMPLE 1
```
Get-AdminRoleUserLicense
```

This example retrieves all administrative role users along with their licenses by connecting to Microsoft Graph using the default scopes.

### EXAMPLE 2
```
Get-AdminRoleUserLicense -SkipGraphConnection
```

This example retrieves all administrative role users along with their licenses without attempting to connect to Microsoft Graph, assuming that the connection is already established.

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

### -SkipGraphConnection
A switch parameter that, when set, skips the connection to Microsoft Graph if already established.
This is useful for batch processing or when used within scripts where multiple calls are made and the connection is managed externally.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Get-AdminRoleUserLicense.
## OUTPUTS

### PSCustomObject
### Returns a custom object for each user with administrative roles that includes the following properties: RoleName, UserName, UserPrincipalName, UserId, HybridUser, and Licenses.
## NOTES
Creation Date:  2024-04-15
Purpose/Change: Initial function development to support Microsoft 365 administrative role auditing.

## RELATED LINKS

[https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-AdminRoleUserLicense](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-AdminRoleUserLicense)

