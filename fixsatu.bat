@echo off
setlocal EnableExtensions EnableDelayedExpansion
title FIX ALL CLOUD UI - Explorer/Taskbar/Desktop/Wallpaper
color 0A

set "LOG=%~dp0fix_all_cloud_ui_log.txt"
echo ==== FIX ALL CLOUD UI START %date% %time% ==== > "%LOG%"

echo.
echo [0/10] Info...
echo Running from: %~dp0 >> "%LOG%"
echo User: %USERNAME% >> "%LOG%"
whoami >> "%LOG%" 2>&1

echo.
echo [1/10] Try start Server service (LanmanServer) (optional)...
sc config lanmanserver start= auto >> "%LOG%" 2>&1
net start lanmanserver >> "%LOG%" 2>&1

echo.
echo [2/10] Fix Winlogon Shell + Userinit...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /t REG_SZ /d "C:\Windows\system32\userinit.exe," /f >> "%LOG%" 2>&1

echo.
echo [3/10] Remove common restriction policies (Explorer/System)...
for %%V in (NoDesktop NoTrayItemsDisplay NoSetTaskbar NoStartMenuMorePrograms NoRun NoViewContextMenu NoClose) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v %%V /f >> "%LOG%" 2>&1
)
for %%V in (DisableTaskMgr DisableRegistryTools DisableCMD) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v %%V /f >> "%LOG%" 2>&1
)

echo.
echo [4/10] Fix user shell folders (Desktop/Documents)...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Desktop" /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Documents" /f >> "%LOG%" 2>&1

echo.
echo [5/10] Kill explorer clean...
taskkill /f /im explorer.exe >> "%LOG%" 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [6/10] Start explorer (multi-fallback)...
if exist "%windir%\explorer.exe" (
  start "" "%windir%\explorer.exe"
) else (
  start "" explorer.exe
)
timeout /t 2 /nobreak >nul
start "" explorer.exe
timeout /t 2 /nobreak >nul

echo.
echo [7/10] Force desktop refresh + icon cache...
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters >> "%LOG%" 2>&1
ie4uinit.exe -ClearIconCache >> "%LOG%" 2>&1
ie4uinit.exe -show >> "%LOG%" 2>&1

echo.
echo [8/10] Force wallpaper to Windows default...
set "WP=C:\Windows\Web\Wallpaper\Windows\img0.jpg"
if exist "%WP%" (
  reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%WP%" /f >> "%LOG%" 2>&1
  RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters >> "%LOG%" 2>&1
) else (
  echo Wallpaper file not found: %WP% >> "%LOG%"
)

echo.
echo [9/10] Open safer control panels (avoid ms-settings)...
start "" control.exe >> "%LOG%" 2>&1
start "" desk.cpl >> "%LOG%" 2>&1
start "" sysdm.cpl >> "%LOG%" 2>&1
start "" appwiz.cpl >> "%LOG%" 2>&1

echo.
echo [10/10] Status check...
echo --- Winlogon Shell/Userinit --- >> "%LOG%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell >> "%LOG%" 2>&1
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit >> "%LOG%" 2>&1
echo --- Explorer process --- >> "%LOG%"
tasklist /fi "imagename eq explorer.exe" >> "%LOG%" 2>&1

echo.
echo DONE. Log saved:
echo %LOG%
echo.
echo Kalau UI masih blank, restart VM/PC sekali setelah ini.
pause
endlocal