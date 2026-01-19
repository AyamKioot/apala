@echo off
setlocal EnableExtensions EnableDelayedExpansion
title FIX FC - Steam/Explorer++/CMD/Explorer Shell

:: ========== Admin check ==========
net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo [!] Jalankan sebagai Administrator: klik kanan ^> Run as administrator
  pause
  exit /b 1
)

:: ========== Setup backup folder ==========
set "BK=%~dp0REG_BACKUP_%DATE:~-4%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "BK=%BK: =0%"
mkdir "%BK%" >nul 2>&1

echo ============================================
echo  FIX FORCE-CLOSE (FC) - Windows
echo  Target: steam.exe, explorer++.exe, cmd.exe + shell explorer
echo  Backup registry: "%BK%"
echo ============================================
echo.

:: ========== 1) Restore Windows shell ==========
echo [1/5] Balikin Shell ke explorer.exe ...
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "%BK%\Winlogon_HKLM.reg" /y >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d explorer.exe /f >nul
echo    OK.

:: ========== Helper to fix IFEO/SilentProcessExit ==========
call :FixIFEO steam.exe
call :FixIFEO explorer++.exe
call :FixIFEO cmd.exe

:: ========== 3) Check common policy blocks (optional) ==========
echo.
echo [4/5] Cek policy blok aplikasi (DisallowRun/RestrictRun) ...
for %%K in (
  "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
) do (
  reg query %%K /v DisallowRun >nul 2>&1 && (
    echo    [!] Ketemu DisallowRun di %%K
    reg export %%K "%BK%\Policies_Explorer_%%~nK.reg" /y >nul 2>&1
    echo    Mau hapus DisallowRun? (bisa bikin app ga keblok)
    choice /c YN /m "    Pilih:"
    if !errorlevel! EQU 1 (
      reg delete %%K /v DisallowRun /f >nul 2>&1
      echo    DisallowRun dihapus.
    ) else (
      echo    Skip.
    )
  )
  reg query %%K /v RestrictRun >nul 2>&1 && (
    echo    [!] Ketemu RestrictRun di %%K
    reg export %%K "%BK%\Policies_Explorer2_%%~nK.reg" /y >nul 2>&1
    echo    Mau hapus RestrictRun?
    choice /c YN /m "    Pilih:"
    if !errorlevel! EQU 1 (
      reg delete %%K /v RestrictRun /f >nul 2>&1
      echo    RestrictRun dihapus.
    ) else (
      echo    Skip.
    )
  )
)

:: ========== 4) Restart Explorer ==========
echo.
echo [5/5] Restart Explorer ...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 >nul
start "" explorer.exe
echo    OK.

echo.
echo ============================================
echo  SELESAI. Kalau masih FC:
echo  - cek Task Scheduler yang jalanin taskkill
echo  - cek Startup folder ada .bat killer
echo  Backup ada di: "%BK%"
echo ============================================
pause
exit /b 0

:: ----------------------------------------------------------
:FixIFEO
set "EXE=%~1"
echo.
echo [2/5] Fix IFEO/SilentProcessExit untuk %EXE% ...

:: IFEO paths
set "IFEO1=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%EXE%"
set "IFEO2=HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%EXE%"
set "SPE1=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\%EXE%"
set "SPE2=HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\%EXE%"

:: Backup relevant keys if exist
reg query "%IFEO1%" >nul 2>&1 && reg export "%IFEO1%" "%BK%\IFEO_HKLM_%EXE%.reg" /y >nul 2>&1
reg query "%IFEO2%" >nul 2>&1 && reg export "%IFEO2%" "%BK%\IFEO_HKCU_%EXE%.reg" /y >nul 2>&1
reg query "%SPE1%"  >nul 2>&1 && reg export "%SPE1%"  "%BK%\SPE_HKLM_%EXE%.reg"  /y >nul 2>&1
reg query "%SPE2%"  >nul 2>&1 && reg export "%SPE2%"  "%BK%\SPE_HKCU_%EXE%.reg"  /y >nul 2>&1

:: Remove Debugger hijack (common FC cause)
reg delete "%IFEO1%" /v Debugger /f >nul 2>&1
reg delete "%IFEO2%" /v Debugger /f >nul 2>&1

:: Remove SilentProcessExit auto-terminate configs
reg delete "%SPE1%" /f >nul 2>&1
reg delete "%SPE2%" /f >nul 2>&1

echo    OK (Debugger/SilentProcessExit dibersihin jika ada).
exit /b 0