" Index {{{1
" * Principles.
" * Begin.
" * Functions and Commands.
" * Auto-commands.
" * Options.
" * Let defines.
" * Key-mappings.
" * Plug-ins.
" * Other Commands.
" }}}1

" Section; Principles {{{1
" * Keep it short and simple, stupid! (500step以下に留めたい)
" * to portable! (e.g. office/home, vim/gvim/vrapper, development/server)
" * デフォルト環境(サーバ)での操作時に混乱するようなカスタマイズはしない(e.g. ;と:の入れ替え)
" # refereces
" * [Vim で使える Ctrl を使うキーバインドまとめ - 反省はしても後悔はしない](http://cohama.hateblo.jp/entry/20121023/1351003586)
" }}}1

" Section; Begin {{{1
" inner encoding(before the scriptencoding)
if has('gui_running')
	set encoding=utf-8
endif
" before multi byte.
scriptencoding utf-8
" load local vimrc.
if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
" augroup unbind.
augroup vimrc
	autocmd!
augroup END
" }}}1

" Section; Functions and Commands {{{1
" command実行結果をキャプチャ.
function! s:capture_cmd_output(cmd)
	if has('clipboard')
		redir @+>
	else
		redir @">
	endif
	" silent で画面描画なし.
	silent execute a:cmd
	redir END
endfunction
command! -nargs=1 -complete=command Capture call <SID>capture_cmd_output(<q-args>)

" pluginが存在するか調べる.
function! s:has_plugin(plugin)
	return !empty(matchstr(&runtimepath, a:plugin))
endfunction

" quickfix: 編集許可と折り返し表示無効.
function! s:openModifiableQF()
	set modifiable
	set nowrap
endfunction

function! s:insertPrefix(str) range
	execute a:firstline . ',' . a:lastline . 'substitute/^/' . substitute(a:str, '/', '\\/', 'g')
endfunction

function! s:insertSuffix(str) range
	execute a:firstline . ',' . a:lastline . 'substitute/$/' . substitute(a:str, '/', '\\/', 'g')
endfunction

function! s:isHomeUnix()
	return $USER ==# 'oji' && has('unix')
endfunction

function! s:isHomeWin()
	return $USER ==# 'oji' && has('win32')
endfunction

function! s:isOfficeUnix()
	return $USER !=# 'oji' && has('unix')
endfunction

function! s:isOfficeWin()
	return $USER !=# 'oji' && has('win32')
endfunction

if ! has('kaoriya')
	command! -nargs=0 CdCurrent cd %:p:h
endif

if ! s:isOfficeUnix() " TODO 原因不明だがwindowsだとvimrc読み込み時にエラーとなるため.
	function! s:formatXml()
		" TODO vintで引っかかる.
		:%substitute/></>\r</g | filetype indent on | setfiletype xml | normal! gg=G
	endfunction
	command! -complete=command FormatXml call <SID>formatXml()
endif
" }}}1

" Section; Auto-commands {{{1
augroup vimrc
	" DoubleByteSpace highlight.
	autocmd VimEnter,Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
	autocmd VimEnter,WinEnter * match DoubleByteSpace /　/
	autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
	autocmd FileType markdown highlight! def link markdownItalic LineNr | setlocal spell
	" 改行時の自動コメント継続をやめる.(o,Oコマンドでの改行時のみ)
	autocmd FileType * set textwidth=0 formatoptions-=o
	" QuickFixを自動で開く,QuickFix内<CR>で選択できるようにする.
	autocmd QuickfixCmdPost make,grep,grepadd,vimgrep,helpgrep if len(getqflist()) != 0 | copen | endif | call s:openModifiableQF()
	" format json.
	if executable('python')
		autocmd BufNewFile,BufRead *.json nnoremap <buffer> [space]j :%!python -m json.tool<CR>
		autocmd BufNewFile,BufRead *.json xnoremap <buffer> [space]j :!python -m json.tool<CR>
	endif
	" pluginでの設定だけだとたまにハードタブのままになっちゃうのでここで指定.
	autocmd FileType yaml,ansible setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
augroup END
" }}}1

" Section; Options {{{1
set autoindent
set nobackup
set clipboard=unnamed,unnamedplus
set diffopt+=vertical
set noexpandtab
" set expandtab " ソフトタブに切り替えられるようにコメントアウトしとく.
set fileencodings=utf-8,ucs-bom,iso-2020-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,latin,latin1,utf-8
if has('folding')
	set foldlevelstart=0
	set foldmethod=marker
endif
set formatoptions-=o " フォーマットオプション(-oでo,Oコマンドでの改行時のコメント継続をなくす)
if has('win32') && executable('grep')
	set grepprg=grep\ -nH
endif
set hidden
set hlsearch
set ignorecase
set incsearch
set keywordprg=:help " Open Vim internal help by K command.
set list
set listchars=tab:>.,trail:_,extends:\
set laststatus=2
set lazyredraw " マクロなどを実行中は描画を中断.
set number
set nrformats="" " インクリメンタル/デクリメンタルを常に10進数として扱う.
set scrolloff=5
set shiftwidth=4
set showtabline=1
set sidescrolloff=5
set smartcase
set smartindent
" スペルチェック用辞書ファイル.
if s:isOfficeWin()
	set spellfile=D:/admin/Documents/spell/en.utf-8.add
elseif s:isHomeUnix()
	set spellfile=~/Dropbox/spell/en.utf-8.add
endif
set splitbelow
set splitright
set spelllang+=cjk " スペルチェックで日本語は除外する.
set tabstop=4
set textwidth=0 " 自動改行をなくす.
set title
if has('win32')
	set noundofile " Undoファイルの有効無効.
endif
set wildmenu
set nowrap
set nowrapscan
if has('win32')
	set noswapfile " swapfile作成有無(offにするとvimfilerでのネットワークフォルダ閲覧が高速化するかも(効果は不明)).
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
" vimfilerとかと競合防ぐため[space]にわりあてている(詳細忘れた).
" TODO Vrapperで[space]prefix系が全般効かない.
map <Space> [space]
noremap [space] <Nop>
noremap [space]h 0
noremap [space]l $

" Caution! jk も試したけど合わなかったよ(visual mode だとできないし、j のあとキー入力待ちになるの気持ちわるい)
inoremap <C-j> <Esc>
vnoremap <C-j> <Esc>
" Caution! cnoremapではできないよ。(<C-c>でできるよ) -> :h c_Esc

" 検索結果ハイライトを解除. TODO [space][space]だとうごかない。なぜ。
nnoremap <Space><Space> :nohlsearch<CR>

" [insert] mappings.
" Caution! 「:<C-u>hogehoge」と定義すると複数行選択が無効になってしまうのでしないこと。
" TODO プラグイン化.  kana/vim-operator-userの追加operatorとするのが良さそう？
" TODO prefix入力後挿入モードにしたい？
map [space]i [insert]
noremap [insert] <Nop>
noremap <silent> [insert]p :call <SID>insertPrefix(input('input prefix:'))<CR>
noremap <silent> [insert]f :call <SID>insertPrefix('file://')<CR>
noremap <silent> [insert]T :call <SID>insertPrefix('TODO ')<CR>
noremap <silent> [insert]1 :call <SID>insertPrefix('# ')<CR>
noremap <silent> [insert]2 :call <SID>insertPrefix('## ')<CR>
noremap <silent> [insert]3 :call <SID>insertPrefix('### ')<CR>
noremap <silent> [insert]4 :call <SID>insertPrefix('#### ')<CR>
noremap <silent> [insert]* :call <SID>insertPrefix('* ')<CR>
noremap <silent> [insert]> :call <SID>insertPrefix('> ')<CR>
noremap <silent> [insert]s :call <SID>insertSuffix(input('input suffix:'))<CR>
noremap <silent> [insert]d :call <SID>insertSuffix(strftime(' @%Y-%m-%d'))<CR>
noremap <silent> [insert]t :call <SID>insertSuffix(strftime(' @%H:%M:%S'))<CR>
noremap <silent> [insert]n :call <SID>insertSuffix(strftime(' @%Y-%m-%d %H:%M:%S'))<CR>
noremap <silent> [insert]a :call <SID>insertSuffix(' @' . input('input author:'))<CR>
noremap <silent> [insert]l :call <SID>insertSuffix('  ')<CR>

" [open] mappings.
nmap [space]o [open]
nnoremap [open] <Nop>
" resolveしなくても開けるが、fugitiveで対象とするため.
" Caution! executeでなく<expr>だとvrapperから読み込んだときにエラーになる.
nnoremap [open]v :<C-u>execute ':edit ' . resolve(expand($MYVIMRC))<CR>
if s:isOfficeWin()
	nnoremap [open]i :<C-u>edit D:\admin\Documents\ipmsg.log<CR>
endif

" [reload] mappings.
nnoremap [space]r :update $MYVIMRC<Bar>:update $MYGVIMRC<Bar>:source $MYVIMRC<Bar>:source $MYGVIMRC<CR>

" windowのカーソル移動.
nnoremap <C-h> <C-W>h
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-l> <C-W>l
" windowのオープンとクローズ.
nnoremap  <C-s> <C-W>s
" Caution! ほんとはg<C-s>じゃなく<C-S-s>とかに割り当てたいが<C-s>と区別されない.めんどいっぽい.
nnoremap g<C-s> <C-W>v
nnoremap  <C-c> <C-W>c
" windowの移動
nnoremap <C-Left>  <C-W>H
nnoremap <C-Down>  <C-W>J
nnoremap <C-Up>    <C-W>K
nnoremap <C-Right> <C-W>L

" tab操作. <TAB> = <C-i>であることに注意.
nnoremap   <C-TAB>     gt
nnoremap   <C-S-TAB>   gT

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

" バッファ、ウィンドウ、タブ移動関連.
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap [B :bfirst<CR>
nnoremap ]B :blast<CR>
nnoremap [w :wincmd W<CR>
nnoremap ]w :wincmd w<CR>
nnoremap [W :wincmd t<CR>
nnoremap ]W :wincmd b<CR>
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
	NeoBundle 'assout/unite-todo'
	NeoBundle 'chase/vim-ansible-yaml'
	NeoBundle 'fuenor/im_control.vim'
	NeoBundle 'glidenote/memolist.vim'
	" TODO windows/linuxで,wでのfowardが効かない(mappingはされてるっぽい)
	NeoBundle 'h1mesuke/textobj-wiw'
	NeoBundle 'h1mesuke/vim-alignta'
	" TODO windowsでmigemoれない.
	" NeoBundle 'haya14busa/vim-migemo'
	NeoBundle 'kana/vim-operator-user'
	NeoBundle 'kana/vim-operator-replace'
	NeoBundle 'kana/vim-submode'
	NeoBundle 'kana/vim-textobj-entire'
	NeoBundle 'kana/vim-textobj-function'
	NeoBundle 'kana/vim-textobj-indent'
	NeoBundle 'kana/vim-textobj-line'
	NeoBundle 'kana/vim-textobj-user'
	NeoBundle 'kannokanno/previm'
	NeoBundle 'koron/codic-vim'
	NeoBundle 'koron/dicwin-vim'
	NeoBundle 'LeafCage/yankround.vim'
	NeoBundle 'mattn/emmet-vim' " markdownのurl形式取得にしか使ってない.
	NeoBundle 'mattn/excitetranslate-vim'
	NeoBundle 'mattn/gist-vim'
	NeoBundle 'mattn/qiita-vim'
	NeoBundle 'mattn/unite-gist'
	NeoBundle 'mattn/vim-textobj-url'
	NeoBundle 'mattn/webapi-vim'
	" NeoBundle 'moznion/hateblo.vim'
	NeoBundle 'TKNGUE/hateblo.vim' " entryの保存位置を指定できるためfork版を使用。本家へもpull reqでてるので、取り込まれたら見先を変える。
	NeoBundle 'rhysd/vim-textobj-anyblock' " life changing. dib, dab.
	NeoBundle 'rhysd/vim-operator-surround' " life changing. sdb, sdf{char}.
	NeoBundle 'pangloss/vim-javascript' " for indent.
	NeoBundle 'schickling/vim-bufonly'
	NeoBundle 'szw/vim-maximizer' " windowの最大化・復元
	NeoBundle 'Shougo/neobundle.vim'
	if has('lua')
		NeoBundle 'Shougo/neocomplete'
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
	NeoBundle 'thinca/vim-textobj-between' " life changing. dif{char} , daf{char}
	NeoBundle 'thinca/vim-textobj-comment'
	NeoBundle 'tomtom/tcomment_vim'
	NeoBundle 'tpope/vim-fugitive'
	NeoBundle 'tpope/vim-repeat'
	NeoBundle 'tyru/open-browser.vim'
	NeoBundle 'tyru/operator-camelize.vim'
	NeoBundle 'tyru/restart.vim'
	NeoBundle 'vim-jp/vimdoc-ja'
	NeoBundle 'vim-scripts/DirDiff.vim' " 文字化けするけど.
	" color schemes.
	NeoBundle 'w0ng/vim-hybrid'
	call neobundle#end()
	filetype plugin indent on

elseif isdirectory($HOME . '/vimfiles/plugins') " At office
	let &runtimepath = &runtimepath.',/vimfiles/plugins'
	for s:addingPath in split(glob($HOME.'/vimfiles/plugins/*'), '\n')
		if s:addingPath !~# '\~$' && isdirectory(s:addingPath)
			let &runtimepath = &runtimepath . ',' . s:addingPath
		end
	endfor
endif
" }}}

if s:has_plugin('alignta') " {{{
	xnoremap [space]a :Alignta<Space>
endif " }}}

if s:has_plugin('codic') " {{{
	nnoremap [space]c :<C-u>Codic<CR>
endif " }}}

if s:has_plugin('excitetranslate') " {{{
	noremap [space]e :<C-u>ExciteTranslate<CR>
endif " }}}

if s:has_plugin('gist-vim') " {{{
	let g:gist_detect_filetype = 1
	let g:gist_get_multiplefile = 1
	nmap [space]g [Gist]
	nnoremap [Gist]     <Nop>
	nnoremap [Gist]l    :<C-u>Unite gist<CR>
	nnoremap [Gist]c    :<C-u>Gist<CR>
	nnoremap [Gist]<CR> :<C-u>Gist<CR>
endif " }}}

if s:has_plugin('hateblo') " {{{
	" api_keyはvimrc.localから設定.
	let g:hateblo_vim = {
				\ 'user': 'assout',
				\ 'api_key': g:hateblo_api_key,
				\ 'api_endpoint': 'https://blog.hatena.ne.jp/assout/assout.hatenablog.com/atom',
				\ 'WYSIWYG_mode': 0,
				\ 'always_yes': 0,
				\ 'edit_command': 'edit'
				\ }
	let g:hateblo_dir = '$HOME/.cache/hateblo/blog'

	nmap [space]H [hateblo]
	nnoremap [hateblo] <Nop>
	nnoremap [hateblo]l :<C-u>HatebloList<CR>
	nnoremap [hateblo]c :<C-u>HatebloCreate<CR>
	nnoremap [hateblo]C :<C-u>HatebloCreateDraft<CR>
	nnoremap [hateblo]d :<C-u>HatebloDelete<CR>
	nnoremap [hateblo]u :<C-u>HatebloUpdate<CR>
endif " }}}

if s:has_plugin('im_control') " {{{
	if s:isHomeUnix()
		""""""""""""""""""""""""""""""
		" 日本語入力固定モードの制御関数
		" xev でキーコード確認すること
		""""""""""""""""""""""""""""""
		let IM_CtrlMode = has('gui_running') ? 1 : 0 " Caution! Vim(非GUIのときに変な挙動（ESC時に1文字削除)
		function! IMCtrl(cmd)
			let cmd = a:cmd
			if cmd ==? 'On'
				let res = system('xvkbd -text "\[Henkan_Mode]\" > /dev/null 2>&1')
			elseif cmd ==? 'Off'
				let res = system('xvkbd -text "\[Muhenkan]" > /dev/null 2>&1')
			elseif cmd ==? 'Toggle'
				let res = system('xvkbd -text "\[Zenkaku_Hankaku]" > /dev/null 2>&1')
			endif
			return ''
		endfunction
	endif
endif " }}}

if s:has_plugin('memolist') " {{{
	let g:memolist_memo_suffix = 'md'
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
		let g:unite_source_alias_aliases = { 'memolist' : { 'source' : 'file', 'args' : g:memolist_path } }
		call unite#custom_source('memolist', 'sorters', ['sorter_ftime', 'sorter_reverse'])
		call unite#custom_source('memolist', 'matchers', ['converter_tail_abbr', 'matcher_default'])
		nnoremap [memolist]l :<C-u>Unite memolist -buffer-name=memolist<CR>
	else
		nnoremap [memolist]l :<C-u>MemoList<CR>
	endif
endif " }}}

if s:has_plugin('neocomplete') " {{{
	let g:neocomplete#enable_at_startup = 1
endif " }}}

if s:has_plugin('open-browser') " {{{
	" gxでディレクトリをエクスプローラで開くことができなくなるためunixのみで有効.
	if s:isHomeUnix()
		let g:netrw_nogx = 1 " disable netrw's gx mapping.
		nmap gx <Plug>(openbrowser-smart-search)
		vmap gx <Plug>(openbrowser-smart-search)
	endif
endif " }}}

if s:has_plugin('operator-camelize') " {{{
	map [space]C <Plug>(operator-camelize)
endif " }}}

if s:has_plugin('operator-replace') " {{{
	map R <Plug>(operator-replace)
endif " }}}

if s:has_plugin('previm') " {{{
	nnoremap [space]p :<C-u>PrevimOpen<CR>
endif " }}}

if s:has_plugin('qiita-vim') " {{{
	nmap [space]q [Qiita]
	nnoremap [Qiita]     <Nop>
	nnoremap [Qiita]l    :<C-u>Unite qiita<CR>
	nnoremap [Qiita]c    :<C-u>Qiita<CR>
	nnoremap [Qiita]<CR> :<C-u>Qiita<CR>
	nnoremap [Qiita]e    :<C-u>Qiita -e<CR>
	nnoremap [Qiita]d    :<C-u>Qiita -d<CR>
endif " }}}

if s:has_plugin('quickrun') " {{{
	nnoremap [space]Q :<C-u>QuickRun<CR>
endif " }}}

if s:has_plugin('restart.vim') " {{{
	command! -bar RestartWithSession let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages' | Restart
endif " }}}

if s:has_plugin('singleton') && has('clientserver') " {{{
	let g:singleton#opener = 'vsplit'
	call singleton#enable()
endif " }}}

if s:has_plugin('tcomment_vim') " {{{
	let g:tcommentTextObjectInlineComment = 'iC'
endif " }}}

if s:has_plugin('unite') " {{{
	let g:unite_enable_ignore_case = 1
	let g:unite_enable_smart_case = 1
	let g:unite_source_grep_max_candidates = 200
	let g:unite_source_history_yank_enable = 1
	let s:my_relative_move = {'description' : 'move after lcd', 'is_selectable' : 1, 'is_quit' : 0 }

	function! s:my_relative_move.func(candidates) " move先を相対パスで指定するaction.
		let candidate = a:candidates[0]
		let l:dir = isdirectory(candidate.word) ? candidate.word : fnamemodify(candidate.word, ':p:h')
		execute g:unite_kind_cdable_lcd_command fnameescape(l:dir)
		call unite#take_action('move', a:candidates)
		" 呼ばないと表示更新されない(なぜ?).
		call unite#force_redraw()
	endfunction

	function! s:unite_my_keymappings()
		" surroundのmappingと被るのでnowait.
		nnoremap <buffer><expr><nowait> s unite#smart_map('s', unite#do_action('split'))
		nnoremap <buffer><expr>         v unite#smart_map('v', unite#do_action('vsplit'))
		" kind:directoryはdefaultでvimfilerにしているので下記設定は不要だが、kind:fileとかに対して実行するため.
		nnoremap <buffer><expr>         f unite#smart_map('f', unite#do_action('vimfiler'))
		nnoremap <buffer><expr>         x unite#smart_map('x', unite#do_action('start'))
		nnoremap <buffer><expr>         m unite#smart_map('m', unite#do_action('relative_move'))
		nunmap <buffer> <C-h>
		nunmap <buffer> <C-l>
		nunmap <buffer> <C-k>
		nmap   <buffer>   g<C-h>   <Plug>(unite_delete_backward_path)
		nmap   <buffer>   <C-w>    <Plug>(unite_delete_backward_path)
		nmap   <buffer>   g<C-l>   <Plug>(unite_redraw)
		nmap   <buffer>   g<C-k>   <Plug>(unite_print_candidate)
	endfunction
	augroup vimrc
		autocmd FileType unite call s:unite_my_keymappings()
	augroup END

	call unite#custom#default_action('directory', 'vimfiler')
	call unite#custom#action('file,directory', 'relative_move', s:my_relative_move)
	call unite#custom#alias('file', 'delete', 'vimfiler__delete')
	call unite#custom#source('file_rec', 'ignore_pattern', '(png\|gif\|jpeg\|jpg)$')
	call unite#custom#source('file_rec/async', 'ignore_pattern', '(png\|gif\|jpeg\|jpg)$')
	call unite#custom#source('bookmark', 'sorters', ['sorter_ftime', 'sorter_reverse'])

	nmap [space]u [unite]
	nnoremap [unite] <Nop>
	nnoremap [unite]<CR> :<C-u>Unite<CR>
	nnoremap [unite]b :<C-u>Unite buffer -buffer-name=buffer<CR>
	nnoremap [unite]B :<C-u>Unite bookmark -buffer-name=bookmark<CR>
	nnoremap [unite]d :<C-u>Unite directory -buffer-name=directory<CR>
	nnoremap [unite]f :<C-u>Unite file -buffer-name=file<CR>
	if has('win32')
		nnoremap [unite]D :<C-u>Unite directory_rec -buffer-name=directory_rec<CR>
		nnoremap [unite]F :<C-u>Unite file_rec -buffer-name=file_rec<CR>
	else
		nnoremap [unite]D :<C-u>Unite directory_rec/async -buffer-name=directory_rec/async<CR>
		nnoremap [unite]F :<C-u>Unite file_rec/async -buffer-name=file_rec/async<CR>
	endif
	nnoremap [unite]g :<C-u>Unite grep -buffer-name=grep<CR>
	nnoremap [unite]o :<C-u>Unite outline -buffer-name=outline -no-quit -vertical -winwidth=30 -direction=botright<CR>
	nnoremap [unite]r :<C-u>Unite resume -buffer-name=resume<CR>
	nnoremap [unite]R :<C-u>Unite register -buffer-name=register<CR>
	nnoremap [unite]t :<C-u>Unite tab -buffer-name=tab<CR>
	nnoremap [unite]w :<C-u>Unite window -buffer-name=window<CR>
	nnoremap [unite]y :<C-u>Unite history/yank -buffer-name=hitory/yank<CR>

	if s:has_plugin('neomru') " {{{
		let g:neomru#filename_format = ''
		let g:neomru#do_validate = 0
		let g:neomru#file_mru_limit = 50
		let g:neomru#directory_mru_limit = 50

		nmap [unite]n [neomru]
		nnoremap [neomru]f :<C-u>Unite neomru/file -buffer-name=neomru/file<CR>
		nnoremap [neomru]d :<C-u>Unite neomru/directory -buffer-name=neomru/directory<CR>
	endif " }}}

	if s:has_plugin('unite-todo') " {{{
		let g:unite_todo_note_suffix = 'md'
		if s:isHomeUnix()
			let g:unite_todo_data_directory = '~/Dropbox'
		elseif s:isOfficeWin()
			let g:unite_todo_data_directory = 'D:/admin/Documents'
		endif

		function! s:todo_grep()
			let word = input('TodoGrep word: ')
			if empty(word)
				return
			endif
			execute ':vimgrep /' . l:word . '/ ' . g:unite_todo_data_directory . '/todo/note/*'
		endfunction

		" Caution! 「:<C-u>hogehoge」と定義すると複数行選択が無効になってしまうのでしないこと。
		map [space]t [unite-todo]
		noremap [unite-todo]     <Nop>
		noremap [unite-todo]<CR> :UniteTodoAddSimple -tag -memo<CR>
		noremap [unite-todo]a    :UniteTodoAddSimple<CR>
		noremap [unite-todo]t    :UniteTodoAddSimple -tag<CR>
		noremap [unite-todo]m    :UniteTodoAddSimple -memo<CR>
		noremap [unite-todo]l    :Unite todo:undone -buffer-name=todo<CR>
		noremap [unite-todo]L    :Unite todo -buffer-name=todo<CR>
		noremap [unite-todo]g    :call <SID>todo_grep()<CR>
	endif " }}}
endif " }}}

if s:has_plugin('vimfiler') " {{{
	let g:vimfiler_safe_mode_by_default = 0 " This variable controls vimfiler enter safe mode by default.
	let g:vimfiler_as_default_explorer = 1 " If this variable is true, Vim use vimfiler as file manager instead of |netrw|.

	nmap [space]f [vimfiler]
	nnoremap [vimfiler] <Nop>
	nnoremap [vimfiler]<CR> :<C-u>VimFiler<CR>
	nnoremap [vimfiler]b    :<C-u>VimFilerBufferDir<CR>
	nnoremap [vimfiler]c    :<C-u>VimFilerCurrentDir<CR>
	nnoremap [vimfiler]d    :<C-u>VimFilerDouble<CR>
	nnoremap [vimfiler]s    :<C-u>VimFilerSplit<CR>
	nnoremap [vimfiler]t    :<C-u>VimFilerTab<CR>
endif " }}}

if s:has_plugin('vim-ansible-yaml') " {{{
	let g:ansible_options = {'ignore_blank_lines': 1}
endif " }}}

if s:has_plugin('vim-maximizer') " {{{
	let g:maximizer_default_mapping_key = '<C-t>' " C-t潰してもいいの?.
endif " }}}

if s:has_plugin('vim-operator-surround') " {{{
	map <silent> sa <Plug>(operator-surround-append)
	map <silent> sd <Plug>(operator-surround-delete)
	map <silent> sr <Plug>(operator-surround-replace)

	" if you use vim-textobj-anyblock
	nmap <silent>sab <Plug>(operator-surround-delete)<Plug>(textobj-anyblock-a)
	nmap <silent>sdb <Plug>(operator-surround-delete)<Plug>(textobj-anyblock-a)
	nmap <silent>srb <Plug>(operator-surround-replace)<Plug>(textobj-anyblock-a)

	" if you use vim-textobj-between
	nmap <silent>saf <Plug>(operator-surround-append)<Plug>(textobj-between-a)
	nmap <silent>sdf <Plug>(operator-surround-delete)<Plug>(textobj-between-a)
	nmap <silent>srf <Plug>(operator-surround-replace)<Plug>(textobj-between-a)

	" if you use vim-textobj-line"
	nmap <silent>sal <Plug>(operator-surround-append)<Plug>(textobj-line-a)
	nmap <silent>sdl <Plug>(operator-surround-delete)<Plug>(textobj-line-a)
	nmap <silent>srl <Plug>(operator-surround-replace)<Plug>(textobj-line-a)
endif " }}}

if s:has_plugin('vim-ref') " {{{
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
		return join(split(a:output, '\n')[15 :], '\n')
	endfunction
	function! g:ref_source_webdict_sites.ej.filter(output)
		return join(split(a:output, '\n')[15 :], '\n')
	endfunction
	function! g:ref_source_webdict_sites.wiki.filter(output)
		return join(split(a:output, '\n')[17 :], '\n')
	endfunction

	nmap [space]R [vim-ref]
	nnoremap [vim-ref]j :<C-u>Ref webdict je<Space>
	nnoremap [vim-ref]e :<C-u>Ref webdict ej<Space>
endif " }}}

if s:has_plugin('vim-submode') " {{{
	call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
	call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
	call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
	call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
	call submode#map('winsize', 'n', '', '>', '<C-w>>')
	call submode#map('winsize', 'n', '', '<', '<C-w><')
	call submode#map('winsize', 'n', '', '+', '<C-w>-')
	call submode#map('winsize', 'n', '', '-', '<C-w>+')
endif " }}}

if s:has_plugin('vim-textobj-entire') " {{{
	nmap yae yae<C-o>
	nmap yie yie<C-o>
	nmap =ae =ae<C-o>
	nmap =ie =ie<C-o>
endif " }}}

if s:has_plugin('vim-textobj-function') " {{{
	" text-obj-between用にf -> Fに退避.
	" TODO windowsで効かない(mappingはされてるっぽい)
	let g:textobj_function_no_default_key_mappings = 1
	omap iF <Plug>(textobj-function-i)
	omap aF <Plug>(textobj-function-a)
	vmap iF <Plug>(textobj-function-i)
	vmap aF <Plug>(textobj-function-a)
endif " }}}

if s:has_plugin('yankround.vim') " {{{
	nmap p <Plug>(yankround-p)
	nmap P <Plug>(yankround-P)
	nmap <C-p> <Plug>(yankround-prev)
	nmap <C-n> <Plug>(yankround-next)
endif " }}}

" }}}1

" Section; Other Commands {{{1
filetype on
if s:isHomeUnix() || s:isOfficeWin()
	colorscheme hybrid-light
else
	colorscheme peachpuff
endif
" :qで誤って終了してしまうのを防ぐためcloseに置き換えちゃう.
cabbrev q <C-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'close' : 'q')<CR>
" }}}1

" vim:nofoldenable:

