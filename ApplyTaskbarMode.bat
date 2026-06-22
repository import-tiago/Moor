@echo off
setlocal EnableExtensions DisableDelayedExpansion

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
