; Auto execute section is the region before any return/hotkey

#InstallKeybdHook ;キーボードフックを有効にする(スクリプトが常駐する)
#UseHook

; MD600ライクな設定
; vk1C 変換
; vk1D 無変換
; vkF2 カタカナひらがな

; F1~F12
vk1C & 1::F1
vk1C & 2::F2
vk1C & 3::F3
vk1C & 4::F4
vk1C & 5::F5
vk1C & 6::F6
vk1C & 7::F7
vk1C & 8::F8
vk1C & 9::F9
vk1C & 0::F10
vk1C & -::F11
vk1C & ^::F12

; 方向キー
vk1C & j::Left
vk1C & l::Right
vk1C & i::Up
vk1C & k::Down
vk1C & h::Home
vk1C & n::End
vk1C & u::PgUp
vk1C & o::PgDn


; その他
vk1C & vkBA::Del
vk1C & z::RButton
vkF3::Esc
vkF4::Esc

; "カタカナひらがな" -> "変換"
vkF2::vk1C
; "変換" -> 無効化
vk1C::Return

; For Terminal/Vim
GroupAdd Terminal, ahk_class mintty ; cygwin
GroupAdd TerminalVim, ahk_group Terminal
GroupAdd TerminalVim, ahk_class Vim
GroupAdd Chrome, ahk_class Chrome_WidgetWin_1

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
; vk1D:: ;無変換キー単独 = IMEオフ
;   IME_SET(0)
;   Return
; vk1C:: ;変換キー単独 = IMEオン
;   IME_SET(1)
;   Return

; ref. [クリップボードと選択範囲を見て文字列を一括入力するAutoHotkeyスクリプトの書き方 - 情報科学屋さんを目指す人のメモ（FC2ブログ版）](http://did2.blog64.fc2.com/blog-entry-422.html)
#IfWInActive, ahk_group Chrome
!e::
  cb_bk = %ClipboardAll%
  Clipboard =
  Send, ^c
  ClipWait, 0
  if ErrorLevel <> 0
  {
    Send, ^e
    Return
  }
  content = %Clipboard%
  StringReplace, content, content, `r`n, , All
  try
  {
    Run, %content%
  } finally
  {
    Clipboard = %cb_bk%
  }
  Return

; tmux+clipboard paste
; TODO だめ。c-s押した後ちょっとしてからvimのタグジャンプのつもりでc-]押したらペーストになっちゃう

; global is_pre_s = 0
; #IfWInActive, ahk_group Terminal
; ^s::
;   Send %A_ThisHotkey%
;   global is_pre_s = 1
;   Return
;  ]::
; ^]::
;   If (is_pre_s) {
;     Send ^g
;     Send ^+v
;   } else {
;     Send %A_ThisHotkey%
;   }
;   global is_pre_s = 0
;   Return
;

