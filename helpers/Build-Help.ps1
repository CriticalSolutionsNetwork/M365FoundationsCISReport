Import-Module .\output\module\M365FoundationsCISReport\*\*.psd1
.\helpers\psDoc-master\src\psDoc.ps1 -moduleName M365FoundationsCISReport -outputDir docs -template ".\helpers\psDoc-master\src\out-html-template.ps1"
.\helpers\psDoc-master\src\psDoc.ps1 -moduleName M365FoundationsCISReport -outputDir ".\" -template ".\helpers\psDoc-master\src\out-markdown-template.ps1" -fileName ".\README.md"