@echo off
setlocal EnableExtensions EnableDelayedExpansion
title KEEP TASKBAR ALIVE (Watchdog Explorer)
color 0A

REM ====== LOG ======
set "LOG=%~dp0keep_taskbar_alive_log.txt"
echo ==== START %date% %time% ==== > "%LOG%"

REM ====== Ensure Winlogon Shell is explorer ======
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1

REM ====== Remove common policy restrictions (no bypass, only normal user policies) ======
for %%V in (NoDesktop NoTrayItemsDisplay NoSetTaskbar NoRun NoViewContextMenu NoClose) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v %%V /f >> "%LOG%" 2>&1
)
for %%V in (DisableTaskMgr DisableRegistryTools DisableCMD) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v %%V /f >> "%LOG%" 2>&1
)

REM ====== Start explorer once ======
taskkill /f /im explorer.exe >> "%LOG%" 2>&1
timeout /t 2 /nobreak >nul
start "" "%windir%\explorer.exe"
timeout /t 2 /nobreak >nul

echo.
echo Watchdog running. Close this window to stop.
echo Log: %LOG%
echo.

REM ====== Loop forever: if Explorer/taskbar missing, restart Explorer ======
:LOOP
REM 1) If explorer.exe not running -> start it
tasklist /fi "imagename eq explorer.exe" | find /i "explorer.exe" >nul
if errorlevel 1 (
  echo [%date% %time%] explorer.exe missing -> starting >> "%LOG%"
  start "" "%windir%\explorer.exe"
  timeout /t 2 /nobreak >nul
)

REM 2) Check taskbar window (Shell_TrayWnd) using powershell if available
powershell -NoProfile -Command ^
"$p=Get-Process explorer -ErrorAction SilentlyContinue; ^
$tb = Get-Process explorer -ErrorAction SilentlyContinue | Out-Null; ^
$w = Get-Process explorer -ErrorAction SilentlyContinue; ^
Add-Type @' using System; using System.Runtime.InteropServices; public class U{[DllImport(\"user32.dll\")] public static extern IntPtr FindWindow(string c,string n);} '@; ^
$h=[U]::FindWindow('Shell_TrayWnd',$null); ^
if($h -eq [IntPtr]::Zero){ exit 2 } else { exit 0 }" >nul 2>&1

if "%errorlevel%"=="2" (
  echo [%date% %time%] taskbar missing -> restart explorer >> "%LOG%"
  taskkill /f /im explorer.exe >> "%LOG%" 2>&1
  timeout /t 2 /nobreak >nul
  start "" "%windir%\explorer.exe"
  timeout /t 2 /nobreak >nul
)

REM 3) Refresh desktop parameters (lightweight)
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters >nul 2>&1

timeout /t 3 /nobreak >nul
goto LOOP