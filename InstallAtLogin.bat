@echo off
setlocal EnableExtensions DisableDelayedExpansion

if /i "%~1"=="--apply" goto :apply

set "SOURCE_SCRIPT=%~f0"
set "INSTALL_DIR=%LOCALAPPDATA%\Moor"
set "INSTALLED_SCRIPT=%INSTALL_DIR%\InstallAtLogin.bat"
set "LEGACY_SCRIPT=%INSTALL_DIR%\ApplyTaskbarMode.bat"
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "LAUNCHER=%STARTUP_DIR%\Moor.cmd"

if not defined LOCALAPPDATA goto :missing_environment
if not defined APPDATA goto :missing_environment

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

rem Remove the script used by earlier Moor versions, if present.
if exist "%LEGACY_SCRIPT%" del /f /q "%LEGACY_SCRIPT%" >nul 2>&1

>"%LAUNCHER%" echo @echo off
if errorlevel 1 goto :launcher_failed
>>"%LAUNCHER%" echo call "%INSTALLED_SCRIPT%" --apply ^>nul 2^>^&1
if errorlevel 1 goto :launcher_failed

call "%INSTALLED_SCRIPT%" --apply >nul 2>&1
if errorlevel 1 goto :apply_failed

echo Moor installed successfully.
echo Startup launcher: "%LAUNCHER%"
exit /b 0

:missing_environment
echo ERROR: LOCALAPPDATA and APPDATA must be available. 1>&2
exit /b 1

:create_directory_failed
echo ERROR: A required per-user directory could not be created. 1>&2
exit /b 1

:copy_failed
echo ERROR: InstallAtLogin.bat could not be copied to the per-user installation directory. 1>&2
exit /b 1

:launcher_failed
echo ERROR: The per-user startup launcher could not be created. 1>&2
exit /b 1

:apply_failed
echo ERROR: Moor was installed, but the registry setting could not be applied. 1>&2
exit /b 1

:apply
rem Apply the per-monitor taskbar mode only when it is not already active.
set "REG_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
set "VALUE_NAME=MMTaskbarMode"
set "CURRENT_IS_DESIRED="

for /f "tokens=1,2,3" %%A in ('reg.exe query "%REG_KEY%" /v "%VALUE_NAME%" 2^>nul') do (
    if /i "%%A"=="%VALUE_NAME%" if /i "%%B"=="REG_DWORD" if /i "%%C"=="0x2" set "CURRENT_IS_DESIRED=1"
)

if defined CURRENT_IS_DESIRED exit /b 0

"%SystemRoot%\System32\reg.exe" add "%REG_KEY%" /v "%VALUE_NAME%" /t REG_DWORD /d 2 /f >nul 2>&1
if errorlevel 1 exit /b 1

rem Restart only the Explorer shell so the updated setting takes effect.
"%SystemRoot%\System32\taskkill.exe" /f /im explorer.exe >nul 2>&1
start "" "%SystemRoot%\explorer.exe" >nul 2>&1

exit /b 0
