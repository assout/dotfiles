scriptencoding utf-8

let g:did_install_default_menus = 1 " メニューバー非表示の場合この設定で起動が高速化するらしい.

" if has('unix')
"   " set guifont=Ricty\ Diminished\ 11
"   " set guifont=Myrica\ M\ 11
" else
"   set guifont=Consolas:h9
"   set guifontwide=MS_Gothic:h9:cSHIFTJIS
" endif
set lines=40
set clipboard&
set clipboard^=unnamedplus,unnamed
set columns=120
set cmdheight=1 " TODO: kaoriya版の場合vimrcに定義していても再定義が必要
set guioptions-=a " 自動選択(autoselect)をオフにする
set guioptions+=b " 水平スクロールバーを表示.
set guioptions-=m " メニューバーを非表示.
set guioptions-=T " ツールバーを非表示.
set background=light " TODO: kaoriya版の場合vimrcに定義していても再定義が必要

" TODO: kaoriya版の場合vimrcに定義していても再定義が必要 TODO: プラグイン無効環境でエラー出る
" colorscheme hybrid

