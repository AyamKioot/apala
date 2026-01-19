@echo off
setlocal EnableExtensions EnableDelayedExpansion
title FIX ALL FORCE CLOSE - ONE CLICK

:: ================= ADMIN CHECK =================
net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo.
  echo [!] WAJIB Run as Administrator
  echo     Klik kanan file ini ^> Run as administrator
  pause
  exit /b
)

:: ================= SETUP =================
set "ROOT=%~dp0"
set "BK=%ROOT%FC_BACKUP_%DATE:~-4%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "BK=%BK: =0%"
mkdir "%BK%" >nul 2>&1

echo ==========================================
echo   FIX FORCE CLOSE - TOTAL ONE CLICK
echo   Backup registry: %BK%
echo ==========================================
echo.

:: ================= 1. RESTORE WINDOWS SHELL =================
echo [1/7] Restore Windows Shell (explorer.exe)
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "%BK%\Winlogon.reg" /y >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" ^
 /v Shell /t REG_SZ /d explorer.exe /f >nul
echo     OK.

:: ================= 2. REMOVE IFEO HIJACK =================
echo.
echo [2/7] Remove IFEO (Debugger trap)

for %%E in (
  cmd.exe
  powershell.exe
  regedit.exe
  explorer.exe
  steam.exe
  explorer++.exe
) do (
  reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%E" /f >nul 2>&1
  reg delete "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%E" /f >nul 2>&1
)

echo     OK.

:: ================= 3. REMOVE SILENT PROCESS EXIT =================
echo.
echo [3/7] Remove SilentProcessExit auto-terminate

for %%E in (
  cmd.exe
  powershell.exe
  regedit.exe
  explorer.exe
  steam.exe
  explorer++.exe
) do (
  reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\%%E" /f >nul 2>&1
  reg delete "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\%%E" /f >nul 2>&1
)

echo     OK.

:: ================= 4. REMOVE POLICY BLOCK =================
echo.
echo [4/7] Remove Policy Blocks (DisallowRun / RestrictRun)

for %%K in (
 "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
 "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
) do (
  reg delete %%K /v DisallowRun /f >nul 2>&1
  reg delete %%K /v RestrictRun /f >nul 2>&1
)

echo     OK.

:: ================= 5. CLEAN STARTUP KILLERS =================
echo.
echo [5/7] Clean Startup folder (BAT killer)

del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*.bat" >nul 2>&1
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*.cmd" >nul 2>&1

echo     OK.

:: ================= 6. DISABLE SUSPICIOUS SCHEDULED TASK =================
echo.
echo [6/7] Disable suspicious Scheduled Tasks

for /f "tokens=*" %%T in ('schtasks /query /fo LIST ^| findstr /I "TaskName"') do (
  echo %%T | findstr /I "kill taskkill protector watchdog" >nul && (
    for /f "tokens=2 delims=:" %%N in ("%%T") do (
      schtasks /Change /TN "%%N" /Disable >nul 2>&1
    )
  )
)

echo     OK.

:: ================= 7. RESTART EXPLORER =================
echo.
echo [7/7] Restart Explorer

taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 >nul
start explorer.exe

echo.
echo ==========================================
echo   DONE.
echo   - CMD / PowerShell / Regedit HARUS BALIK
echo   - Steam / Explorer++ TIDAK FC LAGI
echo   - Backup registry ada di folder ini
echo ==========================================
pause
exit /b