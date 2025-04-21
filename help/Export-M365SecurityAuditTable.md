---
external help file: M365FoundationsCISReport-help.xml
Module Name: M365FoundationsCISReport
online version: https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Export-M365SecurityAuditTable
schema: 2.0.0
---

# Export-M365SecurityAuditTable

## SYNOPSIS
Exports M365 security audit results to a CSV file or outputs a specific test result as an object.

## SYNTAX

### DefaultExport (Default)
```
Export-M365SecurityAuditTable -AuditResults <PSObject[]> -ExportPath <String> [-ExportToExcel]
 [-Prefix <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SingleObject
```
Export-M365SecurityAuditTable -AuditResults <PSObject[]> -OutputTestNumber <String>
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### OnlyExportNestedTables
```
Export-M365SecurityAuditTable -AuditResults <PSObject[]> -ExportPath <String> [-ExportToExcel]
 [-Prefix <String>] [-OnlyExportNestedTables] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function exports M365 security audit results from either an array of CISAuditResult objects or a CSV file.
It can export all results to a specified path or output a specific test result as an object.

## EXAMPLES

### EXAMPLE 1
```
Export-M365SecurityAuditTable -AuditResults $object -OutputTestNumber 6.1.2
# Output object for a single test number from audit results
```

### EXAMPLE 2
```
Export-M365SecurityAuditTable -ExportAllTests -AuditResults $object -ExportPath "C:\temp"
# Export all results from audit results to the specified path
```

### EXAMPLE 3
```
Export-M365SecurityAuditTable -CsvPath "C:\temp\auditresultstoday1.csv" -OutputTestNumber 6.1.2
# Output object for a single test number from CSV
```

### EXAMPLE 4
```
Export-M365SecurityAuditTable -ExportAllTests -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp"
# Export all results from CSV to the specified path
```

### EXAMPLE 5
```
Export-M365SecurityAuditTable -ExportAllTests -AuditResults $object -ExportPath "C:\temp" -ExportOriginalTests
# Export all results from audit results to the specified path along with the original tests
```

### EXAMPLE 6
```
Export-M365SecurityAuditTable -ExportAllTests -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp" -ExportOriginalTests
# Export all results from CSV to the specified path along with the original tests
```

## PARAMETERS

### -AuditResults
An array of CISAuditResult objects containing the audit results.

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportPath
The path where the CSV files will be exported.

```yaml
Type: String
Parameter Sets: DefaultExport, OnlyExportNestedTables
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportToExcel
Switch to export the results to an Excel file.

```yaml
Type: SwitchParameter
Parameter Sets: DefaultExport, OnlyExportNestedTables
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prefix
Add Prefix to filename after date when outputting to excel or csv.
Validate that the count of letters in the prefix is less than 5.

```yaml
Type: String
Parameter Sets: DefaultExport, OnlyExportNestedTables
Aliases:

Required: False
Position: Named
Default value: Corp
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnlyExportNestedTables
───────────────────────────────────────────────────────────────────────────
 2) OnlyExportNestedTables: nested tables only into ZIP
    -AuditResults, -ExportPath, -OnlyExportNestedTables
───────────────────────────────────────────────────────────────────────────

```yaml
Type: SwitchParameter
Parameter Sets: OnlyExportNestedTables
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputTestNumber
The test number to output as an object.
Valid values are "1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4".

```yaml
Type: String
Parameter Sets: SingleObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

### [CISAuditResult[]] - An array of CISAuditResult objects.
### [string] - A path to a CSV file.
## OUTPUTS

### [PSCustomObject] - A custom object containing the path to the zip file and its hash.
## NOTES

## RELATED LINKS

[https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Export-M365SecurityAuditTable](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Export-M365SecurityAuditTable)

