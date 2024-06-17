Import-Module .\output\module\M365FoundationsCISReport\*\*.psd1
.\helpers\psDoc-master\src\psDoc.ps1 -moduleName M365FoundationsCISReport -outputDir docs -template ".\helpers\psDoc-master\src\out-html-template.ps1"
.\helpers\psDoc-master\src\psDoc.ps1 -moduleName M365FoundationsCISReport -outputDir ".\" -template ".\helpers\psDoc-master\src\out-markdown-template.ps1" -fileName ".\README.md"


<#
    $ver = "v0.1.11"
    git checkout main
    git pull origin main
    git tag -a $ver -m "Release version $ver refactor Update"
    git push origin $ver
    "Fix: PR #37"
    git push origin $ver
    # git tag -d $ver
#>
