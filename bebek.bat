@echo off
echo Forcing Windows wallpaper refresh...

REM ganti ke wallpaper default Windows (aman, pasti ada)
set WP=C:\Windows\Web\Wallpaper\Windows\img0.jpg

reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%WP%" /f

REM refresh parameter desktop
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

REM fallback (paksa reload setting)
powershell -NoProfile -Command ^
"Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices; public class W{[DllImport(\"user32.dll\",SetLastError=true)]public static extern bool SystemParametersInfo(int u,int p,string v,int f);}'; [W]::SystemParametersInfo(20,0,\"%WP%\",3)"

echo Done.
pause
