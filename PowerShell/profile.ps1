if ($null -eq (Get-Module -Name 'posh-git' -ListAvailable)) {
    Install-Module -Name 'posh-git' -Scope CurrentUser -Force
}

Import-Module posh-git
Import-Module PSReadLine

$GitPromptSettings.WorkingColor.ForegroundColor = [System.ConsoleColor]::Red
$GitPromptSettings.LocalWorkingStatusSymbol.ForegroundColor = [System.ConsoleColor]::Red

Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -BellStyle None
# Set-PSReadLineOption -PredictionSource History
