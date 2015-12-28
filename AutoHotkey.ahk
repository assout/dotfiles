; Auto execute section is the region before any return/hotkey

;-----------------------------------------------------------
; IMEの状態をセット
;   SetSts          1:ON / 0:OFF
;   WinTitle="A"    対象Window
;   戻り値          0:成功 / 0以外:失敗
;-----------------------------------------------------------
IME_SET(SetSts, WinTitle="A")    {
  ControlGet,hwnd,HWND,,,%WinTitle%
  if  (WinActive(WinTitle)) {
    ptrSize := !A_PtrSize ? 4 : A_PtrSize
      VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
      NumPut(cbSize, stGTI,  0, "UInt")   ; DWORD   cbSize;
    hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
               ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
  }

  return DllCall("SendMessage"
      , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
      , UInt, 0x0283  ;Message : WM_IME_CONTROL
      ,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
      ,  Int, SetSts) ;lParam  : 0 or 1
}

; For Terminal/Vim
GroupAdd Terminal, ahk_class PuTTY
GroupAdd Terminal, ahk_class mintty ; cygwin
GroupAdd TerminalVim, ahk_group Terminal
GroupAdd TerminalVim, ahk_class Vim

; Include IME.hak
; http://www6.atwiki.jp/eamat/pages/17.html
; #Include  %A_ScriptDir%/IME.ahk

Return

; ESC + IME
#IfWInActive, ahk_group TerminalVim
Esc:: ; Just send Esc at converting.
  IME_SET(0)
  Send,{Esc}
  Return
^[:: ; Go to Normal mode (for vim) with IME off even at converting.
  IME_SET(0)
  Send,{Esc}
  Return
#IfWInActive

