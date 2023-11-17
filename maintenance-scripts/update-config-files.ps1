Test-Path $PROFILE && Copy-Item $PROFILE ".\config-files\powershell-profile.ps1" -Force && Write-Host "Powershell profile file updated"

$winTermSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Test-Path $winTermSettingsPath && Copy-Item $winTermSettingsPath ".\config-files\windows-terminal-settings.json" -Force && Write-Host "Windows Terminal settings file updated"