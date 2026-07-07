@echo off
title VNC KILLER 24/7 - VISIBLE MODE
mode con cols=70 lines=15
color 0a

echo ======================================
echo VNC KILLER 24/7 - JALAN NONSTOP
echo ======================================

:LOOP
start /wait powershell -NoExit -Command "
$procs = @('vncserver','winvnc','winvnc4','tightvncserver','ultravnc','vncviewer','tvnserver','tvncviewer');
foreach($p in $procs){ 
    try { 
        $proc = Get-Process -Name $p -ErrorAction Stop;
        foreach($x in $proc){ 
            Stop-Process -Id $x.Id -Force;
            Write-Host ('[ ' + (Get-Date -Format 'HH:mm:ss') + ' ] KILLED: ' + $x.ProcessName + ' (PID: ' + $x.Id + ')') -ForegroundColor Red 
        }
    } catch {}
}
Write-Host '[ ' + (Get-Date -Format 'HH:mm:ss') + ' ] Checking...' -ForegroundColor Gray
Start-Sleep -Seconds 1
"
goto :LOOP
