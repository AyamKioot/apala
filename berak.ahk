#NoEnv
#SingleInstance Force
#Persistent
SetWorkingDir %A_ScriptDir%

; =========
; mapping asumsi umum
; =========
; DPad Left  = POV270
; X          = Joy3
; Back       = Joy7
; Start      = Joy8

bat := "N:\Apps\Cache\_Cache\DragonAge\elguard\Empty\fixsatu.bat"

SetTimer, CheckCombo, 30
return

CheckCombo:

; cek D-Pad kiri
GetKeyState, pov, JoyPOV

if (pov = 27000
    && GetKeyState("Joy3")
    && GetKeyState("Joy7")
    && GetKeyState("Joy8"))
{
    Run, *RunAs "%bat%"
    Sleep, 1200   ; biar ga kepanggil berkali2
}
return
