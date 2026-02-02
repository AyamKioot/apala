@echo off
setlocal EnableExtensions EnableDelayedExpansion
title KEEP UI ALIVE - Taskbar/Explorer Watchdog (No dycg kill)
color 0A

set "LOG=%~dp0keep_ui_alive_log.txt"
echo ==== START %date% %time% ==== > "%LOG%"

echo.
echo [1] Fix Winlogon Shell/Userinit (normal Windows repair)...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /t REG_SZ /d "C:\Windows\system32\userinit.exe," /f >> "%LOG%" 2>&1

echo.
echo [2] Remove common user policies that hide taskbar/desktop...
for %%V in (NoDesktop NoTrayItemsDisplay NoSetTaskbar NoRun NoViewContextMenu NoClose) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v %%V /f >> "%LOG%" 2>&1
)
for %%V in (DisableTaskMgr DisableRegistryTools DisableCMD) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v %%V /f >> "%LOG%" 2>&1
)

echo.
echo [3] Start Explorer once...
taskkill /f /im explorer.exe >> "%LOG%" 2>&1
timeout /t 2 /nobreak >nul
start "" "%windir%\explorer.exe"
timeout /t 2 /nobreak >nul

echo.
echo Watchdog ACTIVE. Close this window to stop.
echo Log: %LOG%
echo.

:LOOP
REM If explorer missing, start it
tasklist /fi "imagename eq explorer.exe" | find /i "explorer.exe" >nul
if errorlevel 1 (
  echo [%date% %time%] explorer.exe missing -> start >> "%LOG%"
  start "" "%windir%\explorer.exe"
  timeout /t 2 /nobreak >nul
)

REM Try detect missing taskbar window (Shell_TrayWnd)
REM If PowerShell blocked, this will just be skipped.
powershell -NoProfile -Command ^
"Add-Type @'using System;using System.Runtime.InteropServices;public class U{[DllImport(""user32.dll"")]public static extern IntPtr FindWindow(string c,string n);} '@; ^
$h=[U]::FindWindow('Shell_TrayWnd',$null); if($h -eq [IntPtr]::Zero){ exit 2 } else { exit 0 }" >nul 2>&1

if "%errorlevel%"=="2" (
  echo [%date% %time%] taskbar missing -> restart explorer >> "%LOG%"
  taskkill /f /im explorer.exe >> "%LOG%" 2>&1
  timeout /t 2 /nobreak >nul
  start "" "%windir%\explorer.exe"
  timeout /t 2 /nobreak >nul
)

REM Light refresh
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters >nul 2>&1
timeout /t 3 /nobreak >nul
goto LOOP