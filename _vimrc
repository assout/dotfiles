" # Index {{{
" * Begen.
" * Commands.
" * Options.
" * Lets.
" * Key-mappings.
" * Functions.
" * Plug-ins.
" * Auto-commands.
" }}}

" # Section; Begen {{{
" vi互換性.
set nocompatible
" }}}

" # Section; Commands {{{
" ファイルタイプ判別.
filetype on
" }}}

" # Section; Options {{{
" バックアップファイル作成有無.
set nobackup
" ヤンク、ペーストのクリップボード共有.
set clipboard+=unnamed,autoselect
" 内部encoding.
set encoding=utf-8
" ソフトタブ.
set noexpandtab
" ファイルエンコーディング.
set fileencodings=utf-8,ucs-bom,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,utf-8
" フォーマットオプション(-oでo,Oコマンドでの改行時のコメント継続をなくす).
set formatoptions-=o
" バッファ破棄設定.
set hidden
" 検索結果ハイライト.
set hlsearch
" 検索での大文字小文字区別.
set ignorecase
" インクリメンタルサーチ.
set incsearch
" 不可視文字表示.
set list
" 表示する不可視文字.
set listchars=tab:>.,trail:_,extends:\
" ステータスラインの表示設定.
set laststatus=2
" マクロなどを実行中は描画を中断.
set lazyredraw
" 行番号.
set number
" インクリメンタル/デクリメンタルを常に10進数として扱う.
set nrformats=
" カーソル行の上下に表示する行数.
set scrolloff=5
" フォーマット時などの幅.
set shiftwidth=4
" 常にタブラベルを表示する.
set showtabline=2
" カーソル行の水平に表示する行数.
set sidescrolloff=5
" 検索で大文字を含むときは大小を区別するか.
set smartcase
" スペルチェックで日本語は除外する.
set spelllang+=cjk
" tab幅.
set tabstop=4
" 自動改行をなくす.
set textwidth=0
" タイトルを表示するか.
set title
" コマンドラインモードの補完を使いやすくする.
set wildmenu
" 行折り返し.
set nowrap
" 検索循環.
set nowrapscan
" windows only.
if has('win32')
	" swapfile作成有無(vimfilerでのネットワークフォルダ閲覧時の速度低下防止(効果は不明)).
	set noswapfile
endif
" }}}

" # Section; Lets {{{
" netrwのデフォルト表示スタイル変更.
let g:netrw_liststyle=3
" shellのハイライトをbash基準にする.
let b:is_bash=1
" }}}

" # Section; Key-mappings {{{

nmap <Space> [space]
nnoremap [space]h zH
nnoremap [space]l zL

" ## normal & visual mode {{{
" TODO これは見直す?(なれちゃう前に).
noremap <C-j> 10j
noremap <C-k> 10k
noremap <C-h> gT
noremap <C-l> gt

nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
" }}}

" ## normal mode {{{
" 改行を挿入.
nnoremap <CR> i<CR><ESC>
" YをD,Cと一貫性のある挙動に変更.
nnoremap Y y$
" very magicをデフォルトにする.
nnoremap / /\v
nnoremap ? ?\v
" 検索結果ハイライトを解除.
nnoremap <silent> <ESC><ESC> :nohlsearch<CR>
" ### バッファ、ウィンドウ、タブ移動関連.
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
nnoremap <silent> [a :Next<CR>
nnoremap <silent> ]a :next<CR>
nnoremap <silent> [A :first<CR>
nnoremap <silent> ]A :last<CR>
nnoremap <silent> [q :cprevious
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [Q :cfirst<CR>
nnoremap <silent> ]Q :clast<CR>
" ### vimrcとgvimrcの編集、保存、読み込み.
nnoremap <Leader>v :tabe $MYVIMRC<CR>
nnoremap <Leader>g :tabe $MYGVIMRC<CR>
nnoremap <Leader>s :up $MYVIMRC<Bar>:up $MYGVIMRC<BAR>:source $MYVIMRC<Bar>:source $MYGVIMRC<CR>
" ### ウィンドウ移動を簡単に.
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
nnoremap <Leader>H <C-w>H
nnoremap <Leader>J <C-w>J
nnoremap <Leader>K <C-w>K
nnoremap <Leader>L <C-w>L

" }}}

" ## insert mode {{{
" カッコ等の入力補助 TODO カーソル移動が不自然になる
" inoremap  {} {}<Left>
" inoremap [] []<Left>
" inoremap () ()<Left>
" inoremap "" ""<Left>
" inoremap '' ''<Left>
" inoremap $$ $$<Left>
" inoremap <> <><Left> TODO vrapperが正しく動かなくなる
" inoremap `` ``<Left>
" }}}

" ## command mode {{{
" ### コマンドラインモードでのキーマッピングをEmacs風にする.
" 行頭へ移動.
cnoremap <C-a> <Home>
" 行末へ移動.
cnoremap <C-e> <End>
" 一文字戻る.
cnoremap <C-b> <Left>
" 一文字進む.
cnoremap <C-f> <Right>
" カーソルの下の文字を削除(Delete).
cnoremap <C-d> <Del>
" コマンドライン履歴を一つ進む.
cnoremap <C-n> <Down>
" コマンドライン履歴を一つ戻る.
cnoremap <C-p> <Up>
" 前の単語へ移動.
cnoremap <M-b> <S-Left>
" 次の単語へ移動.
cnoremap <M-f> <S-Right>
" }}}

" ## visual mode {{{
" ビジュアルモードでのヤンク後にカーソルを選択前の位置に戻さない.
vnoremap y y'>
" }}}

" }}}

" # Section; Functions {{{
" ## command実行結果をキャプチャ.
function! s:capture_cmd_output(cmd)
	if has("clipboard")
		redir @*>
	else
		redir @">
	endif
	execute a:cmd
	redir END
endfunction
command! -nargs=1 -complete=command Capture call <SID>capture_cmd_output(<q-args>)

function! s:has_plugin(plugin)
	return !empty(globpath(&runtimepath, 'plugin/' . a:plugin . '.vim'))
				\ || !empty(globpath(&runtimepath, 'autoload/' . a:plugin . '.vim'))
					\ || !empty(globpath(&runtimepath, 'colors/' . a:plugin . '.vim'))
endfunction
" }}}

" # Section; Plug-ins {{{
" ## Setup plug-in runtime path {{{
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
	NeoBundle 'thinca/vim-singleton'
	NeoBundle 'tomtom/tcomment_vim'
	NeoBundle 'vim-jp/vimdoc-ja'
	NeoBundle 'tpope/vim-surround'
	NeoBundle 'tpope/vim-repeat'
	NeoBundle 'schickling/vim-bufonly'
	"# colorscheme
	NeoBundle 'w0ng/vim-hybrid'
	NeoBundle 'tomasr/molokai'
	NeoBundle 'vim-scripts/rdark'
	NeoBundle 'vim-scripts/newspaper.vim'
	NeoBundle 'altercation/vim-colors-solarized'
	filetype plugin indent on
	"}}}

elseif isdirectory($HOME . '/vimfiles/plugins') " At office
	"# $HOME/vimfiles/plugins下のディレクトリをruntimepathへ追加する. {{{
	for s:path in split(glob($HOME.'/vimfiles/plugins/*'), '\n')
		if s:path !~# '\~$' && isdirectory(s:path)
			let &runtimepath = &runtimepath.','.s:path
		end
	endfor
	for s:path in split(glob($HOME.'/vimfiles/colors/*'), '\n')
		if s:path !~# '\~$' && isdirectory(s:path)
			let &runtimepath = &runtimepath.','.s:path
		end
	endfor
	unlet s:path
	"}}}
endif
" }}}

" # vimfiler.vim {{{
if s:has_plugin("vimfiler")
	" 非safe modeで起動.
	let g:vimfiler_safe_mode_by_default=0
	" key-mappings.
	nnoremap [vimfiler] <Nop>
	nmap [space]v [vimfiler]
	nnoremap <silent> [vimfiler]v :<C-u>VimFiler<CR>
	nnoremap <silent> [vimfiler]b :<C-u>VimFilerBufferDir<CR>
	nnoremap <silent> [vimfiler]c :<C-u>VimFilerCurrentDir<CR>
	nnoremap <silent> [vimfiler]d :<C-u>VimFilerDouble<CR>
	nnoremap <silent> [vimfiler]s :<C-u>VimFilerSplit<CR>
	nnoremap <silent> [vimfiler]t :<C-u>VimFilerTab<CR>
endif
" }}}

" # unite.vim {{{
if s:has_plugin("unite")
	" source=bookmark,のデフォルトアクションをvimfilerにする.
	call unite#custom_default_action('directory', 'vimfiler')
	" key-mappings.
	nnoremap [unite] <Nop>
	nmap [space]u [unite]
	" nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
	nnoremap <silent> [unite]b :<C-u>Unite bookmark<CR>
	nnoremap <silent> [unite]f :<C-u>Unite file_rec<CR>
	nnoremap <silent> [unite]d :<C-u>Unite directory_rec<CR>
	nnoremap <silent> [unite]r :<C-u>Unite resume -buffer-name=search<CR>

	" # neomru.vim {{{
	if s:has_plugin("neomru")
		" show mru help.
		let g:neomru#filename_format=''
		let g:neomru#do_validate=0
		let g:neomru#file_mru_limit=40
		let g:neomru#directory_mru_limit=40
		" key-mappings.
		nnoremap <silent> [unite]mf :<C-u>Unite neomru/file<CR>
		nnoremap <silent> [unite]md :<C-u>Unite neomru/directory<CR>
	endif
	" }}}
endif
" }}}

" # neocomplete.vim {{{
let g:neocomplete#enable_at_startup=1
let g:neocomplete#enable_ignore_case=1
let g:neocomplete#enable_smart_case=1
" }}}:

" # singleton.vim {{{
if s:has_plugin("singleton") && has("clientserver")
	call singleton#enable()
endif
" }}}

" # color-scheme {{{
if $USER == 'oji'
	colorscheme hybrid-light
elseif has('gui_running')
	colorscheme hybrid-light
else
	colorscheme default
endif
" }}}
" }}}

" # Section; Auto-commands {{{
augroup MyAutoGroup
	autocmd!
	"## DoubleByteSpace highlight.
	autocmd VimEnter,Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
	autocmd VimEnter,WinEnter * match DoubleByteSpace /　/
	"## markdown.
	autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
	autocmd FileType markdown hi! def link markdownItalic LineNr
	"## 改行時の自動コメント継続をやめる(o,Oコマンドでの改行時のみ).
	autocmd FileType * set textwidth=0
	autocmd FileType * set formatoptions-=o
augroup END
" }}}
