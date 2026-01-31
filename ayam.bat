@echo off
setlocal EnableExtensions EnableDelayedExpansion
title RECOVER UI FULL - Explorer/Taskbar/Desktop Fix
color 0A

set "LOG=%~dp0recover_ui_log.txt"
echo ==== START %date% %time% ==== > "%LOG%"

echo.
echo [1/9] Cek akses admin...
net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo [-] Script ini harus Run as Administrator! >> "%LOG%"
  echo [-] HARUS RUN AS ADMIN. Klik kanan BAT -> Run as administrator.
  echo.
  pause
  exit /b
)
echo [+] Admin OK. >> "%LOG%"

echo.
echo [2/9] Matikan explorer lama (kalau ada)...
taskkill /f /im explorer.exe >> "%LOG%" 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [3/9] Balikin Winlogon Shell & Userinit (sering dibajak)...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >> "%LOG%" 2>&1

REM Userinit default: C:\Windows\system32\userinit.exe,
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /t REG_SZ /d "C:\Windows\system32\userinit.exe," /f >> "%LOG%" 2>&1

echo.
echo [4/9] Hapus policy yang sering bikin desktop/taskbar hilang...
REM Policy Explorer (HKCU)
for %%V in (NoDesktop NoTrayItemsDisplay NoSetTaskbar NoStartMenuMorePrograms NoRun NoViewContextMenu NoClose) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v %%V /f >> "%LOG%" 2>&1
)

REM Policy System (HKCU) - TaskMgr/Regedit sering dimatiin
for %%V in (DisableTaskMgr DisableRegistryTools DisableCMD) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v %%V /f >> "%LOG%" 2>&1
)

REM Safer cleanup: jangan hapus key-nya, cuma value yang umum
echo [+] Policy cleanup done. >> "%LOG%"

echo.
echo [5/9] Balikin Shell Folders penting (kadang diarahkan ke folder aneh)...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Desktop" /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Documents" /f >> "%LOG%" 2>&1

echo.
echo [6/9] Start Explorer dengan beberapa cara (fallback)...
start "" explorer.exe
timeout /t 2 /nobreak >nul

REM Fallback 1
if not exist "%windir%\explorer.exe" (
  echo [-] explorer.exe tidak ditemukan di %windir% >> "%LOG%"
) else (
  "%windir%\explorer.exe" >> "%LOG%" 2>&1
)
timeout /t 2 /nobreak >nul

REM Fallback 2: memanggil shell lewat rundll32
rundll32.exe shell32.dll,Control_RunDLL >> "%LOG%" 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [7/9] Buka Task Manager / Settings / Control Panel buat tes...
start "" taskmgr.exe
timeout /t 1 /nobreak >nul

REM Settings via start
start "" ms-settings: >> "%LOG%" 2>&1

REM Fallback Settings via powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process 'ms-settings:'" >> "%LOG%" 2>&1

REM Control Panel fallback
start "" control.exe >> "%LOG%" 2>&1

echo.
echo [8/9] Cek status explorer di Tasklist...
tasklist /fi "imagename eq explorer.exe" >> "%LOG%" 2>&1

echo.
echo [9/9] Selesai. Log disimpan di:
echo %LOG%
echo.
echo Kalau masih blank: coba restart PC sekali setelah ini.
echo.
pause
endlocal
