@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "SOURCE_SCRIPT=%~dp0ApplyTaskbarMode.bat"
set "INSTALL_DIR=%LOCALAPPDATA%\Moor"
set "INSTALLED_SCRIPT=%INSTALL_DIR%\ApplyTaskbarMode.bat"
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "LAUNCHER=%STARTUP_DIR%\Moor.cmd"

if not defined LOCALAPPDATA goto :missing_environment
if not defined APPDATA goto :missing_environment
if not exist "%SOURCE_SCRIPT%" goto :missing_source

if not exist "%INSTALL_DIR%" (
    md "%INSTALL_DIR%" >nul 2>&1
    if errorlevel 1 goto :create_directory_failed
)

if not exist "%STARTUP_DIR%" (
    md "%STARTUP_DIR%" >nul 2>&1
    if errorlevel 1 goto :create_directory_failed
)

copy /y "%SOURCE_SCRIPT%" "%INSTALLED_SCRIPT%" >nul 2>&1
if errorlevel 1 goto :copy_failed

>"%LAUNCHER%" echo @echo off
if errorlevel 1 goto :launcher_failed
>>"%LAUNCHER%" echo call "%INSTALLED_SCRIPT%" ^>nul 2^>^&1
if errorlevel 1 goto :launcher_failed

call "%INSTALLED_SCRIPT%" >nul 2>&1
if errorlevel 1 goto :apply_failed

echo Moor installed successfully.
echo Startup launcher: "%LAUNCHER%"
exit /b 0

:missing_environment
echo ERROR: LOCALAPPDATA and APPDATA must be available. 1>&2
exit /b 1

:missing_source
echo ERROR: ApplyTaskbarMode.bat was not found next to this installer. 1>&2
exit /b 1

:create_directory_failed
echo ERROR: A required per-user directory could not be created. 1>&2
exit /b 1

:copy_failed
echo ERROR: ApplyTaskbarMode.bat could not be copied to the per-user installation directory. 1>&2
exit /b 1

:launcher_failed
echo ERROR: The per-user startup launcher could not be created. 1>&2
exit /b 1

:apply_failed
echo ERROR: Moor was installed, but the registry setting could not be applied. 1>&2
exit /b 1
