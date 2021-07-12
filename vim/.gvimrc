scriptencoding utf-8

let g:did_install_default_menus = 1 " メニューバー非表示の場合この設定で起動が高速化するらしい.

set guifont=HackGenNerd:h10
set guifontwide=HackGenNerd:h10:cSHIFTJIS

set background=light " TODO: kaoriya版の場合vimrcに定義していても再定義が必要
set columns=120
set cmdheight=1 " TODO: kaoriya版の場合vimrcに定義していても再定義が必要
set guioptions-=a " 自動選択(autoselect)をオフにする
set guioptions+=b " 水平スクロールバーを表示.
set guioptions-=m " メニューバーを非表示.
set guioptions-=T " ツールバーを非表示.
set lines=40

" .swpファイルや~ファイル、un～ファイルなどが作成される場所を~\AppData\Local\Tempに変更
set directory=~\AppData\Local\Temp
set backupdir=~\AppData\Local\Temp
set undodir=~\AppData\Local\Temp

set iminsert=0 " 挿入モードでIMEオンになってしまうのを防ぐため
inoremap <ESC> <ESC>:set iminsert=0<CR>

" TODO: kaoriya版の場合vimrcに定義していても再定義が必要 TODO: プラグイン無効環境でエラー出る
" colorscheme hybrid
" colorscheme slate

