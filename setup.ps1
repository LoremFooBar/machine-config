$scriptFolderPath = "Q:\machine-config"

function executeScript {
    Param ([string]$script)
    Write-Host "executing $scriptFolderPath\$script ..."
    Invoke-Expression $scriptFolderPath\$script
}

[System.Environment]::SetEnvironmentVariable("POWERSHELL_UPDATECHECK", "Off", [System.EnvironmentVariableTarget]::Machine)

Install-WindowsUpdate -acceptEula

executeScript "remove-default-apps.ps1"