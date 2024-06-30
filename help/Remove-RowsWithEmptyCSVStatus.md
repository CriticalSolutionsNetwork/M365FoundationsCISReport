---
external help file: M365FoundationsCISReport-help.xml
Module Name: M365FoundationsCISReport
online version:
schema: 2.0.0
---

# Remove-RowsWithEmptyCSVStatus

## SYNOPSIS
Removes rows from an Excel worksheet where the 'CSV_Status' column is empty and saves the result to a new file.

## SYNTAX

```
Remove-RowsWithEmptyCSVStatus [-FilePath] <String> [-WorksheetName] <String> [<CommonParameters>]
```

## DESCRIPTION
The Remove-RowsWithEmptyCSVStatus function imports data from a specified worksheet in an Excel file, checks for the presence of the 'CSV_Status' column, and filters out rows where the 'CSV_Status' column is empty.
The filtered data is then exported to a new Excel file with a '-Filtered' suffix added to the original file name.

## EXAMPLES

### EXAMPLE 1
```
Remove-RowsWithEmptyCSVStatus -FilePath "C:\Reports\Report.xlsx" -WorksheetName "Sheet1"
This command imports data from the "Sheet1" worksheet in the "Report.xlsx" file, removes rows where the 'CSV_Status' column is empty, and saves the filtered data to a new file named "Report-Filtered.xlsx" in the same directory.
```

## PARAMETERS

### -FilePath
The path to the Excel file to be processed.

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

### -WorksheetName
The name of the worksheet within the Excel file to be processed.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function requires the ImportExcel module to be installed.

## RELATED LINKS
