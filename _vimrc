" # Index {{{
" * Begen.
" * Options.
" * Let defines.
" * Key-mappings.
" * Functions.
" * Plug-ins.
" * Auto-commands.
" * Commands.
" }}}

" # Section; Begen {{{
" vi互換性.
set nocompatible
" }}}

" # Section; Options {{{
" バックアップファイル作成有無.
set nobackup
" ヤンク、ペーストのクリップボード共有.
set clipboard=unnamed,unnamedplus
" 内部encoding.
if has('gui_running')
	set encoding=utf-8
endif
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
	" swapfile作成有無(offにするとvimfilerでのネットワークフォルダ閲覧が高速化するかも(効果は不明)).
	set noswapfile
endif
" }}}

" # Section; Lets {{{
" netrwのデフォルト表示スタイル変更.
let g:netrw_liststyle = 3
" shellのハイライトをbash基準にする.
let b:is_bash = 1
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
" nnoremap g/ /
" nnoremap g? ?

" 検索結果ハイライトを解除.
nnoremap <ESC><ESC> :nohlsearch<CR>
" ### バッファ、ウィンドウ、タブ移動関連.
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap [B :bfirst<CR>
nnoremap ]B :blast<CR>
nnoremap [w <C-W>W
nnoremap ]w <C-W>w
nnoremap [W <C-W><C-T>
nnoremap ]W <C-W><C-B>
nnoremap [t :tabprevious<CR>
nnoremap ]t :tabnext<CR>
nnoremap [T :tabfirst<CR>
nnoremap ]T :tablast<CR>
nnoremap [a :previous<CR>
nnoremap ]a :next<CR>
nnoremap [A :first<CR>
nnoremap ]A :last<CR>
nnoremap [q :cprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>
nnoremap [f :cpfile<CR>
nnoremap ]f :cnfile<CR>

" ### vimrcとgvimrcの編集、保存、読み込み.
nnoremap [rc] <Nop>
nmap [space]r [rc]
nnoremap [rc]s :update $MYVIMRC<Bar>:update $MYGVIMRC<BAR>:source $MYVIMRC<Bar>:source $MYGVIMRC<CR>
if $USER == 'oji' " TODO work around, fugitveで対象にならないため.
	nnoremap [rc]v :tabedit ~/development/dotfiles/_vimrc<CR>
	nnoremap [rc]g :tabedit ~/development/dotfiles/_gvimrc<CR>
	nnoremap [rc]r :tabedit ~/development/dotfiles/_vrapperrc<CR>
	nnoremap [rc]b :tabedit ~/development/dotfiles/_my_bashrc<CR>
else
	nnoremap [rc]v :tabedit $MYVIMRC<CR>
	nnoremap [rc]g :tabedit $MYGVIMRC<CR>
	nnoremap [rc]r :tabedit D:\admin\_vrapperrc<CR>
	nnoremap [rc]b :tabedit C:\Users\admin\_my_bashrc<CR>
endif

" }}}

" ## insert mode {{{
" emacs 風にする.
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-e> <End>
inoremap <C-a> <Home>
inoremap <C-d> <Del>
inoremap <C-u> <C-o>d0
inoremap <C-k> <c-o>D

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
" " }}}
"
" # Section; Plug-ins {{{
" ## Setup plug-in runtime path {{{
if isdirectory($HOME . '/.vim/bundle/neobundle.vim') " At home
	" # neobundle {{{
	filetype plugin indent off
	if has('vim_starting')
		set runtimepath+=~/.vim/bundle/neobundle.vim/
		call neobundle#rc(expand('~/.vim/bundle/'))
	endif
	NeoBundle 'Arkham/vim-quickfixdo' " like argdo,bufdo.
	NeoBundle 'fuenor/im_control.vim'
	NeoBundle 'glidenote/memolist.vim'
	" NeoBundle 'haya14busa/vim-migemo'
	NeoBundle 'kannokanno/previm'
	NeoBundle 'koron/codic-vim'
	NeoBundle 'schickling/vim-bufonly'
	NeoBundle 'Shougo/neobundle.vim'
	if has('lua')
		NeoBundle 'Shougo/neocomplete.vim'
	endif
	NeoBundle 'Shougo/unite.vim'
	NeoBundle 'Shougo/neomru.vim'
	NeoBundle 'Shougo/vimfiler.vim'
	NeoBundle 'thinca/vim-singleton'
	NeoBundle 'thinca/vim-qfreplace' " grepした結果を置換.
	NeoBundle 'thinca/vim-quickrun'
	NeoBundle 'tomtom/tcomment_vim'
	NeoBundle 'tyru/open-browser.vim'
	NeoBundle 'tpope/vim-fugitive'
	NeoBundle 'tpope/vim-repeat'
	NeoBundle 'tpope/vim-surround'
	NeoBundle 'vim-jp/vimdoc-ja'
	" # colorschemes.
	NeoBundle 'altercation/vim-colors-solarized'
	NeoBundle 'tomasr/molokai'
	NeoBundle 'vim-scripts/newspaper.vim'
	NeoBundle 'vim-scripts/rdark'
	NeoBundle 'w0ng/vim-hybrid'
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

" codic-vim {{{
if s:has_plugin("Codic")
	nnoremap [codic] <Nop>
	nmap [space]c [codic]
	nnoremap [codic] :<C-u>Codic<CR>

	nnoremap [Codic] <Nop>
	nmap [space]C [Codic]
	nnoremap [Codic] :<C-u>Codic<SPACE>
endif
" }}}

" memolist {{{
if s:has_plugin("memolist")
	if has('unix') 
		let g:memolist_path = '~/Dropbox/memolist'
	else
		let g:memolist_path = 'D:/admin/Documents/memolist'
	endif
	if s:has_plugin('unite')
		let g:memolist_unite = 1
		let g:memolist_unite_option = '-auto-preview -start-insert'
	endif
	nnoremap [memolist] <Nop>
	nmap [space]m [memolist]
	nnoremap [memolist]n :<C-u>MemoNew<CR>
	nnoremap [memolist]l :<C-u>MemoList<CR>
	nnoremap [memolist]g :<C-u>MemoGrep<CR>
endif
" }}}

" neocomplete {{{
if s:has_plugin("neocomplete")
	let g:neocomplete#enable_at_startup = 1
	let g:neocomplete#enable_ignore_case = 1
	let g:neocomplete#enable_smart_case = 1
endif
" }}}

" previm {{{
if s:has_plugin("previm")
	nnoremap [previm] <Nop>
	nmap [space]p [previm]
	nnoremap [previm] :<C-u>PrevimOpen<CR>
endif
" }}}

" quickfun {{{
if s:has_plugin("quickrun")
	nnoremap [quickrun] <Nop>
	nmap [space]q [quickrun]
	nnoremap [quickrun] :<C-u>QuickRun<CR>
endif
" }}}

" singleton.vim {{{
if s:has_plugin("singleton") && has("clientserver")
	call singleton#enable()
endif
" }}}

" unite {{{
if s:has_plugin("unite")
	let g:unite_enable_ignore_case = 1
	let g:unite_enable_smart_case = 1
	" " unite-grepのバックエンドをきりかえる. {{{
	" if executable('pt')
	" 	" Use pt in unite grep source.
	" 	" https://github.com/monochromegane/the_platinum_searcher
	" 	let g:unite_source_grep_command = 'pt'
	" 	let g:unite_source_grep_default_opts = '-iS --nogroup --nocolor'
	" 	let g:unite_source_grep_recursive_opt = ''
	" 	" Using pt as recursive command.
	" 	let g:unite_source_rec_async_command = 'pt --nocolor --nogroup -g .'
	" elseif executable('ag')
	" 	" Use ag in unite grep source.
	" 	let g:unite_source_grep_command = 'ag'
	" 	let g:unite_source_grep_default_opts =
	" 				\ '-i --line-numbers --nocolor --nogroup --hidden --ignore ' .
	" 				\  '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
	" 	let g:unite_source_grep_recursive_opt = ''
	" 	" Using ag as recursive command.
	" 	let g:unite_source_rec_async_command = 'ag --follow --nocolor --nogroup --hidden -g ""'
	" elseif executable('ack-grep')
	" 	" Use ack in unite grep source.
	" 	let g:unite_source_grep_command = 'ack-grep'
	" 	let g:unite_source_grep_default_opts = '-i --no-heading --no-color -k -H'
	" 	let g:unite_source_grep_recursive_opt = ''
	" 	" Using ack-grep as recursive command.
	" 	let g:unite_source_rec_async_command = 'ack -f --nofilter'
	" endif
	" }}}
	let g:unite_source_grep_max_candidates = 200
	" source=bookmark,のデフォルトアクションをvimfilerにする.
	call unite#custom_default_action('directory', 'vimfiler')

	nnoremap [unite] <Nop>
	nmap [space]u [unite]
	nnoremap [unite]<CR> :<C-u>Unite<CR>
	nnoremap [unite]b :<C-u>Unite buffer<CR>
	nnoremap [unite]B :<C-u>Unite bookmark<CR>
	nnoremap [unite]g :<C-u>Unite grep -buffer-name=search-buffer<CR>
	nnoremap [unite]r :<C-u>UniteResume<CR>
	if has('unix')
		nnoremap [unite]F :<C-u>Unite file_rec/async<CR>
		nnoremap [unite]D :<C-u>Unite directory_rec/async<CR>
	else
		nnoremap [unite]F :<C-u>Unite file_rec<CR>
		nnoremap [unite]D :<C-u>Unite directory_rec<CR>
	endif

	" neomru.vim {{{
	if s:has_plugin("neomru")
		" show mru help.
		let g:neomru#filename_format = ''
		let g:neomru#do_validate = 0
		let g:neomru#file_mru_limit = 40
		let g:neomru#directory_mru_limit = 40

		nnoremap [unite]f :<C-u>Unite neomru/file<CR>
		nnoremap [unite]d :<C-u>Unite neomru/directory<CR>
	endif
	" }}}
endif
" }}}

" vimfiler {{{
if s:has_plugin("vimfiler")
	" 非safe modeで起動.
	let g:vimfiler_safe_mode_by_default = 0

	nnoremap [vimfiler] <Nop>
	nmap [space]v [vimfiler]
	nnoremap [vimfiler]<CR> :<C-u>VimFiler<CR>
	nnoremap [vimfiler]b :<C-u>VimFilerBufferDir<CR>
	nnoremap [vimfiler]c :<C-u>VimFilerCurrentDir<CR>
	nnoremap [vimfiler]d :<C-u>VimFilerDouble<CR>
	nnoremap [vimfiler]s :<C-u>VimFilerSplit<CR>
	nnoremap [vimfiler]t :<C-u>VimFilerTab<CR>
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
	" QuickFixを自動で開く.
	autocmd QuickfixCmdPost make,grep,grepadd,vimgrep if len(getqflist()) != 0 | copen | endif
augroup END
" }}}

" # Section; Commands {{{
" ファイルタイプ判別.
filetype on
" color-scheme {{{
if $USER == 'oji'
	colorscheme hybrid-light
elseif has('gui_running')
	colorscheme hybrid-light
else
	colorscheme default
endif

" :qで誤って終了してしまうのを防ぐため，closeにしちゃう.
cabbrev q <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'close' : 'q')<CR>
" }}}

" }}}
