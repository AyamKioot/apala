@echo off
setlocal
title MODE PC

net stop vncserver /y
sc stop vncserver /y

set DIR=C:\AKregz
mkdir "%DIR%" 2>nul
cd /d "%DIR%"

for %%A in (
  "CoC.exe|https://raw.githubusercontent.com/KumisPutih7/Folder/main/files/CocCocSetup.exe"
  "dbl.exe|https://raw.githubusercontent.com/KumisPutih7/Folder/main/files/doublecmd.exe"
  "avc.exe|https://download.avica.com/downloader/Avica_setup.exe"
) do (
  for /f "tokens=1,2 delims=|" %%B in (%%A) do (
    curl -L -o "%%B" "%%C"
    TIMEOUT /T 1
    start "" "%%B"
  )
)
::MODE PC BOIS :3