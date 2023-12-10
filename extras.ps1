# install node LTS
nvm install lts
nvm use lts

# install whatsapp
Write-Host "Installing WhatsApp..."
winget install 9NKSQGP7F2NH --accept-package-agreements

# install wsl
wsl --install

# copy powershell profile
Write-Host "Copying Powershell profile..."
if (!(Test-Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force
}
Copy-Item ".\config-files\powershell-profile.ps1" $PROFILE
. $PROFILE

# copy windows terminal settings
$winTermSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Write-Host "Copying Windows Terminal settings..."
if (Test-Path $winTermSettingsPath) {
  Copy-Item $winTermSettingsPath "$winTermSettingsPath.bkp" && Write-Host "Backup created at: $winTermSettingsPath.bkp"
  Copy-Item ".\config-files\windows-terminal-settings.json" $winTermSettingsPath
}
else {
  Write-Host "Windows Terminal settings file was not found at: $winTermSettingsPath"
}

# copy winget user settings
Write-Host "Copying WinGet user settings file..."
$wingetSettingsPath = (winget settings export | ConvertFrom-Json).userSettingsFile
Copy-Item $wingetSettingsPath ($wingetSettingsPath + ".bkp") -Force && Write-Host "Backup created at: $wingetSettingsPath.bkp"
Copy-Item ".\config-files\winget-user-settings.json" $wingetSettingsPath