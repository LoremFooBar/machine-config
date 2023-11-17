$scriptFolderPath = "Q:\machine-config"

function executeScript {
    Param ([string]$script)
    Write-Host "executing $scriptFolderPath\$script ..."
    Invoke-Expression $scriptFolderPath\$script
}

Install-WindowsUpdate -acceptEula

executeScript "remove-default-apps.ps1"