@echo off
title VNC KILLER 24/7 - AUTO HUNT MODE
mode con cols=70 lines=15
color 0a

echo ======================================
echo VNC KILLER 24/7 - JALAN NONSTOP
echo ======================================
echo.
echo [*] Script jalan terus bro, tiap 1 detik ngecek VNC...
echo [*] Kalo ada VNC nyala, langsung DIBUNUH!
echo [*] Tekan Ctrl+C buat berhenti
echo ======================================
echo.

:LOOP
powershell -Command "
$procs = @('vncserver','winvnc','winvnc4','tightvncserver','ultravnc','vncviewer','tvnserver','tvncviewer');
foreach($p in $procs){ 
    try { 
        $proc = Get-Process -Name $p -ErrorAction Stop;
        foreach($x in $proc){ 
            Stop-Process -Id $x.Id -Force -ErrorAction SilentlyContinue;
            Write-Host \"[$(Get-Date -Format 'HH:mm:ss')] KILLED: $($x.ProcessName) (PID: $($x.Id))\" -ForegroundColor Red 
        }
    } catch {}
}
" 2>nul

:: Delay 1 detik
ping -n 2 127.0.0.1 >nul 2>&1
goto :LOOP
