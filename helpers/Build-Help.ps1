Import-Module .\output\module\M365FoundationsCISReport\*\*.psd1
.\helpers\psDoc-master\src\psDoc.ps1 -moduleName M365FoundationsCISReport -outputDir docs -template ".\helpers\psDoc-master\src\out-html-template.ps1"
.\helpers\psDoc-master\src\psDoc.ps1 -moduleName M365FoundationsCISReport -outputDir ".\" -template ".\helpers\psDoc-master\src\out-markdown-template.ps1" -fileName ".\README.md"


<#
    $ver = "v0.1.14"
    git checkout main
    git pull origin main
    git tag -a $ver -m "Release version $ver refactor Update"
    git push origin $ver
    "Fix: PR #37"
    git push origin $ver
    # git tag -d $ver
#>

$OutputFolder = ".\help"
$parameters = @{
    Module = "M365FoundationsCISReport"
    OutputFolder = $OutputFolder
    AlphabeticParamsOrder = $true
    WithModulePage = $true
    ExcludeDontShow = $true
    Encoding = [System.Text.Encoding]::UTF8
}
New-MarkdownHelp @parameters
New-MarkdownAboutHelp -OutputFolder $OutputFolder -AboutName "M365FoundationsCISReport"


####
$parameters = @{
    Path = ".\help"
    RefreshModulePage = $true
    AlphabeticParamsOrder = $true
    UpdateInputOutput = $true
    ExcludeDontShow = $true
    LogPath = ".\log.txt"
    Encoding = [System.Text.Encoding]::UTF8
}
Update-MarkdownHelpModule @parameters -Force
Update-MarkdownHelpModule -Path ".\help" -RefreshModulePage -Force
New-ExternalHelp -Path ".\help" -OutputPath ".\source\en-US" -force