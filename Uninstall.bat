@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "INSTALL_DIR=%LOCALAPPDATA%\Moor"
set "INSTALLED_SCRIPT=%INSTALL_DIR%\InstallAtLogin.bat"
set "LEGACY_SCRIPT=%INSTALL_DIR%\ApplyTaskbarMode.bat"
set "LAUNCHER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Moor.cmd"
set "REG_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
set "VALUE_NAME=MMTaskbarMode"
set "REMOVE_FAILED="
set "REGISTRY_CHANGED="

if not defined LOCALAPPDATA goto :missing_environment
if not defined APPDATA goto :missing_environment

if exist "%LAUNCHER%" (
    del /f /q "%LAUNCHER%" >nul 2>&1
    if exist "%LAUNCHER%" set "REMOVE_FAILED=1"
)

if exist "%INSTALLED_SCRIPT%" (
    del /f /q "%INSTALLED_SCRIPT%" >nul 2>&1
    if exist "%INSTALLED_SCRIPT%" set "REMOVE_FAILED=1"
)

if exist "%LEGACY_SCRIPT%" (
    del /f /q "%LEGACY_SCRIPT%" >nul 2>&1
    if exist "%LEGACY_SCRIPT%" set "REMOVE_FAILED=1"
)

rem Remove the installation directory only when no unrelated files remain.
if exist "%INSTALL_DIR%\" rd "%INSTALL_DIR%" >nul 2>&1

rem Restore Explorer's default behavior by removing Moor's registry value.
"%SystemRoot%\System32\reg.exe" query "%REG_KEY%" /v "%VALUE_NAME%" >nul 2>&1
if not errorlevel 1 (
    "%SystemRoot%\System32\reg.exe" delete "%REG_KEY%" /v "%VALUE_NAME%" /f >nul 2>&1
    if errorlevel 1 (
        set "REMOVE_FAILED=1"
    ) else (
        set "REGISTRY_CHANGED=1"
    )
)

if defined REGISTRY_CHANGED (
    rem Restart only the Explorer shell so the restored setting takes effect now.
    "%SystemRoot%\System32\taskkill.exe" /f /im explorer.exe >nul 2>&1
    start "" "%SystemRoot%\explorer.exe" >nul 2>&1
)

if defined REMOVE_FAILED goto :remove_failed

echo Moor uninstalled successfully.
echo The MMTaskbarMode registry value was removed.
exit /b 0

:missing_environment
echo ERROR: LOCALAPPDATA and APPDATA must be available. 1>&2
exit /b 1

:remove_failed
echo ERROR: Moor could not be completely uninstalled. 1>&2
exit /b 1
