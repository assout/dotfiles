; Auto execute section is the region before any return/hotkey

#InstallKeybdHook ;キーボードフックを有効にする(スクリプトが常駐する)
#UseHook

F1::
  Suspend, Toggle
Return

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
vk1C & z::+F10
vk1C & vkF3::Esc
vk1C & vkF4::Esc

; "カタカナひらがな" -> "変換"
vkF2::vk1C
; "変換" -> 無効化
vk1C::Return

; For Terminal/Vim
GroupAdd Chrome, ahk_class Chrome_WidgetWin_1

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

