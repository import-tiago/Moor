@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "INSTALL_DIR=%LOCALAPPDATA%\Moor"
set "INSTALLED_SCRIPT=%INSTALL_DIR%\ApplyTaskbarMode.bat"
set "LAUNCHER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Moor.cmd"
set "REMOVE_FAILED="

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

rem Remove the installation directory only when no unrelated files remain.
if exist "%INSTALL_DIR%\" rd "%INSTALL_DIR%" >nul 2>&1

if defined REMOVE_FAILED goto :remove_failed

echo Moor uninstalled successfully.
echo The MMTaskbarMode registry value was not changed.
exit /b 0

:missing_environment
echo ERROR: LOCALAPPDATA and APPDATA must be available. 1>&2
exit /b 1

:remove_failed
echo ERROR: One or more Moor files could not be removed. 1>&2
echo The MMTaskbarMode registry value was not changed. 1>&2
exit /b 1
