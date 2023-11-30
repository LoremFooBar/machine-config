# Machine Configuration

Use Boxstarter and WinGet to setup my dev machine.

## Steps

### Prepare

1. Disable UAC.

2. Update [App Installer](https://www.microsoft.com/p/app-installer/9nblggh4nns1) on the Microsoft Store to get the latest `winget` version. Make sure `(winget --version) -ge 1.6`

3. Install Git: `winget install git.git`

4. Create [Dev Drive](https://learn.microsoft.com/en-us/windows/dev-drive/) with drive letter Q.

5. Clone this repo: `git clone https://github.com/LoremFooBar/machine-config/ Q:\machine-config`

6. Install latest Powershell: `winget install Microsoft.PowerShell`

### Boxstarter Script

Install all available Windows updates and remove some redundant default apps.

1. Install [Boxstarter](https://boxstarter.org) (run as admin, restart terminal when done):

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); Get-Boxstarter -Force
   ```

2. Run setup with Boxstarter (as admin):

   ```powershell
   Import-Module Boxstarter.Chocolatey
   Set-ExecutionPolicy Unrestricted -Force -Scope LocalMachine
   Install-BoxstarterPackage -PackageName "Q:\machine-config\setup.ps1"
   ```

### Winget Packages

Run WinGet configuration (**NOT** as admin):

```
winget configure -f Q:\machine-config\winget.dsc.yaml --accept-configuration-agreements
```

### Extras

1. [Download](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip) and install latest CascadiaCode Nerd Font.

2. Run `.\extras.ps1`.

3. Enable UAC.

## My Preferred Pinned Apps Order

1. Mail (Outlook)
2. Browser (Firefox)
3. Coding (JetBrains, VS Code, Notepad++, Fork, Postman)
4. Terminal
5. Chat (Teams, WhatsApp)
6. Other (Spotify, qBittorrent, Phone Link)
7. Extra browsers (Edge)
8. Explorer and Files app
