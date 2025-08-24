# Nova CLI Universal Launcher for Windows PowerShell
# Right-click and "Run with PowerShell" or double-click to install or run Nova CLI

# Set execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Colors
$Blue = "Blue"
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Magenta = "Magenta"
$Cyan = "Cyan"

function Write-Log {
    param($Message)
    Write-Host "[Nova] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param($Message)
    Write-Host "[Nova] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param($Message)
    Write-Host "[Nova] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param($Message)
    Write-Host "[Nova] $Message" -ForegroundColor $Red
}

function Write-Info {
    param($Message)
    Write-Host "[Nova] $Message" -ForegroundColor $Cyan
}

function Show-Banner {
    Write-Host ""
    Write-Host "    _   ______ _    _____         _____ __  ______________    ____ " -ForegroundColor $Magenta
    Write-Host "   / | / / __ \ |  / /   |       / ___// / / / ____/ ____/   / __ \" -ForegroundColor $Magenta
    Write-Host "  /  |/ / / / / | / / /||       \__ \/ / / / __/ / __/     / / / /" -ForegroundColor $Magenta
    Write-Host " / /|  / /_/ /| |/ / ___ |      ___/ / /_/ / /___/ /___    / /_/ / " -ForegroundColor $Magenta
    Write-Host "/_/ |_/\____/ |___/_/  |_|     /____/\____/_____/_____/   /_____/  " -ForegroundColor $Magenta
    Write-Host ""
    Write-Host "Enhanced Coding Agent - Your AI Programming Assistant" -ForegroundColor $Cyan
    Write-Host ""
}

function Test-NovaInstalled {
    try {
        $version = & nova --version 2>$null
        return $true, $version
    }
    catch {
        return $false, $null
    }
}

function Test-Prerequisites {
    Write-Log "Checking system requirements..."
    
    # Check Node.js
    try {
        $nodeVersion = & node --version 2>$null
        $majorVersion = [int]($nodeVersion -replace 'v', '' -split '\.')[0]
        
        if ($majorVersion -lt 20) {
            Write-Error "Node.js 20+ is required. Current version: $nodeVersion"
            Write-Host ""
            Write-Host "Please update Node.js from: https://nodejs.org/"
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }
        
        Write-Success "Node.js $nodeVersion ✓"
    }
    catch {
        Write-Error "Node.js 20+ is required but not installed."
        Write-Host ""
        Write-Host "Please install Node.js from: https://nodejs.org/"
        Write-Host "On Windows: Download from nodejs.org or use chocolatey"
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Check npm
    try {
        $npmVersion = & npm --version 2>$null
        Write-Success "npm v$npmVersion ✓"
    }
    catch {
        Write-Error "npm is required but not found."
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Check git
    try {
        $gitVersion = & git --version 2>$null
        Write-Success "$gitVersion ✓"
    }
    catch {
        Write-Warning "Git not found - some features may be limited"
    }
}

function Install-Nova {
    Write-Log "Installing Nova CLI..."
    Write-Host ""
    
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    
    if (Test-Path "$scriptDir\codex-cli") {
        Write-Info "Installing from local files..."
        Set-Location "$scriptDir\codex-cli"
        
        try {
            & npm install -g . 2>$null
            Write-Success "Nova CLI installed successfully! 🎉"
        }
        catch {
            Write-Error "Installation failed. Please try manual installation:"
            Write-Host "cd codex-cli && npm install -g ."
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
    else {
        Write-Info "Please download the Nova CLI repository first."
        Write-Host "Visit: https://github.com/ceobitch/nova-cli"
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host ""
    Write-Success "Installation complete!"
}

function Show-RunMenu {
    while ($true) {
        Write-Host ""
        Write-Info "What would you like to do?"
        Write-Host ""
        Write-Host "1) Start interactive Nova session"
        Write-Host "2) Show Nova help"
        Write-Host "3) Run custom prompt"
        Write-Host "4) Exit"
        Write-Host ""
        
        $choice = Read-Host "Choose an option (1-4)"
        
        switch ($choice) {
            "1" {
                Write-Host ""
                Write-Info "Starting Nova in interactive mode..."
                Write-Host ""
                & nova
                break
            }
            "2" {
                Write-Host ""
                & nova --help
                Write-Host ""
                Read-Host "Press Enter to continue"
            }
            "3" {
                Write-Host ""
                $userPrompt = Read-Host "Enter your prompt"
                if ($userPrompt) {
                    Write-Host ""
                    & nova $userPrompt
                }
                else {
                    Write-Warning "No prompt entered."
                }
                Write-Host ""
                Read-Host "Press Enter to continue"
            }
            "4" {
                Write-Host ""
                Write-Success "Thanks for using Nova CLI! 👋"
                exit 0
            }
            default {
                Write-Warning "Invalid option. Please choose 1-4."
                Start-Sleep -Seconds 1
            }
        }
    }
}

function Show-MainMenu {
    $installed, $version = Test-NovaInstalled
    
    while ($true) {
        Clear-Host
        Show-Banner
        
        if ($installed) {
            Write-Success "Nova CLI is installed! Version: $version"
            Write-Host ""
            Write-Host "🎯 What would you like to do?"
            Write-Host ""
            Write-Host "1) Run Nova CLI"
            Write-Host "2) Update Nova CLI"
            Write-Host "3) Uninstall Nova CLI"
            Write-Host "4) Show system info"
            Write-Host "5) Exit"
            Write-Host ""
            
            $choice = Read-Host "Choose an option (1-5)"
            
            switch ($choice) {
                "1" {
                    Show-RunMenu
                }
                "2" {
                    Write-Host ""
                    Write-Log "Updating Nova CLI..."
                    Install-Nova
                    $installed, $version = Test-NovaInstalled
                    Write-Host ""
                    Read-Host "Press Enter to continue"
                }
                "3" {
                    Write-Host ""
                    Write-Warning "Uninstalling Nova CLI..."
                    try {
                        & npm uninstall -g nova-cli 2>$null
                        Write-Success "Nova CLI uninstalled successfully."
                    }
                    catch {
                        Write-Error "Failed to uninstall. You may need to remove manually."
                    }
                    Write-Host ""
                    Read-Host "Press Enter to exit"
                    exit 0
                }
                "4" {
                    Write-Host ""
                    Write-Info "System Information:"
                    Write-Host "OS: Windows"
                    Write-Host "Node.js: $(& node --version 2>$null)"
                    Write-Host "npm: $(& npm --version 2>$null)"
                    Write-Host "Nova: $version"
                    try {
                        Write-Host "Git: $(& git --version 2>$null)"
                    }
                    catch {
                        Write-Host "Git: Not installed"
                    }
                    Write-Host ""
                    Read-Host "Press Enter to continue"
                }
                "5" {
                    Write-Host ""
                    Write-Success "Thanks for using Nova CLI! 👋"
                    exit 0
                }
                default {
                    Write-Warning "Invalid option. Please choose 1-5."
                    Start-Sleep -Seconds 1
                }
            }
        }
        else {
            break
        }
    }
}

# Main execution
function Main {
    Clear-Host
    Show-Banner
    Write-Info "Detected: Windows"
    Write-Host ""
    
    $installed, $version = Test-NovaInstalled
    
    if ($installed) {
        Show-MainMenu
    }
    else {
        Write-Log "Nova CLI is not installed. Let's install it!"
        Write-Host ""
        
        Test-Prerequisites
        Write-Host ""
        
        Read-Host "Press Enter to install Nova CLI"
        Write-Host ""
        
        Install-Nova
        
        $installed, $version = Test-NovaInstalled
        if ($installed) {
            Write-Host ""
            Write-Success "🎉 Nova CLI is now ready to use!"
            Write-Host ""
            Read-Host "Press Enter to start using Nova"
            Show-MainMenu
        }
        else {
            Write-Error "Installation verification failed."
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
}

# Run main function
Main

# Keep window open
Write-Host ""
Read-Host "Press Enter to close"
