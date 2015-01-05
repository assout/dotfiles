" Index {{{1
" * Begin.
" * Functions and Commands.
" * Options.
" * Let defines.
" * Key-mappings.
" * Plug-ins.
" * Auto-commands.
" * Other Commands.
" }}}1

" Section; Begin {{{1
" vi互換性.
set nocompatible
" load local vimrc.
if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
" }}}1

" Section; Functions and Commands {{{1
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
" Open Vim internal help by K command.
set keywordprg=:help
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

" Section; Key-mappings {{{1
" Prefix key mappings {{{2
" vimfilerとかと競合防ぐため.
map <Space> [space]

" [edit] mappings.
nmap [space]e [edit]
nnoremap [edit] <Nop>
" fugitiveで対象とするためpathを解決.
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
noremap [insert] <Nop>
noremap <silent> [insert]p :call <SID>insertPrefix(input("input prefix:"))<CR>
noremap <silent> [insert]t :call <SID>insertPrefix("TODO ")<CR>
noremap <silent> [insert]1 :call <SID>insertPrefix("# ")<CR>
noremap <silent> [insert]2 :call <SID>insertPrefix("## ")<CR>
noremap <silent> [insert]3 :call <SID>insertPrefix("### ")<CR>
noremap <silent> [insert]* :call <SID>insertPrefix("* ")<CR>
noremap <silent> [insert]> :call <SID>insertPrefix("> ")<CR>
noremap <silent> [insert]s :call <SID>insertSuffix(input("input suffix:"))<CR>
noremap <silent> [insert]n :call <SID>insertSuffix(" " . strftime("[%Y-%m-%d %H:%M:%S]"))<CR>
noremap <silent> [insert]l :call <SID>insertSuffix(" ")<CR>
noremap <silent> [insert]at :call <SID>insertSuffix("[asin::title]")<CR>0f:
noremap <silent> [insert]ad :call <SID>insertSuffix("[asin::detail]")<CR>0f:
noremap <silent> [insert]ai :call <SID>insertSuffix("[asin::image]")<CR>0f:

" [json] mappings.
if executable('python')
	xnoremap [space]j :!python -m json.tool<CR>
endif

" [reload] mappings.
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
	NeoBundle 'Shougo/neobundle.vim'
	NeoBundle 'assout/unite-todo'
	NeoBundle 'fuenor/im_control.vim'
	NeoBundle 'glidenote/memolist.vim'
	NeoBundle 'h1mesuke/vim-alignta'
	" NeoBundle 'haya14busa/vim-migemo'
	NeoBundle 'kana/vim-operator-user'
	NeoBundle 'kana/vim-textobj-entire'
	NeoBundle 'kana/vim-textobj-user'
	NeoBundle 'kannokanno/previm'
	NeoBundle 'koron/codic-vim'
	NeoBundle 'koron/dicwin-vim'
	NeoBundle 'mattn/excitetranslate-vim'
	NeoBundle 'mattn/webapi-vim'
	NeoBundle 'moznion/hateblo.vim'
	NeoBundle 'rhysd/vim-operator-surround'
	NeoBundle 'schickling/vim-bufonly'
	if has('lua')
		NeoBundle 'Shougo/neocomplete'
		" NeoBundle 'Shougo/neosnippet'
		" NeoBundle 'Shougo/neosnippet-snippets'
	endif
	NeoBundle 'Shougo/neomru.vim'
	NeoBundle 'Shougo/unite-outline'
	NeoBundle 'Shougo/unite.vim'
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
	NeoBundle 'thinca/vim-qfreplace' " grepした結果を置換.
	NeoBundle 'thinca/vim-quickrun'
	NeoBundle 'thinca/vim-singleton'
	NeoBundle 'tomtom/tcomment_vim'
	NeoBundle 'tpope/vim-fugitive'
	NeoBundle 'tpope/vim-repeat'
	NeoBundle 'tyru/open-browser.vim'
	NeoBundle 'tyru/restart.vim'
	NeoBundle 'vim-jp/vimdoc-ja'

	" color schemes.
	NeoBundle 'w0ng/vim-hybrid'

	call neobundle#end()
	filetype plugin indent on

elseif isdirectory($HOME . '/vimfiles/plugins') " At office
	let &runtimepath = &runtimepath.',/vimfiles/plugins'
	for path in split(glob($HOME.'/vimfiles/plugins/*'), '\n')
		if path !~# '\~$' && isdirectory(path)
			let &runtimepath = &runtimepath.','.path
		end
	endfor
endif
" }}}

if s:has_plugin("alignta") " {{{
	xnoremap [space]a :Alignta<Space>
endif
" }}}

if s:has_plugin("codic") " {{{
	nnoremap [space]c :<C-u>Codic<CR>
	nnoremap [space]C :<C-u>Codic<Space>
endif
" }}}

if s:has_plugin("excitetranslate") " {{{
	nnoremap [space]E :<C-u>ExciteTranslate<CR>
endif
" }}}

if s:has_plugin("hateblo") " {{{
	" api_keyはvimrc.localから設定.
	let g:hateblo_vim = {
				\ 'user': 'assout',
				\ 'api_key': g:hateblo_api_key,
				\ 'api_endpoint': 'https://blog.hatena.ne.jp/assout/assout.hatenablog.com/atom',
				\ 'WYSIWYG_mode': 0,
				\ 'always_yes': 0,
				\ 'edit_command': 'edit'
				\ }
	nmap [space]h [hateblo]
	nnoremap [hateblo] <Nop>
	nnoremap [hateblo]l :<C-u>HatebloList<CR>
	nnoremap [hateblo]c :<C-u>HatebloCreate<CR>
	nnoremap [hateblo]C :<C-u>HatebloCreateDraft<CR>
	nnoremap [hateblo]d :<C-u>HatebloDelete<CR>
	nnoremap [hateblo]u :<C-u>HatebloUpdate<CR>
endif
"}}}

if s:has_plugin("memolist") " {{{
	let g:memolist_memo_suffix = "md"
	if s:isHomeUnix()
		let g:memolist_path = '~/Dropbox/memolist'
		let g:memolist_template_dir_path = '~/Dropbox/memolist'
	elseif s:isOfficeWin()
		let g:memolist_path = 'D:/admin/Documents/memolist'
		let g:memolist_template_dir_path = 'D:/admin/Documents/memolist'
	endif

	nmap [space]m [memolist]
	nnoremap [memolist] <Nop>
	nnoremap [memolist]a :<C-u>MemoNew<CR>
	nnoremap [memolist]g :<C-u>MemoGrep<CR>

	if s:has_plugin('unite')
		let g:unite_source_alias_aliases = { "memolist" : { "source" : "file", "args" : g:memolist_path } }
		call unite#custom_source('memolist', 'sorters', ["sorter_ftime", "sorter_reverse"])
		call unite#custom_source('memolist', 'matchers', ["converter_tail_abbr", "matcher_default"])
		nnoremap [memolist]l :<C-u>Unite memolist -buffer-name=memolist-buffer<CR>
	else
		nnoremap [memolist]l :<C-u>MemoList<CR>
	endif
endif
" }}}

if s:has_plugin("neocomplete") " {{{
	let g:neocomplete#enable_at_startup = 1
	let g:neocomplete#enable_ignore_case = 1
	let g:neocomplete#enable_smart_case = 1
endif
" }}}

" if s:has_plugin("neosnippet") " {{{
" " Plugin key-mappings.
" imap <C-k> <Pug>(neosnippet_expand_or_jump)
" smap <C-k> <Plug>(neosnippet_expand_or_jump)
" xmap <C-k> <Plug>(neosnippet_expand_target)
" xmap <C-l> <Plug>(neosnippet_start_unite_snippet_target)
"
" " SuperTab like snippets' behavior.
" imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
" smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
"
" " For snippet_complete marker.
" if has('conceal')
" set conceallevel=2 concealcursor=i
" endif
"
" " Enable snipMate compatibility feature.
" let g:neosnippet#enable_snipmate_compatibility = 1
" endif
" " }}}

if s:has_plugin("open-browser") " {{{
	let g:netrw_nogx = 1 " disable netrw's gx mapping.
	nmap gx <Plug>(openbrowser-smart-search)
	vmap gx <Plug>(openbrowser-smart-search)
endif
"}}}

if s:has_plugin("previm") " {{{
	nnoremap [space]p :<C-u>PrevimOpen<CR>
endif
" }}}

if s:has_plugin("quickrun") " {{{
	nnoremap [space]q :<C-u>QuickRun<CR>
	nnoremap [space]Q :<C-u>QuickRun<Space>
endif
" }}}

if s:has_plugin("restart.vim") " {{{
	command! -bar RestartWithSession
				\ let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages' | Restart
endif
" }}}

if s:has_plugin("singleton") && has("clientserver") " {{{
	call singleton#enable()
endif
" }}}

if s:has_plugin("unite") " {{{
	let g:unite_enable_ignore_case = 1
	let g:unite_enable_smart_case = 1
	let g:unite_source_grep_max_candidates = 200
	let g:unite_source_history_yank_enable = 1
	let s:my_relative_move = {'description' : 'move after lcd', 'is_selectable' : 1, 'is_quit' : 0 }

	function! s:my_relative_move.func(candidates)
		let candidate = a:candidates[0]
		let l:dir = isdirectory(candidate.word) ? candidate.word : fnamemodify(candidate.word, ':p:h')
		execute g:unite_kind_cdable_lcd_command fnameescape(l:dir)
		call unite#take_action('move', a:candidates)
		" 呼ばないと表示更新されない.
		call unite#force_redraw()
	endfunction

	function! s:unite_my_keymappings()
		nnoremap <buffer><expr> x unite#smart_map('x', unite#do_action('start'))
		nnoremap <buffer><expr> m unite#smart_map('m', unite#do_action('relative_move'))
		" kind:directoryはdefaultでvimfilerだが、kind:fileとかに対して実行するため.
		nnoremap <buffer><expr> v unite#smart_map('v', unite#do_action('vimfiler'))
	endfunction

	call unite#custom#default_action('directory', 'vimfiler')
	call unite#custom#action('file,directory', 'relative_move', s:my_relative_move)
	call unite#custom#alias('file', 'delete', 'vimfiler__delete')
	call unite#custom#source('file_rec', 'ignore_pattern', '(png\|gif\|jpeg\|jpg)$')
	call unite#custom#source('file_rec/async', 'ignore_pattern', '(png\|gif\|jpeg\|jpg)$')
	call unite#custom#source('bookmark', 'sorters', ["sorter_ftime", "sorter_reverse"])

	" TODO autocmd!しなくて大丈夫？
	autocmd FileType unite call s:unite_my_keymappings()

	nmap [space]u [unite]
	nnoremap [unite] <Nop>
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

	if s:has_plugin("neomru") " {{{
		let g:neomru#filename_format = ''
		let g:neomru#do_validate = 0
		let g:neomru#file_mru_limit = 20
		let g:neomru#directory_mru_limit = 20

		nmap [unite]n [neomru]
		nnoremap [neomru]f :<C-u>Unite neomru/file -buffer-name=neomru/file-buffer<CR>
		nnoremap [neomru]d :<C-u>Unite neomru/directory -buffer-name=neomru/directory-buffer<CR>
	endif
	" }}}

	if s:has_plugin("open-browser") " {{{
		let s:openbrowser_file = { 'description' : 'OpenBrowser file:/{word}', 'is_selectable' : 1, }
		function! s:openbrowser_file.func(candidates)"{{{
			for l:candidate in a:candidates
				call openbrowser#open('file:/' . l:candidate.action__path)
			endfor
		endfunction"}}}
		call unite#custom_action('openable', 'openbrowser_file', s:openbrowser_file)
	endif
	" }}}

	if s:has_plugin("unite-todo") " {{{
		let g:unite_todo_note_suffix = 'md'
		if s:isHomeUnix()
			let g:unite_todo_data_directory = '/home/oji/Dropbox'
		elseif s:isOfficeWin()
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
		noremap [todo] <Nop>
		noremap [todo]<CR> :UniteTodoAddSimple -tag -memo<CR>
		noremap [todo]a :UniteTodoAddSimple<CR>
		noremap [todo]t :UniteTodoAddSimple -tag<CR>
		noremap [todo]m :UniteTodoAddSimple -memo<CR>
		noremap [todo]l :<C-u>Unite todo:undone<CR>
		noremap [todo]L :<C-u>Unite todo<CR>
		noremap [todo]g :call Todo_grep()<CR>
	endif
	" }}}
endif
" }}}

if s:has_plugin("vimfiler") " {{{
	let g:vimfiler_safe_mode_by_default = 0
	let g:vimfiler_as_default_explorer = 1

	nmap [space]f [vimfiler]
	nnoremap [vimfiler] <Nop>
	nnoremap [vimfiler]<CR> :<C-u>VimFiler<CR>
	nnoremap [vimfiler]b :<C-u>VimFilerBufferDir<CR>
	nnoremap [vimfiler]c :<C-u>VimFilerCurrentDir<CR>
	nnoremap [vimfiler]d :<C-u>VimFilerDouble<CR>
	nnoremap [vimfiler]s :<C-u>VimFilerSplit<CR>
	nnoremap [vimfiler]t :<C-u>VimFilerTab<CR>
endif
" }}}

if s:has_plugin("vim-operator-surround") " {{{
	map <silent>sa <Plug>(operator-surround-append)
	map <silent>sd <Plug>(operator-surround-delete)
	map <silent>sr <Plug>(operator-surround-replace)
endif
" }}}

if s:has_plugin("vim-ref") " {{{
	" webdictサイトの設定.
	let g:ref_source_webdict_sites = {
				\ 'je': {
				\ 'url': 'http://dictionary.infoseek.ne.jp/jeword/%s',
				\ },
				\ 'ej': {
				\ 'url': 'http://dictionary.infoseek.ne.jp/ejword/%s',
				\ },
				\ 'wiki': {
				\ 'url': 'http://ja.wikipedia.org/wiki/%s',
				\ },
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

if s:has_plugin("vim-textobj-entire") " {{{
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

" Section; Other Commands {{{1
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

