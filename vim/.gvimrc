scriptencoding utf-8
" メニューバー非表示の場合この設定で起動が高速化するらしい.
let g:did_install_default_menus=1
" フォント設定.
if has('unix')
  set guifont=Ricty\ Diminished\ 11
else
  set guifont=Consolas:h9
  set guifontwide=MS_Gothic:h9:cSHIFTJIS
endif
" 縦幅 デフォルトは24.
set lines=40
" 横幅 デフォルトは80.
set columns=120
" コマンドライン高さ TODO: kaoriya版の場合vimrcに定義していても再定義が必要
set cmdheight=1
" 自動選択(autoselect)をオフにする
set guioptions-=a
" 水平スクロールバーを表示.
set guioptions+=b
" メニューバーを非表示.
set guioptions-=m
" ツールバーを非表示.
set guioptions-=T
" 背景色 TODO: kaoriya版の場合vimrcに定義していても再定義が必要
set background=light
" カラースキーム TODO: kaoriya版の場合vimrcに定義していても再定義が必要 TODO: プラグイン無効環境でエラー出る
colorscheme hybrid

