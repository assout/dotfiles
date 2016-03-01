; Auto execute section is the region before any return/hotkey

#InstallKeybdHook ;キーボードフックを有効にする(スクリプトが常駐する)
#UseHook

; For Terminal/Vim
GroupAdd Terminal, ahk_class mintty ; cygwin
GroupAdd TerminalVim, ahk_group Terminal
GroupAdd TerminalVim, ahk_class Vim

Return

;-----------------------------------------------------------
; IMEの状態の取得
;    対象： AHK v1.0.34以降
;   WinTitle : 対象Window (省略時:アクティブウィンドウ)
;   戻り値  1:ON 0:OFF
;-----------------------------------------------------------
IME_GET(WinTitle="")
{
    ifEqual WinTitle,,  SetEnv,WinTitle,A
    WinGet,hWnd,ID,%WinTitle%
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hWnd, Uint)

    ;Message : WM_IME_CONTROL  wParam:IMC_GETOPENSTATUS
    DetectSave := A_DetectHiddenWindows
    DetectHiddenWindows,ON
    SendMessage 0x283, 0x005,0,,ahk_id %DefaultIMEWnd%
    DetectHiddenWindows,%DetectSave%
    Return ErrorLevel
}

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

;---
; with 無変換キー、変換キー
;---
vk1Dsc07B:: ;無変換キー単独 = IMEオフ
  IME_SET(0)
  Return
vk1Csc079:: ;変換キー単独 = IMEオン
  IME_SET(1)
  Return

;---
; CapsLockキーにCtrlキーの仕事をさせる
; TODO: Windows7だと無理らしい(Windows8なら大丈夫らしい) Refs: http://syobochim.hatenablog.com/entry/2013/10/22/232444
;---
;Capslock::Ctrl
;sc03a::Ctrl

;---
; other
;---
^j:: ; Disable if IME ON
  getIMEMode := IME_GET()
  if (%getIMEMode% = 0) {
    Send,^j
  }
  Return
