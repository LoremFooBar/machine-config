Test-Path $PROFILE && Copy-Item $PROFILE ".\config-files\powershell-profile.ps1" -Force && Write-Host "Powershell profile file updated"

$winTermSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Test-Path $winTermSettingsPath && Copy-Item $winTermSettingsPath ".\config-files\windows-terminal-settings.json" -Force && Write-Host "Windows Terminal settings file updated"

$wingetSettingsPath = (winget settings export | ConvertFrom-Json).userSettingsFile
Copy-Item $wingetSettingsPath ".\config-files\winget-user-settings.json" && Write-Host "Winget user settings file updated"
