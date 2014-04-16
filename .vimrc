"# set define {{{

" 内部encodingをutf-8
set encoding=utf-8
" ファイルエンコーディングを指定
set fileencodings=ucs-bom,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,utf-8
" 検索を循環しない
set nowrapscan
" 行折り返しなし
set nowrap
" 行番号あり
set number
" 不可視文字を表示する
set list
" 表示する不可視文字を設定する
set listchars=tab:>.,trail:_,extends:\
" 検索で大文字小文字を区別しない
set ignorecase
" 検索で大文字を含むときは大小を区別する
set smartcase
" 検索結果をハイライト
set hlsearch
" インクリメンタルサーチ
set incsearch
" ヤンク、ペーストをクリップボードに
set clipboard=unnamed,autoselect
" コマンドラインモードの補完を使いやすくする
set wildmenu
" マクロなどを実行中は描画を中断
set lazyredraw
" カーソル行の上下に表示する行数
set scrolloff=5
" カーソル行の水平に表示する行数
set sidescrolloff=5
" インクリメンタル/デクリメンタルを常に10進数として扱う
set nrformats=""
" 自動改行をなくす
set textwidth=0
" o,Oコマンドでの改行時のコメント継続をなくす
set formatoptions-=o

"}}}

"# let define {{{

" netrwのデフォルト表示スタイル変更
let g:netrw_liststyle=3

"}}}

"# map define {{{

" YをD,Cと一貫性のある挙動に変更
nnoremap Y y$
" very magicをデフォルトにする
nnoremap / /\v
" 検索結果ハイライトを解除
nnoremap <silent> <ESC><ESC> :nohlsearch<CR>

"ノーマルモードで改行を挿入
noremap <CR> i<CR><ESC>

"## スクロール
noremap <C-j> 10<C-e>
noremap <C-k> 10<C-y>
noremap <C-h> 10zh
noremap <C-l> 10zl

"## バッファ、ウィンドウ、タブ移動関連
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>

nnoremap <silent> [w <C-W>W
nnoremap <silent> ]w <C-W>w
nnoremap <silent> [W <C-W><C-T>
nnoremap <silent> ]W <C-W><C-B>

nnoremap <silent> [t gT
nnoremap <silent> ]t gt
nnoremap <silent> [T :tabfirst<CR>
nnoremap <silent> ]T :tablast<CR>

"## vimrcとgvimrcの編集、保存、読み込み
nnoremap <Leader>v :e $MYVIMRC<CR>
nnoremap <Leader>g :e $MYGVIMRC<CR>
nnoremap <Leader>s :up $MYVIMRC<Bar>:up $MYGVIMRC<BAR>:source $MYVIMRC<Bar>:source $MYGVIMRC<CR>

" カッコ等の入力補助
"inoremap {} {}<LEFT>
"inoremap [] []<LEFT>
"inoremap () ()<LEFT>
"inoremap "" ""<left>
"inoremap '' ''<left>
"inoremap $$ $$<left>
"" inoremap <> <><left>
"inoremap `` ``<left>

"コマンドラインでコマンド履歴をやりやすく 
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

"# コマンドラインモードでのキーマッピングをEmacs風にする(pluginのemacscommandline.vimが使えない環境のみ)
cnoremap <C-a> <Home>
" 行末へ移動
cnoremap <C-e> <End>
" 一文字戻る
cnoremap <C-b> <Left>
" 一文字進む
cnoremap <C-f> <Right>
" カーソルの下の文字を削除(Delete)
cnoremap <C-d> <Del>
" コマンドライン履歴を一つ進む
cnoremap <C-n> <Down>
" コマンドライン履歴を一つ戻る
cnoremap <C-p> <Up>
" 前の単語へ移動
cnoremap <M-b> <S-Left>
" 次の単語へ移動
cnoremap <M-f> <S-Right>

"ウィンドウ移動を簡単に
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
nnoremap <Leader>H <C-w>H
nnoremap <Leader>J <C-w>J
nnoremap <Leader>K <C-w>K
nnoremap <Leader>L <C-w>L

"# autocom define
augroup MyAutoGroup
	autocmd!
	
	"## DoubleByteSpace highlight
	autocmd VimEnter,Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
	autocmd VimEnter,WinEnter * match DoubleByteSpace /　/

	"## markdown
	autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
	autocmd FileType markdown hi! def link markdownItalic LineNr
	
	"## 改行時の自動コメント継続をやめる(o,Oコマンドでの改行時のみ)
	autocmd FileType * set textwidth=0
	autocmd FileType * set formatoptions-=o
augroup END

"# function define {{{

" command実行結果をclipboardにキャプチャ
func! s:func_copy_cmd_output(cmd)
	redir @">
	execute a:cmd
	redir END
endfunc
command! -nargs=1 -complete=command Capture call <SID>func_copy_cmd_output(<q-args>)
"}}}

"# plugin define {{{

if isdirectory($HOME . '/.vim/bundle/neobundle.vim') " At home
	"# neobundle {{{
	filetype plugin indent off
	if has('vim_starting')
	  set runtimepath+=~/.vim/bundle/neobundle.vim/
	  call neobundle#rc(expand('~/.vim/bundle/'))
	endif

	NeoBundle 'Shougo/neobundle.vim'
	NeoBundle 'Shougo/unite.vim'
	NeoBundle 'Shougo/neomru.vim'
	NeoBundle 'Shougo/vimfiler.vim'
	if has('lua')
		NeoBundle 'Shougo/neocomplete.vim'
	end
	NeoBundle 'kannokanno/previm'
	NeoBundle 'houtsnip/vim-emacscommandline'
	NeoBundle 'thinca/vim-singleton'
	"# colorscheme
	NeoBundle 'w0ng/vim-hybrid'
	NeoBundle 'tomasr/molokai'
	NeoBundle 'vim-scripts/rdark'
	NeoBundle 'vim-jp/vimdoc-ja'

	filetype plugin indent on
	"}}}

elseif isdirectory($HOME . '/vimfiles/plugins') " At office
	"# $HOME/vimfiles/plugins下のディレクトリをruntimepathへ追加する。{{{
	for s:path in split(glob($HOME.'/vimfiles/plugins/*'), '\n')
		if s:path !~# '\~$' && isdirectory(s:path)
			let &runtimepath = &runtimepath.','.s:path
		end
	endfor
	unlet s:path
endif

"# vimfiler.vim {{{

" セーフモードの設定(オフにする)
let g:vimfiler_safe_mode_by_default=0

"}}}

"# unite.vim {{{

" unite source=bookmarkのデフォルトアクションをvimfilerにする
call unite#custom_default_action('source/bookmark/directory' , 'vimfiler')

"}}}

"# neocomplete.vim {{{
let g:neocomplete#enable_at_startup=1
let g:neocomplete#enable_ignore_case=1
let g:neocomplete#enable_smart_case=1
"}}}

" singgleton.vim
call singleton#enable()

"}}}

