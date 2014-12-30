" Index {{{1
" * Begin.
" * Options.
" * Let defines.
" * Functions.
" * Key-mappings.
" * Plug-ins.
" * Auto-commands.
" * Commands.
" }}}1

" Section; Begin {{{1
" vi互換性.
set nocompatible
" load local vimrc.
if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
" }}}1

" Section; Options {{{1
" バックアップファイル作成有無.
set nobackup
" ヤンク、ペーストのクリップボード共有.
set clipboard=unnamed,unnamedplus
" 差分モードの表示.
set diffopt+=vertical
" 内部encoding.
if has('gui_running')
	set encoding=utf-8
endif
" ソフトタブ.
set noexpandtab
" ファイルエンコーディング.
set fileencodings=utf-8,ucs-bom,iso-2020-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,latin,latin1,utf-8
" 折りたたみレベル.
set foldlevelstart=99
" 折りたたみ方法
set foldmethod=marker
" フォーマットオプション(-oでo,Oコマンドでの改行時のコメント継続をなくす).
set formatoptions-=o
if has('win32') && executable('grep')
	" grep.
	set grepprg=grep\ -nH
endif
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
" スペルチェック用辞書ファイル.
if s:isOfficeWin()
	set spellfile=D:/admin/Documents/spell/en.utf-8.add
elseif s:isHomeUnix()
	set spellfile=~/Dropbox/spell/en.utf-8.add
endif
" スペルチェックで日本語は除外する.
set spelllang+=cjk
" tab幅.
set tabstop=4
" 自動改行をなくす.
set textwidth=0
" タイトルを表示するか.
set title
" Undoファイルの有効無効.
if has('win32')
	set noundofile
endif
" コマンドラインモードの補完を使いやすくする.
set wildmenu
" 行折り返し.
set nowrap
" 検索循環.
set nowrapscan
if has('win32')
	" swapfile作成有無(offにするとvimfilerでのネットワークフォルダ閲覧が高速化するかも(効果は不明)).
	set noswapfile
endif
" }}}1

" Section; Let defines {{{1
" netrwのデフォルト表示スタイル変更.
let g:netrw_liststyle = 3
" shellのハイライトをbash基準にする.
let b:is_bash = 1
" for dicwin.vim.
let g:mapleader = '[space]d'
" let g:dicwin_mapleader = '[space]d'
" }}}1

" Section; Functions {{{1
" command実行結果をキャプチャ.
function! s:capture_cmd_output(cmd)
	if has("clipboard")
		redir @+>
	else
		redir @">
	endif
	execute a:cmd
	redir END
endfunction
command! -nargs=1 -complete=command Capture call <SID>capture_cmd_output(<q-args>)

" pluginが存在するか調べる.
function! s:has_plugin(plugin)
	return !empty(matchstr(&runtimepath, a:plugin))
endfunction

" quickfix: 編集許可と折り返し表示無効.
function! s:openModifiableQF()
	cw
	set modifiable
	set nowrap
endfunction

function! s:insertPrefix(str) range
	execute a:firstline . "," . a:lastline . "s/^/" . a:str
endfunction

function! s:insertSuffix(str) range
	execute a:firstline . "," . a:lastline . "s/$/" . a:str
endfunction

function! s:isHomeUnix()
	return $USER == 'oji' && has('unix')
endfunction

function! s:isHomeWin()
	return $USER == 'oji' && has('win32')
endfunction

function! s:isOfficeUnix()
	return $USER != 'oji' && has('unix')
endfunction

function! s:isOfficeWin()
	return $USER != 'oji' && has('win32')
endfunction

" }}}1


" Section; Key-mappings {{{1
" Prefix key mappings {{{2

" vimfilerとかと競合防ぐため.
map <Space> [space]

" [edit] mappings
nmap [space]e [edit]
nnoremap [edit]v :execute "tabedit " . resolve(expand($MYVIMRC))<CR>
nnoremap [edit]g :execute "tabedit " . resolve(expand($MYGVIMRC))<CR>
nnoremap [edit]r :tabedit ~/development/dotfiles/_vrapperrc<CR>
nnoremap [edit]b :tabedit ~/development/dotfiles/_my_bashrc<CR>
if s:isOfficeWin()
	nnoremap [edit]r :tabedit D:\admin\_vrapperrc<CR>
	nnoremap [edit]b :tabedit C:\Users\admin\_my_bashrc<CR>
	nnoremap [edit]i :tabedit D:\admin\Documents\ipmsg.log<CR>
endif

" [insert] mappings.
map [space]i [insert]
noremap [insert]p :call <SID>insertPrefix(input("input prefix:"))<CR>
noremap [insert]t :call <SID>insertPrefix("TODO ")<CR>
noremap [insert]1 :call <SID>insertPrefix("# ")<CR>
noremap [insert]2 :call <SID>insertPrefix("## ")<CR>
noremap [insert]3 :call <SID>insertPrefix("### ")<CR>
noremap [insert]* :call <SID>insertPrefix("* ")<CR>
noremap [insert]> :call <SID>insertPrefix("> ")<CR>
noremap [insert]s :call <SID>insertSuffix(input("input suffix:"))<CR>
noremap [insert]n :call <SID>insertSuffix(" " . strftime("[%Y-%m-%d %H:%M:%S]"))<CR>
noremap [insert]l :call <SID>insertSuffix("  ")<CR>
noremap [insert]at :call <SID>insertSuffix("[asin::title]")<CR>0f:
noremap [insert]ad :call <SID>insertSuffix("[asin::detail]")<CR>0f:
noremap [insert]ai :call <SID>insertSuffix("[asin::image]")<CR>0f:

" [json] mappings
map [space]j [json]
nnoremap [json] :%!python -m json.tool<CR>
xnoremap [space] :!python -m json.tool<CR>

" vimrc,gvimrcのreload.
nnoremap [space]r :update $MYVIMRC<Bar>:update $MYGVIMRC<Bar>:source $MYVIMRC<Bar>:source $MYGVIMRC<CR>
" }}}2

noremap <C-j> 10j
noremap <C-k> 10k
noremap <C-h> gT
noremap <C-l> gt

" 横スクロール.
nnoremap [space]h zH
nnoremap [space]l zL
" 表示位置でカーソル移動.
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
" 改行を挿入.
nnoremap <CR> i<CR><Esc>
" YをD,Cと一貫性のある挙動に変更.
nnoremap Y y$
" very magicをデフォルトにする.
nnoremap / /\v
nnoremap ? ?\v
" 検索結果ハイライトを解除.
nnoremap <Esc><Esc> :nohlsearch<CR>
" バッファ、ウィンドウ、タブ移動関連.
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

" インサートモードでのキーマッピングをEmacs風にする.
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-e> <End>
inoremap <C-a> <Home>
inoremap <C-d> <Del>
inoremap <C-u> <C-k>d0
inoremap <C-k> <C-o>D

" コマンドラインモードでのキーマッピングをEmacs風にする.
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-d> <Del>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>

" ビジュアルモードでのヤンク後にカーソルを選択前の位置に戻さない.
vnoremap y y'>
" }}}1

" Section; Plug-ins {{{1
" Setup plug-in runtime path {{{
if isdirectory($HOME . '/.vim/bundle/neobundle.vim') " At home
	filetype plugin indent off
	if has('vim_starting')
		set runtimepath+=~/.vim/bundle/neobundle.vim/
		call neobundle#begin(expand('~/.vim/bundle'))
	endif
	NeoBundle 'Arkham/vim-quickfixdo' " like argdo,bufdo.
	NeoBundle 'fuenor/im_control.vim'
	NeoBundle 'glidenote/memolist.vim'
	NeoBundle 'h1mesuke/vim-alignta'
	NeoBundle 'h1mesuke/unite-outline'
	" NeoBundle 'haya14busa/vim-migemo'
	NeoBundle 'kana/vim-textobj-user'
	NeoBundle 'kana/vim-textobj-entire'
	NeoBundle 'kannokanno/previm'
	NeoBundle 'kannokanno/unite-todo'
	NeoBundle 'koron/codic-vim'
	NeoBundle 'koron/dicwin-vim'
	NeoBundle 'mattn/excitetranslate-vim'
	NeoBundle 'mattn/webapi-vim'
	NeoBundle 'moznion/hateblo.vim'
	NeoBundle 'schickling/vim-bufonly'
	NeoBundle 'Shougo/neobundle.vim'
	if has('lua')
		NeoBundle 'Shougo/neocomplete'
		" NeoBundle 'Shougo/neosnippet'
		" NeoBundle 'Shougo/neosnippet-snippets'
	endif
	NeoBundle 'Shougo/unite.vim'
	NeoBundle 'Shougo/neomru.vim'
	NeoBundle 'Shougo/vimfiler.vim'
	NeoBundle 'Shougo/vimproc', {
				\ 'build' : {
				\ 'windows' : 'make -f make_mingw32.mak',
				\ 'cygwin' : 'make -f make_cygwin.mak',
				\ 'mac' : 'make -f make_mac.mak',
				\ 'unix' : 'make -f make_unix.mak',
				\ },
				\ }
	NeoBundle 'thinca/vim-ref'
	NeoBundle 'thinca/vim-singleton'
	NeoBundle 'thinca/vim-qfreplace' " grepした結果を置換.
	NeoBundle 'thinca/vim-quickrun'
	NeoBundle 'tomtom/tcomment_vim'
	NeoBundle 'tyru/open-browser.vim'
	NeoBundle 'tpope/vim-fugitive'
	NeoBundle 'tpope/vim-repeat'
	" NeoBundle 'tpope/vim-surround'
	NeoBundle 'vim-jp/vimdoc-ja'

	" color schemes.
	" NeoBundle 'altercation/vim-colors-solarized'
	" NeoBundle 'tomasr/molokai'
	" NeoBundle 'vim-scripts/newspaper.vim'
	" NeoBundle 'vim-scripts/rdark'
	NeoBundle 'w0ng/vim-hybrid'

	call neobundle#end()
	filetype plugin indent on

elseif isdirectory($HOME . '/vimfiles/plugins') " At office
	let &runtimepath = &runtimepath.',/vimfiles/plugins'
	for l:path in split(glob($HOME.'/vimfiles/plugins/*'), '\n')
		if l:path !~# '\~$' && isdirectory(l:path)
			let &runtimepath = &runtimepath.','.l:path
		end
	endfor
endif
" }}}

" alignta {{{
if s:has_plugin("alignta")
	xnoremap [space]a :Alignta<Space>
endif
" }}}

" codic {{{
if s:has_plugin("codic")
	nnoremap [space]c :<C-u>Codic<CR>
	nnoremap [space]C :<C-u>Codic<Space>
endif
" }}}

" excitetranslate {{{
if s:has_plugin("excitetranslate")
	nnoremap [space]E :<C-u>ExciteTranslate<CR>
endif
" }}}

" hateblo {{{
if s:has_plugin("hateblo")
	" api_keyはvimrc.localから設定.
	let g:hateblo_vim = {
		\ 'user':         'assout',
		\ 'api_key': g:hateblo_api_key,
		\ 'api_endpoint': 'https://blog.hatena.ne.jp/assout/assout.hatenablog.com/atom',
		\ 'WYSIWYG_mode': 0,
		\ 'always_yes':   0,
		\ 'edit_command': 'edit'
	\ }
	nmap [space]h [hateblo]
	nnoremap [hateblo]l :<C-u>HatebloList<CR>
	nnoremap [hateblo]c :<C-u>HatebloCreate<CR>
	nnoremap [hateblo]C :<C-u>HatebloCreateDraft<CR>
	nnoremap [hateblo]d :<C-u>HatebloDelete<CR>
	nnoremap [hateblo]u :<C-u>HatebloUpdate<CR>

endif
"}}}

" memolist {{{
if s:has_plugin("memolist")
	let g:memolist_memo_suffix = "md"
	if has('unix')
		let g:memolist_path = '~/Dropbox/memolist'
		let g:memolist_template_dir_path = '~/Dropbox/memolist'
	else
		let g:memolist_path = 'D:/admin/Documents/memolist'
		let g:memolist_template_dir_path = 'D:/admin/Documents/memolist'
	endif

	if s:has_plugin('unite')
		let g:unite_source_alias_aliases = {
					\	"memolist" : {
					\		"source" : "file",
					\		"args" : g:memolist_path,
					\	},
					\}
		call unite#custom_source('memolist', 'sorters', ["sorter_ftime", "sorter_reverse"])
		call unite#custom_source('memolist', 'matchers', ["converter_tail_abbr", "matcher_default"])
		nnoremap [memolist]l :<C-u>Unite memolist -buffer-name=memolist-buffer<CR>
	else
		nnoremap [memolist]l :<C-u>MemoList<CR>
	endif

	nmap [space]m [memolist]
	nnoremap [memolist]a :<C-u>MemoNew<CR>
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

" neosnippet {{{
" if s:has_plugin("neosnippet")
" 	" Plugin key-mappings.
" 	imap <C-k> <Pug>(neosnippet_expand_or_jump)
" 	smap <C-k> <Plug>(neosnippet_expand_or_jump)
" 	xmap <C-k> <Plug>(neosnippet_expand_target)
" 	xmap <C-l> <Plug>(neosnippet_start_unite_snippet_target)
"
" 	" SuperTab like snippets' behavior.
" 	"imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
" 	" \ "\<Plug>(neosnippet_expand_or_jump)"
" 	" \: pumvisible() ? "\<C-n>" : "\<TAB>"
" 	"smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
" 	" \ "\<Plug>(neosnippet_expand_or_jump)"
" 	" \: "\<TAB>"
"
" 	" For snippet_complete marker.
" 	if has('conceal')
" 		set conceallevel=2 concealcursor=i
" 	endif
"
" 	" Enable snipMate compatibility feature.
" 	" let g:neosnippet#enable_snipmate_compatibility = 1
" endif
" }}}

" previm {{{
if s:has_plugin("previm")
	nnoremap [space]p :<C-u>PrevimOpen<CR>
endif
" }}}

" quickrun {{{
if s:has_plugin("quickrun")
	nnoremap [space]q :<C-u>QuickRun<CR>
	nnoremap [space]Q :<C-u>QuickRun<Space>
endif
" }}}

" singleton {{{
if s:has_plugin("singleton") && has("clientserver")
	call singleton#enable()
endif
" }}}

" unite {{{
if s:has_plugin("unite")
	let g:unite_enable_ignore_case = 1
	let g:unite_enable_smart_case = 1
	let g:unite_source_grep_max_candidates = 200
	let g:unite_source_history_yank_enable = 1

	" source=directoryのデフォルトアクションをvimfilerにする.
	call unite#custom_default_action('directory', 'vimfiler')
	call unite#custom#alias('file', 'delete', 'vimfiler__delete')
	" ignore files.
	call unite#custom#source('file_rec', 'ignore_pattern', '(png\|gif\|jpeg\|jpg)$')
	call unite#custom#source('file_rec/async', 'ignore_pattern', '(png\|gif\|jpeg\|jpg)$')
	" sort rank
	call unite#custom_source('bookmark', 'sorters', ["sorter_ftime", "sorter_reverse"])

	nmap [space]u [unite]
	nnoremap [unite]<CR> :<C-u>Unite<CR>
	nnoremap [unite]b :<C-u>Unite buffer -buffer-name=buffer-buffer<CR>
	nnoremap [unite]B :<C-u>Unite bookmark -buffer-name=bookmark-buffer<CR>
	nnoremap [unite]f :<C-u>Unite file -buffer-name=file-buffer<CR>
	nnoremap [unite]d :<C-u>Unite directory -buffer-name=directory-buffer<CR>
	if has('win32')
		nnoremap [unite]F :<C-u>Unite file_rec -buffer-name=file_rec-buffer<CR>
		nnoremap [unite]D :<C-u>Unite directory_rec -buffer-name=directory_rec-buffer<CR>
	else
		nnoremap [unite]F :<C-u>Unite file_rec/async -buffer-name=file_rec/async-buffer<CR>
		nnoremap [unite]D :<C-u>Unite directory_rec/async -buffer-name=directory_rec/async-buffer<CR>
	endif
	nnoremap [unite]g :<C-u>Unite grep -buffer-name=grep-buffer<CR>
	nnoremap [unite]r :<C-u>Unite resume -buffer-name=resume-buffer<CR>
	nnoremap [unite]R :<C-u>Unite register -buffer-name=register-buffer<CR>
	nnoremap [unite]y :<C-u>Unite history/yank -buffer-name=hitory/yank-buffer<CR>
	nnoremap [unite]o :<C-u>Unite outline<CR>

	" neomru {{{
	if s:has_plugin("neomru")
		let g:neomru#filename_format = ''
		let g:neomru#do_validate = 0
		let g:neomru#file_mru_limit = 50
		let g:neomru#directory_mru_limit = 50

		nmap [unite]n [neomru]
		nnoremap [neomru]f :<C-u>Unite neomru/file -buffer-name=neomru/file-buffer<CR>
		nnoremap [neomru]d :<C-u>Unite neomru/directory -buffer-name=neomru/directory-buffer<CR>
	endif
	" }}}

	" unite-outline {{{
	if s:has_plugin("unite-outline")
		" Work around. http://totem3.hatenablog.jp/entry/2014/07/16/051101
		let g:unite_abbr_highlight = 'Normal'
	endif
	" }}}

	" unite-todo {{{
	if s:has_plugin("unite-todo")
		let g:unite_todo_note_suffix = 'md'
		if has('unix')
			let g:unite_todo_data_directory = '/home/oji/Dropbox'
		else
			let g:unite_todo_data_directory = 'D:/admin/Documents'
		endif

		function! Todo_grep()
			let word = input("TodoGrep word: ")
			if word == ''
				return
			endif
			execute ":grep -i " . l:word . " " . g:unite_todo_data_directory . "/todo/note/*"
		endfunction

		map [space]t [todo]
		noremap [todo]<CR> :UniteTodoAddSimple -tag -memo<CR>
		noremap [todo]a :UniteTodoAddSimple<CR>
		noremap [todo]t :UniteTodoAddSimple -tag<CR>
		noremap [todo]m :UniteTodoAddSimple -memo<CR>
		noremap [todo]l :<C-u>Unite todo:undone<CR>
		noremap [todo]L :<C-u>Unite todo<CR>
		noremap [todo]g :call Todo_grep()<CR>
	endif
	" }}}

	" OpenBrowser file: {{{
	let openbrowser_file = {
				\ 'description' : 'OpenBrowser file:/{word}',
				\ 'is_selectable' : 1,
				\ }
	function! openbrowser_file.func(candidates)"{{{
		for l:candidate in a:candidates
			call openbrowser#open('file:/'.l:candidate.action__path)
		endfor
	endfunction"}}}
	call unite#custom_action('openable', 'openbrowser_file', openbrowser_file)
	unlet openbrowser_file

	autocmd FileType unite call s:unite_my_keymappings()
	function! s:unite_my_keymappings()
		nnoremap <silent><buffer><expr> x unite#smart_map('x', unite#do_action('start'))
		nnoremap <silent><buffer><expr> m unite#smart_map('m', unite#do_action('move'))
		nnoremap <silent><buffer><expr> v unite#smart_map('v', unite#do_action('vimfiler'))
	endfunction
	" }}}
endif
" }}}

" vimfiler {{{
if s:has_plugin("vimfiler")
	let g:vimfiler_safe_mode_by_default = 0
	let g:vimfiler_as_default_explorer = 1

	nmap [space]v [vimfiler]
	nnoremap [vimfiler]<CR> :<C-u>VimFiler<CR>
	nnoremap [vimfiler]b :<C-u>VimFilerBufferDir<CR>
	nnoremap [vimfiler]c :<C-u>VimFilerCurrentDir<CR>
	nnoremap [vimfiler]d :<C-u>VimFilerDouble<CR>
	nnoremap [vimfiler]s :<C-u>VimFilerSplit<CR>
	nnoremap [vimfiler]t :<C-u>VimFilerTab<CR>
endif
" }}}

" vim-ref {{{
if s:has_plugin("vim-ref")
	" webdictサイトの設定.
	let g:ref_source_webdict_sites = {
				\   'je': {
				\     'url': 'http://dictionary.infoseek.ne.jp/jeword/%s',
				\   },
				\   'ej': {
				\     'url': 'http://dictionary.infoseek.ne.jp/ejword/%s',
				\   },
				\   'wiki': {
				\     'url': 'http://ja.wikipedia.org/wiki/%s',
				\   },
				\ }
	" デフォルトサイト.
	let g:ref_source_webdict_sites.default = 'ej'

	" 出力に対するフィルタ。最初の数行を削除.
	function! g:ref_source_webdict_sites.je.filter(output)
		return join(split(a:output, "\n")[15 :], "\n")
	endfunction
	function! g:ref_source_webdict_sites.ej.filter(output)
		return join(split(a:output, "\n")[15 :], "\n")
	endfunction
	function! g:ref_source_webdict_sites.wiki.filter(output)
		return join(split(a:output, "\n")[17 :], "\n")
	endfunction

	nmap [space]R [vim-ref]
	nnoremap [vim-ref]j :<C-u>Ref webdict je<Space>
	nnoremap [vim-ref]e :<C-u>Ref webdict ej<Space>
endif
" }}}

" vim-textobj-entire {{{
if s:has_plugin("vim-textobj-entire")
	nmap yae yae<C-o>
	nmap yie yie<C-o>
	nmap =ae =ae<C-o>
	nmap =ie =ie<C-o>
endif
" }}}
" }}}1

" Section; Auto-commands {{{1
augroup MyAutoGroup
	autocmd!
	" DoubleByteSpace highlight.
	autocmd VimEnter,Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
	autocmd VimEnter,WinEnter * match DoubleByteSpace /　/
	" markdown.
	autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
	autocmd FileType markdown highlight! def link markdownItalic LineNr | setlocal spell
	" 改行時の自動コメント継続をやめる(o,Oコマンドでの改行時のみ).
	autocmd FileType * set textwidth=0 formatoptions-=o
	" QuickFixを自動で開く,QuickFix内<CR>で選択できるようにする.
	autocmd QuickfixCmdPost make,grep,grepadd,vimgrep,helpgrep if len(getqflist()) != 0 | copen | endif | call s:openModifiableQF()
augroup END
" }}}1

" Section; Commands {{{1
" ファイルタイプ判別.
filetype on
" colorscheme
if s:isHomeUnix() || s:isOfficeWin()
	colorscheme hybrid-light
else
	colorscheme peachpuff
endif
" :qで誤って終了してしまうのを防ぐためcloseに置き換えちゃう.
cabbrev q <C-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'close' : 'q')<CR>
" }}}1

