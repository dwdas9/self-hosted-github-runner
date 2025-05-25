@echo off
echo.
echo ==========================================
echo   GitHub Actions Self-Hosted Runner Setup
echo ==========================================
echo.

:: Check if PowerShell is available
powershell -Command "Write-Host 'PowerShell is available'" >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell is not available or not in PATH
    echo Please install PowerShell and try again
    pause
    exit /b 1
)

:: Run the PowerShell setup script
echo Starting setup...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0setup-agent.ps1"

echo.
echo Setup completed. Press any key to exit...
pause >nul
