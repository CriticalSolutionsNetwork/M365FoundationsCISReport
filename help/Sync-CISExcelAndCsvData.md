---
external help file: M365FoundationsCISReport-help.xml
Module Name: M365FoundationsCISReport
online version: https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData
schema: 2.0.0
---

# Sync-CISExcelAndCsvData

## SYNOPSIS
Synchronizes and updates data in an Excel worksheet with new information from a CSV file, including audit dates.

## SYNTAX

```
Sync-CISExcelAndCsvData [[-ExcelPath] <String>] [[-CsvPath] <String>] [[-SheetName] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Sync-CISExcelAndCsvData function merges and updates data in a specified Excel worksheet from a CSV file.
This includes adding or updating fields for connection status, details, failure reasons, and the date of the update.
It's designed to ensure that the Excel document maintains a running log of changes over time, ideal for tracking remediation status and audit history.

## EXAMPLES

### EXAMPLE 1
```
Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -CsvPath "path\to\data.csv" -SheetName "AuditData"
Updates the 'AuditData' worksheet in 'excel.xlsx' with data from 'data.csv', adding new information and the date of the update.
```

## PARAMETERS

### -ExcelPath
Specifies the path to the Excel file to be updated.
This parameter is mandatory.

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

### -CsvPath
Specifies the path to the CSV file containing new data.
This parameter is mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SheetName
Specifies the name of the worksheet in the Excel file where data will be merged and updated.
This parameter is mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

### System.String
### The function accepts strings for file paths and worksheet names.
## OUTPUTS

### None
### The function directly updates the Excel file and does not output any objects.
## NOTES
- Ensure that the 'ImportExcel' module is installed and up to date to handle Excel file manipulations.
- It is recommended to back up the Excel file before running this function to avoid accidental data loss.
- The CSV file should have columns that match expected headers like 'Connection', 'Details', 'FailureReason', and 'Status' for correct data mapping.

## RELATED LINKS

[https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData)

