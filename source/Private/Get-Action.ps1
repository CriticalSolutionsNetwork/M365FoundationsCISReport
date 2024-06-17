function Get-Action {
    [CmdletBinding(DefaultParameterSetName = "GetDictionaries")]
    param (
        [Parameter(Position = 0, ParameterSetName = "GetDictionaries")]
        [switch]$Dictionaries,

        [Parameter(Position = 0, ParameterSetName = "ConvertActions")]
        [string[]]$Actions,

        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "ConvertActions")]
        [ValidateSet("Admin", "Delegate", "Owner")]
        [string]$ActionType,

        [Parameter(Position = 0, ParameterSetName = "ReverseActions")]
        [string[]]$AbbreviatedActions,

        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "ReverseActions")]
        [ValidateSet("Admin", "Delegate", "Owner")]
        [string]$ReverseActionType
    )

    $Dictionary = @{
        AdminActions = @{
            ApplyRecord              = 'AR'
            Copy                     = 'CP'
            Create                   = 'CR'
            FolderBind               = 'FB'
            HardDelete               = 'HD'
            MailItemsAccessed        = 'MIA'
            Move                     = 'MV'
            MoveToDeletedItems       = 'MTDI'
            SendAs                   = 'SA'
            SendOnBehalf             = 'SOB'
            Send                     = 'SD'
            SoftDelete               = 'SD'
            Update                   = 'UP'
            UpdateCalendarDelegation = 'UCD'
            UpdateFolderPermissions  = 'UFP'
            UpdateInboxRules         = 'UIR'
        }
        DelegateActions = @{
            ApplyRecord             = 'AR'
            Create                  = 'CR'
            FolderBind              = 'FB'
            HardDelete              = 'HD'
            MailItemsAccessed       = 'MIA'
            Move                    = 'MV'
            MoveToDeletedItems      = 'MTDI'
            SendAs                  = 'SA'
            SendOnBehalf            = 'SOB'
            SoftDelete              = 'SD'
            Update                  = 'UP'
            UpdateFolderPermissions = 'UFP'
            UpdateInboxRules        = 'UIR'
        }
        OwnerActions = @{
            ApplyRecord              = 'AR'
            Create                   = 'CR'
            HardDelete               = 'HD'
            MailboxLogin             = 'ML'
            MailItemsAccessed        = 'MIA'
            Move                     = 'MV'
            MoveToDeletedItems       = 'MTDI'
            Send                     = 'SD'
            SoftDelete               = 'SD'
            Update                   = 'UP'
            UpdateCalendarDelegation = 'UCD'
            UpdateFolderPermissions  = 'UFP'
            UpdateInboxRules         = 'UIR'
        }
    }

    switch ($PSCmdlet.ParameterSetName) {
        "GetDictionaries" {
            return $Dictionary
        }
        "ConvertActions" {
            $actionDictionary = switch ($ActionType) {
                "Admin"    { $Dictionary.AdminActions }
                "Delegate" { $Dictionary.DelegateActions }
                "Owner"    { $Dictionary.OwnerActions }
            }

            $abbreviatedActions = @()
            foreach ($action in $Actions) {
                if ($actionDictionary.ContainsKey($action)) {
                    $abbreviatedActions += $actionDictionary[$action]
                }
            }
            return $abbreviatedActions
        }
        "ReverseActions" {
            $reverseDictionary = @{}
            $originalDictionary = switch ($ReverseActionType) {
                "Admin"    { $Dictionary.AdminActions }
                "Delegate" { $Dictionary.DelegateActions }
                "Owner"    { $Dictionary.OwnerActions }
            }

            foreach ($key in $originalDictionary.Keys) {
                $reverseDictionary[$originalDictionary[$key]] = $key
            }

            $fullNames = @()
            foreach ($abbrAction in $AbbreviatedActions) {
                if ($reverseDictionary.ContainsKey($abbrAction)) {
                    $fullNames += $reverseDictionary[$abbrAction]
                }
            }
            return $fullNames
        }
    }
}
