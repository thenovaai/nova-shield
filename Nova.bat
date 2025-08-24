@echo off
REM Nova CLI Universal Launcher for Windows
REM Double-click this file to install or run Nova CLI

setlocal enabledelayedexpansion

REM Colors for Windows (limited support)
set "BLUE=[94m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "PURPLE=[95m"
set "CYAN=[96m"
set "NC=[0m"

REM Show banner
echo.
echo %PURPLE%    _   ______ _    _____         _____ __  ______________    ____ %NC%
echo %PURPLE%   / ^| / / __ \ ^|  / /   ^|       / ___// / / / ____/ ____/   / __ \%NC%
echo %PURPLE%  /  ^|/ / / / / ^| / / /^|^|       \__ \/ / / / __/ / __/     / / / /%NC%
echo %PURPLE% / /^|  / /_/ /^| ^|/ / ___ ^|      ___/ / /_/ / /___/ /___    / /_/ / %NC%
echo %PURPLE%/_/ ^|_/\____/ ^|___/_/  ^|_^|     /____/\____/_____/_____/   /_____/  %NC%
echo.
echo %CYAN%Enhanced Coding Agent - Your AI Programming Assistant%NC%
echo.

REM Check if Nova is installed
where nova >nul 2>&1
if %errorlevel% == 0 (
    echo %GREEN%[Nova]%NC% Nova CLI is already installed!
    for /f "tokens=*" %%i in ('nova --version 2^>nul') do set "NOVA_VERSION=%%i"
    echo %GREEN%[Nova]%NC% Version: !NOVA_VERSION!
    goto :run_menu
) else (
    echo %BLUE%[Nova]%NC% Nova CLI is not installed. Let's install it!
    goto :install
)

:install
echo.
echo %BLUE%[Nova]%NC% Checking prerequisites...

REM Check Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[Nova]%NC% Node.js 20+ is required but not installed.
    echo.
    echo Please install Node.js from: https://nodejs.org/
    echo On Windows: Download from nodejs.org or use chocolatey
    echo.
    pause
    exit /b 1
)

REM Check Node.js version
for /f "tokens=1 delims=v" %%i in ('node --version') do set "NODE_VERSION=%%i"
for /f "tokens=1 delims=." %%i in ("%NODE_VERSION%") do set "MAJOR_VERSION=%%i"

if %MAJOR_VERSION% lss 20 (
    echo %RED%[Nova]%NC% Node.js 20+ is required. Current version: v%NODE_VERSION%
    echo.
    echo Please update Node.js from: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo %GREEN%[Nova]%NC% Node.js v%NODE_VERSION% ✓

REM Check npm
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[Nova]%NC% npm is required but not found.
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('npm --version') do set "NPM_VERSION=%%i"
echo %GREEN%[Nova]%NC% npm v%NPM_VERSION% ✓

echo.
echo %BLUE%[Nova]%NC% Installing Nova CLI...
echo.

REM Check if we have local codex-cli directory
if exist "codex-cli" (
    echo %CYAN%[Nova]%NC% Installing from local files...
    cd codex-cli
    npm install -g . >nul 2>&1
    if %errorlevel% == 0 (
        echo %GREEN%[Nova]%NC% Nova CLI installed successfully! 🎉
    ) else (
        echo %RED%[Nova]%NC% Installation failed. Please try manual installation:
        echo cd codex-cli && npm install -g .
        echo.
        pause
        exit /b 1
    )
) else (
    echo %CYAN%[Nova]%NC% Please download the Nova CLI repository first.
    echo Visit: https://github.com/ceobitch/nova-cli
    echo.
    pause
    exit /b 1
)

echo.
echo %GREEN%[Nova]%NC% Installation complete!
goto :run_menu

:run_menu
echo.
echo %CYAN%[Nova]%NC% What would you like to do?
echo.
echo 1) Start interactive Nova session
echo 2) Show Nova help
echo 3) Run custom prompt
echo 4) Exit
echo.

set /p "choice=Choose an option (1-4): "

if "%choice%"=="1" (
    echo.
    echo %CYAN%[Nova]%NC% Starting Nova in interactive mode...
    echo.
    nova
    goto :run_menu
) else if "%choice%"=="2" (
    echo.
    nova --help
    echo.
    pause
    goto :run_menu
) else if "%choice%"=="3" (
    echo.
    set /p "user_prompt=Enter your prompt: "
    if not "!user_prompt!"=="" (
        echo.
        nova "!user_prompt!"
    ) else (
        echo %YELLOW%[Nova]%NC% No prompt entered.
    )
    echo.
    pause
    goto :run_menu
) else if "%choice%"=="4" (
    echo.
    echo %GREEN%[Nova]%NC% Thanks for using Nova CLI! 👋
    exit /b 0
) else (
    echo %YELLOW%[Nova]%NC% Invalid option. Please choose 1-4.
    timeout /t 2 >nul
    goto :run_menu
)

:end
pause
