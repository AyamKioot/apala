@echo off
title RECOVER UI CLOUD - Explorer / Taskbar / Desktop
color 0A

set "LOG=%~dp0recover_ui_log.txt"
echo ==== START %date% %time% ==== > "%LOG%"

echo.
echo [0] Cloud VM detected - skip net session check
echo Skipping admin check (LanmanServer often disabled on cloud) >> "%LOG%"

echo.
echo [1/9] Start Server service (LanmanServer)...
sc config lanmanserver start= auto >> "%LOG%" 2>&1
net start lanmanserver >> "%LOG%" 2>&1

echo.
echo [2/9] Kill explorer (if running)...
taskkill /f /im explorer.exe >> "%LOG%" 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [3/9] Fix Winlogon Shell + Userinit...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /t REG_SZ /d "C:\Windows\system32\userinit.exe," /f >> "%LOG%" 2>&1

echo.
echo [4/9] Remove common policies (taskbar / desktop / cmd / taskmgr)...
for %%V in (NoDesktop NoTrayItemsDisplay NoSetTaskbar NoStartMenuMorePrograms NoRun NoViewContextMenu NoClose) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v %%V /f >> "%LOG%" 2>&1
)
for %%V in (DisableTaskMgr DisableRegistryTools DisableCMD) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v %%V /f >> "%LOG%" 2>&1
)

echo.
echo [5/9] Fix user shell folders...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Desktop" /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Documents" /f >> "%LOG%" 2>&1

echo.
echo [6/9] Start explorer (multi fallback)...
start "" explorer.exe
timeout /t 2 /nobreak >nul

if exist "%windir%\explorer.exe" (
  "%windir%\explorer.exe" >> "%LOG%" 2>&1
)

rundll32.exe shell32.dll,Control_RunDLL >> "%LOG%" 2>&1

echo.
echo [7/9] Open tools (test)...
start "" taskmgr.exe
timeout /t 1 /nobreak >nul
start "" ms-settings:
start "" control.exe

echo.
echo [8/9] Check explorer process...
tasklist /fi "imagename eq explorer.exe" >> "%LOG%" 2>&1

echo.
echo [9/9] Done.
echo Log:
echo %LOG%
echo.
pause
