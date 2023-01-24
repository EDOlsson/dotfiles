param (
    [switch]$InstallPackages,
    [switch]$SetupDotFiles,
    [switch]$ConfigureGit,
    [switch]$InstallPoshGit,
    [switch]$InstallFonts
)

$runAllTasks = -not ($InstallPackages.IsPresent -or $SetupDotFiles.IsPresent -or $ConfigureGit.IsPresent -or $InstallPoshGit.IsPresent -or $InstallFonts.IsPresent)

$messages = @{
    InstallingPackages = "Installing packages"
    FinishedInstallingPackages = "Finished installing packages"
    SettingUpDotFiles = "Setting up dotfiles"
    FinishedSettingUpDotFiles = "Finished setting up dotfiles"
    ConfiguringGit = "Configuring git"
    FinishedConfiguringGit = "Finished configuring git"
    InstallingPoshGit = "Installing posh-git"
    FinishedInstallingPoshGit = "Finished installing posh-git"
    Done = "Done"
}

function Write-Progress([string] $message) {
    $maxMessageLength = ($messages.Values | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
    # Add 2 to length to accommodate spaces & calculate spacing
    $leadingSpaceCount = ($maxMessageLength + 2 - $message.Length) / 2
    if ($leadingSpaceCount -le 0) {
        $leadingSpaceCount = 1
    }
    $leadingSpaces = " " * $leadingSpaceCount
    $leader = '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    Write-Output "$leader$leadingSpaces$message$leadingSpaces$leader"
}

#
# Upgrade/install nice utilities
#
if ($runAllTasks -or $InstallPackages.IsPresent) {
    Write-Progress $messages.InstallingPackages
    choco upgrade git -y
    choco install powershell-core -y
    choco install neovim -y
    choco install ripgrep -y
    choco install fzf -y
    choco install conemu -y
    choco install microsoft-windows-terminal -y

    Start-Process -FilePath 'https://learn.microsoft.com/en-us/troubleshoot/developer/visualstudio/cpp/libraries/c-runtime-packages-desktop-bridge#how-to-install-and-update-desktop-framework-packages'

    Write-Progress $messages.FinishedInstallingPackages
}

#
# Set up dotfiles using symlinks
#
if ($runAllTasks -or $SetupDotFiles.IsPresent) {
    Write-Progress $messages.SettingUpDotFiles

    # set up the symlinks
    $mappings = @(
        @{
            source = "$Env:USERPROFILE\.gitconfig"
            dest = "$PWD\.gitconfig"
        },
        @{
            source = "$Env:LOCALAPPDATA\nvim"
            dest = "$PWD\NeoVim\"
        },
        @{
            source = "$Env:USERPROFILE\.vsvimrc"
            dest = "$PWD\VsVim\.vsvimrc"
        }
    )

    foreach ($mapping in $mappings) {
        Write-Output "....Creating symlink for $($mapping.source) -> $($mapping.dest)"

        if (Test-Path -Path $mapping.source) {
            $(Get-Item $mapping.source) | Remove-Item -Recurse -Force | Out-Null
        }

        New-Item -ItemType SymbolicLink -Path $mapping.source -Target $mapping.dest -Force | Out-Null
    }

    # git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA/nvim-data/site/pack/packer/packer.nvim"

    #
    # Configure PowerShell
    #

    Get-Content "$PWD\PowerShell\profile.ps1" | Out-File $Env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

    Write-Progress $messages.FinishedSettingUpDotFiles
}

#
# Install posh-git
#
if ($runAllTasks -or $InstallPoshGit.IsPresent) {
    Write-Progress $messages.InstallingPoshGit

    Install-Module posh-git -Scope CurrentUser -Force

    Write-Progress $messages.FinishedInstallingPoshGit
}

#
# Set environment variables
#
Push-Location
Set-Location Env:
Set-Content -Path FZF_DEFAULT_COMMAND -Value 'rg --files'
Set-Content -Path FZF_DEFAULT_OPTS -Value '-m --height 50% --border'
Pop-Location

#
# Download Caskaydia Cove Nerd Font for install
#
if ($runAllTasks -or $InstallFonts.IsPresent) {
    Invoke-WebRequest -Uri 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip' -OutFile "~\Desktop\CascadiaCode.zip"
}

if ($runAllTasks -or $InstallPackages.IsPresent) {
    Start-Process "C:\Program Files\PowerShell\7\pwsh.exe"
}

#
# Let user know setup is done
#
Write-Progress $messages.Done
