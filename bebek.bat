@echo off
setlocal enabledelayedexpansion
for /f "tokens=2 delims==" %%a in ('wmic computersystem get name /value ^| find "="') do set "PCNAME=%%a"
for /f "tokens=*" %%a in ('wmic path win32_videocontroller get caption ^| findstr /i /v "Caption" ^| findstr /r /v "^$"') do set "GPU=%%a"
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do set "IP=%%a"
set "IP=!IP: =!"
for /f "tokens=2 delims=:" %%a in ('netstat -an ^| findstr "LISTENING" ^| findstr /r "0.0.0.0:[0-9]"') do (for /f "tokens=*" %%b in ("%%a") do (if not defined PORT set "PORT=%%b"))
if not defined PORT set "PORT=NO ONE PORT IS ACTIVE"
echo Dim WshShell, Msg, Style, Title> "%temp%\popup.vbs"
echo WshShell = CreateObject("WScript.Shell")>> "%temp%\popup.vbs"
echo Msg = "NAMA DESKTOP: %PCNAME%" ^& vbCrLf ^& vbCrLf ^& "GPU/VGA: %GPU%" ^& vbCrLf ^& vbCrLf ^& "IP ADDRESS: %IP%" ^& vbCrLf ^& vbCrLf ^& "PORT: %PORT%">> "%temp%\popup.vbs"
echo Style = 0 + 48 + 4096>> "%temp%\popup.vbs"
echo Title = "SYSTEM INFORMATION">> "%temp%\popup.vbs"
echo WshShell.Popup Msg, 0, Title, Style>> "%temp%\popup.vbs"
wscript "%temp%\popup.vbs"
del "%temp%\popup.vbs" 2>nul
exit
