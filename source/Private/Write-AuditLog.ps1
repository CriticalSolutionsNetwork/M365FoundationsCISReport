function Write-AuditLog {
    <#
    .SYNOPSIS
        Writes log messages to the console and updates the script-wide log variable.
    .DESCRIPTION
        The Write-AuditLog function writes log messages to the console based on the severity (Verbose, Warning, or Error) and updates
        the script-wide log variable ($script:LogString) with the log entry. You can use the Start, End, and EndFunction switches to
        manage the lifecycle of the logging.
    .INPUTS
        System.String
        You can pipe a string to the Write-AuditLog function as the Message parameter.
        You can also pipe an object with a Severity property as the Severity parameter.
    .OUTPUTS
        None
        The Write-AuditLog function doesn't output any objects to the pipeline. It writes messages to the console and updates the
        script-wide log variable ($script:LogString).
    .PARAMETER BeginFunction
        Sets the message to "Begin [FunctionName] function log.", where FunctionName is the name of the calling function, and adds it to the log variable.
    .PARAMETER Message
        The message string to log.
    .PARAMETER Severity
        The severity of the log message. Accepted values are 'Information', 'Warning', and 'Error'. Defaults to 'Information'.
    .PARAMETER Start
        Initializes the script-wide log variable and sets the message to "Begin [FunctionName] Log.", where FunctionName is the name of the calling function.
    .PARAMETER End
        Sets the message to "End Log" and exports the log to a CSV file if the OutputPath parameter is provided.
    .PARAMETER EndFunction
        Sets the message to "End [FunctionName] log.", where FunctionName is the name of the calling function, and adds it to the log variable.
    .PARAMETER OutputPath
        The file path for exporting the log to a CSV file when using the End switch.
    .EXAMPLE
        Write-AuditLog -Message "This is a test message."

        Writes a test message with the default severity (Information) to the console and adds it to the log variable.
    .EXAMPLE
        Write-AuditLog -Message "This is a warning message." -Severity "Warning"

        Writes a warning message to the console and adds it to the log variable.
    .EXAMPLE
        Write-AuditLog -Start

        Initializes the log variable and sets the message to "Begin [FunctionName] Log.", where FunctionName is the name of the calling function.
    .EXAMPLE
        Write-AuditLog -BeginFunction

        Sets the message to "Begin [FunctionName] function log.", where FunctionName is the name of the calling function, and adds it to the log variable.
    .EXAMPLE
        Write-AuditLog -EndFunction

        Sets the message to "End [FunctionName] log.", where FunctionName is the name of the calling function, and adds it to the log variable.
    .EXAMPLE
        Write-AuditLog -End -OutputPath "C:\Logs\auditlog.csv"

        Sets the message to "End Log", adds it to the log variable, and exports the log to a CSV file.
    .NOTES
    Author: DrIOSx
#>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        ###
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Input a Message string.',
            Position = 0,
            ParameterSetName = 'Default',
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        ###
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Information, Warning or Error.',
            Position = 1,
            ParameterSetName = 'Default',
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Severity = 'Information',
        ###
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'End'
        )]
        [switch]$End,
        ###
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'BeginFunction'
        )]
        [switch]$BeginFunction,
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'EndFunction'
        )]
        [switch]$EndFunction,
        ###
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Start'
        )]
        [switch]$Start,
        ###
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'End'
        )]
        [string]$OutputPath
    )
    begin {
        $ErrorActionPreference = "SilentlyContinue"
        # Define variables to hold information about the command that was invoked.
        $ModuleName = $Script:MyInvocation.MyCommand.Name -replace '\..*'
        $callStack = Get-PSCallStack
        if ($callStack.Count -gt 1) {
            $FuncName = $callStack[1].Command
        } else {
            $FuncName = "DirectCall"  # Or any other default name you prefer
        }
        #Write-Verbose "Funcname Name is $FuncName!" -Verbose
        $ModuleVer = $MyInvocation.MyCommand.Version.ToString()
        # Set the error action preference to continue.
        $ErrorActionPreference = "Continue"
    }
    process {
        try {
            if (-not $Start -and -not (Test-Path variable:script:LogString)) {
                throw "The logging variable is not initialized. Please call Write-AuditLog with the -Start switch or ensure $script:LogString is set."
            }
            $Function = $($FuncName + '.v' + $ModuleVer)
            if ($Start) {
                $script:LogString = @()
                $Message = '+++ Begin Log | ' + $Function + ' |'
            }
            elseif ($BeginFunction) {
                $Message = '>>> Begin Function Log | ' + $Function + ' |'
            }
            $logEntry = [pscustomobject]@{
                Time      = ((Get-Date).ToString('yyyy-MM-dd hh:mmTss'))
                Module    = $ModuleName
                PSVersion = ($PSVersionTable.PSVersion).ToString()
                PSEdition = ($PSVersionTable.PSEdition).ToString()
                IsAdmin   = $(Test-IsAdmin)
                User      = "$Env:USERDOMAIN\$Env:USERNAME"
                HostName  = $Env:COMPUTERNAME
                InvokedBy = $Function
                Severity  = $Severity
                Message   = $Message
                RunID     = -1
            }
            if ($BeginFunction) {
                $maxRunID = ($script:LogString | Where-Object { $_.InvokedBy -eq $Function } | Measure-Object -Property RunID -Maximum).Maximum
                if ($null -eq $maxRunID) { $maxRunID = -1 }
                $logEntry.RunID = $maxRunID + 1
            }
            else {
                $lastRunID = ($script:LogString | Where-Object { $_.InvokedBy -eq $Function } | Select-Object -Last 1).RunID
                if ($null -eq $lastRunID) { $lastRunID = 0 }
                $logEntry.RunID = $lastRunID
            }
            if ($EndFunction) {
                $FunctionStart = "$((($script:LogString | Where-Object {$_.InvokedBy -eq $Function -and $_.RunId -eq $lastRunID } | Sort-Object Time)[0]).Time)"
                $startTime = ([DateTime]::ParseExact("$FunctionStart", 'yyyy-MM-dd hh:mmTss', $null))
                $endTime = Get-Date
                $timeTaken = $endTime - $startTime
                $Message = '<<< End Function Log   | ' + $Function + ' | Runtime: ' + "$($timeTaken.Minutes) min $($timeTaken.Seconds) sec"
                $logEntry.Message = $Message
            }
            elseif ($End) {
                $startTime = ([DateTime]::ParseExact($($script:LogString[0].Time), 'yyyy-MM-dd hh:mmTss', $null))
                $endTime = Get-Date
                $timeTaken = $endTime - $startTime
                $Message = '--- End Log   | ' + $Function + ' | Runtime: ' + "$($timeTaken.Minutes) min $($timeTaken.Seconds) sec"
                $logEntry.Message = $Message
            }
            $script:LogString += $logEntry
            switch ($Severity) {
                'Warning' {
                    Write-Warning ('[WARNING] ! ' + $Message)
                    $UserInput = Read-Host "Warning encountered! Do you want to continue? (Y/N)"
                    if ($UserInput -eq 'N') {
                        throw "Script execution stopped by user."
                    }
                }
                'Error'       { Write-Error ('[ERROR] X - ' + $FuncName + ' ' + $Message) -ErrorAction Continue }
                'Verbose'     { Write-Verbose ('[VERBOSE] ~ ' + $Message) }
                Default { Write-Information ('[INFO] * ' + $Message)  -InformationAction Continue}
            }
        }
        catch {
            throw "Write-AuditLog encountered an error (process block): $($_)"
        }

    }
    end {
        try {
            if ($End) {
                if (-not [string]::IsNullOrEmpty($OutputPath)) {
                    $script:LogString | Export-Csv -Path $OutputPath -NoTypeInformation
                    Write-Verbose "LogPath: $(Split-Path -Path $OutputPath -Parent)"
                }
                else {
                    throw "OutputPath is not specified for End action."
                }
            }
        }
        catch {
            throw "Error in Write-AuditLog (end block): $($_.Exception.Message)"
        }
    }
}