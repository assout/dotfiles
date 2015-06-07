" Index {{{1
" * Introduction
" * Begin
" * Functions and Commands
" * Auto-commands
" * Options
" * Let defines
" * Key-mappings
" * Plug-ins
" * Other Commands
" }}}1

" Section; Introduction {{{1
" # Principles/Points
" * Keep it short and simple, stupid! (500step以下に留めたい)
" * To portable! (e.g. office/home, vim/gvim/vrapper, development/server)
" * デフォルト環境(サーバなど)での操作時に混乱するカスタマイズはしない(;と:の入れ替えとか)
" * execute コマンドをキーマッピングするとき <C-u> をつけること(e.g. nnoremap hoge :<C-u>fuga)
"   (誤って範囲指定しないようにするためなので、範囲指定してほしい場合はつけないこと) <http://d.hatena.ne.jp/e_v_e/20150101/1420067539>

" # References
" * [Vim で使える Ctrl を使うキーバインドまとめ - 反省はしても後悔はしない](http://cohama.hateblo.jp/entry/20121023/1351003586)
" * [Vimスクリプト基礎文法最速マスター - 永遠に未完成](http://d.hatena.ne.jp/thinca/20100201/1265009821)
" * [Big Sky :: モテる男のVim Script短期集中講座](http://mattn.kaoriya.net/software/vim/20111202085236.htm)

" # TODOs
" * TODO windows(kaoriya) だと <C-k> が dicwin にとられているっぽい -> 暫定対応として dicwin を単独で導入し、kaoriya ビルトインのほうを削除する
" }}}1

" Section; Begin {{{1
if has('gui_running')
	set encoding=utf-8 " inner encoding(before the scriptencoding)
endif
scriptencoding utf-8 " before multi byte

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif

augroup vimrc
	autocmd!
augroup END
" }}}1

" Section; Functions and Commands {{{1
function! s:capture_cmd_output(cmd) " command 実行結果をキャプチャ TODO 実行が遅い(silent で描画しないようにしても遅そう)
	if has('clipboard')
		redir @+>
	else
		redir @">
	endif
	execute a:cmd
	redir END
endfunction
command! -nargs=1 -complete=command Capture call <SID>capture_cmd_output(<q-args>)

function! s:formatXml() " caution: execute にする必要ないが vint で警告になってしまうため
	execute '%substitute/>\s*</>\r</ge' | filetype indent on | setfiletype xml | normal! gg=G
endfunction
command! -complete=command FormatXml call <SID>formatXml()

function! s:toggleTab()
	setlocal expandtab! | retab " caution: retab! は使わない(意図しない空白も置換されてしまうため)
	if ! &expandtab " <http://vim-jp.org/vim-users-jp/2010/04/30/Hack-143.html>
		execute '%substitute@^\v(%( {' . &tabstop . '})+)@\=repeat("\t", len(submatch(1))/' . &tabstop . ')@e' | normal! ``
	endif
endfunction
command! -complete=command ToggleTab call <SID>toggleTab()

function! s:has_plugin(plugin) " plugin が存在するか調べる
	return !empty(matchstr(&runtimepath, a:plugin))
endfunction

function! s:insertPrefix(str) range
	execute a:firstline . ',' . a:lastline . 'substitute/^/' . substitute(a:str, '/', '\\/', 'g')
endfunction
command! -range -nargs=1 -complete=command InsertPrefix <line1>,<line2>call <SID>insertPrefix(<f-args>)

function! s:insertSuffix(str) range
	execute a:firstline . ',' . a:lastline . 'substitute/$/' . substitute(a:str, '/', '\\/', 'g')
endfunction
command! -range -nargs=1 -complete=command InsertSuffix <line1>,<line2>call <SID>insertSuffix(<f-args>)

function! s:isHome()
	return $USER ==# 'oji'
endfunction

if ! has('kaoriya')
	command! -nargs=0 CdCurrent cd %:p:h
endif
" }}}1

" Section; Auto-commands {{{1
augroup vimrc
	" DoubleByteSpace highlight
	autocmd VimEnter,Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
	autocmd VimEnter,WinEnter * match DoubleByteSpace /　/
	autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
	if &encoding ==# 'utf-8' " windows の 非gvim 環境で spell ファイル関連のエラーとなってしまうため
		autocmd FileType markdown highlight! def link markdownItalic LineNr | setlocal spell
	endif
	" 改行時の自動コメント継続をやめる(o,Oコマンドでの改行時のみ)
	autocmd FileType * set textwidth=0 formatoptions-=o
	" QuickFixを自動で開く、QuickFix内<CR>で選択できるようにする
	autocmd QuickfixCmdPost make,grep,grepadd,vimgrep,helpgrep if len(getqflist()) != 0 | copen | endif | set modifiable nowrap
	" format json
	if executable('python')
		autocmd BufNewFile,BufRead *.json nnoremap <buffer> [space]j :%!python -m json.tool<CR>
		autocmd BufNewFile,BufRead *.json xnoremap <buffer> [space]j :!python -m json.tool<CR>
	endif
	" ansible plugin での設定だけだとたまにハードタブのままになっちゃうのでここで指定
	autocmd FileType yaml,ansible setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
augroup END
" }}}1

" Section; Options {{{1
set autoindent
set nobackup
set clipboard=unnamed,unnamedplus
set cmdheight=1
set diffopt+=vertical
set noexpandtab
set fileencodings=utf-8,ucs-bom,iso-2020-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,latin,latin1,utf-8
if has('folding')
	set foldlevelstart=0
	set foldmethod=marker
endif
set formatoptions-=o " フォーマットオプション(-oでo,Oコマンドでの改行時のコメント継続をなくす)
if has('win32') && executable('grep')
	set grepprg=grep\ -nH
endif
" if executable('pt')
"   set grepprg=pt\ --nogroup\ -iS
" endif
set helplang& helplang=en,ja " If true Vim master, use English help file. NeoBundle 'vim-jp/vimdoc-ja'. :h index or :h index@ja .
set hidden
set hlsearch
set ignorecase
set incsearch
if has('win32')
	set isfname-=: " gF 実行時に grep 結果を開きたい(ドライブレター含むファイルが開けなくなるかも)<http://saihoooooooo.hatenablog.com/entry/20111206/1323185728>
endif
set keywordprg=:help " Open Vim internal help by K command
set list
set listchars=tab:>.,trail:_,extends:\
set laststatus=2
set lazyredraw " マクロなどを実行中は描画を中断
set number
set nrformats="" " インクリメンタル/デクリメンタルを常に10進数として扱う
set scrolloff=5
set shiftwidth=4
set showtabline=1
set sidescrolloff=5
set smartcase
set smartindent
if s:isHome() && has('unix')
	set spellfile=~/Dropbox/spell/en.utf-8.add
elseif has('win32')
	set spellfile=D:/admin/Documents/spell/en.utf-8.add
endif
set splitbelow
set splitright
set spelllang+=cjk " スペルチェックで日本語は除外する
set tabstop=4
set textwidth=0 " 自動改行をなくす
set title
if has('persistent_undo')
	set noundofile
endif
set wildmenu
set nowrap
set nowrapscan
if has('win32')
	set noswapfile " swapfile作成有無(offにするとvimfilerでのネットワークフォルダ閲覧が高速化するかも(効果は不明))
endif
" }}}1

" Section; Let defines {{{1
let g:netrw_liststyle = 3 " netrwのデフォルト表示スタイル変更
let b:is_bash = 1 " shellのハイライトをbash基準にする
" }}}1

" Section; Key-mappings {{{1

" caution: <C-;> に <Esc> を割り当てたいがめんどいっぽい
" 今はデフォルトの <C-]> か <C-c> を使ってるけど押しづらい
" 前は <C-j> を 割り当ててたけど bash とかだと Enter 扱いでややこしいからやめた
" あとなにかの plugin で jk 同時押しで <Esc> も試したけど合わなかった(visual mode だとできないし、j のあとキー入力待ちになるの気持ちわるい)

" vimfilerと競合防ぐため[space]にわりあてている
map     <Space>  [space]
noremap [space]  <Nop>
noremap [space]h ^
noremap [space]l g_

noremap /  /\v
noremap ?  ?\v
noremap g/ /
noremap g? ?

map     [space]i       [insert]
noremap [insert]       <Nop>
noremap <silent><expr> [insert]p ':InsertPrefix<Space>' . input('prefix:') . '<CR>'
noremap <silent>       [insert]*  :InsertPrefix *<Space><CR>
noremap <silent>       [insert]1  :InsertPrefix #<Space><CR>A
noremap <silent>       [insert]2  :InsertPrefix ##<Space><CR>A
noremap <silent>       [insert]3  :InsertPrefix ###<Space><CR>A
noremap <silent>       [insert]4  :InsertPrefix ####<Space><CR>A
noremap <silent>       [insert]>  :InsertPrefix ><Space><CR>
noremap <silent>       [insert]T  :InsertPrefix TODO<Space><CR>
noremap <silent>       [insert]f  :InsertPrefix file://<Space><CR>
noremap <silent><expr> [insert]s ':InsertSuffix<Space>' . input('suffix:') . '<CR>'
noremap <silent><expr> [insert]d ':InsertSuffix<Space>' . strftime('\<Space>@%Y-%m-%d') . '<CR>'
noremap <silent><expr> [insert]t ':InsertSuffix<Space>' . strftime('\<Space>@%H:%M:%S') . '<CR>'
noremap <silent><expr> [insert]n ':InsertSuffix<Space>' . strftime('\<Space>@%Y-%m-%d %H:%M:%S') . '<CR>'
noremap <silent><expr> [insert]a ':InsertSuffix<Space>\<Space>@' . input('author:') . '<CR>'
noremap <silent>       [insert]l  :InsertSuffix \<Space>\<Space><CR>

nmap     [space]o [open]
nnoremap [open]   <Nop>
" caution: executeでなく<expr>だとvrapperから読み込んだときにエラーになる
" resolveしなくても開けるが、fugitiveで対象とするため
nnoremap [open]v  :<C-u>execute ':vsplit ' . resolve(expand($MYVIMRC))<CR>
if !s:isHome() && has('win32')
	nnoremap [open]i :<C-u>vsplit D:\admin\Documents\ipmsg.log<CR>
endif

" 検索結果ハイライトを解除。caution: [space][space]だと動かない。<Space><Space>だと vimfiler と競合
nnoremap [space]<Space> :nohlsearch<CR>
nnoremap [space]b       :bdelete<CR>
nnoremap [space]U       :update $MYVIMRC<Bar>:update $MYGVIMRC<Bar>:source $MYVIMRC<Bar>:source $MYGVIMRC<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap  <C-s> <C-w>s
" caution: ほんとはg<C-s>じゃなく<C-S-s>とかに割り当てたいが<C-s>と区別されない。やろうとするとめんどいっぽい
nnoremap g<C-s> <C-w>v
nnoremap  <C-c> <C-w>c

nnoremap <C-Left>  <C-w>H
nnoremap <C-Down>  <C-w>J
nnoremap <C-Up>    <C-w>K
nnoremap <C-Right> <C-w>L

" tab操作 caution: <TAB> == <C-i>
nnoremap <C-TAB>   gt
nnoremap <C-S-TAB> gT

nnoremap j  gj
nnoremap k  gk
nnoremap gj j
nnoremap gk k

nnoremap <CR> i<CR><Esc>
" D,Cと一貫性のある挙動に変更
nnoremap Y y$

" バッファ、ウィンドウ、タブ移動関連
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

" インサートモードでのキーマッピングを Emacs 風にする
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Del>
" TODO im_control が有効だと効かない(linux のみ)
inoremap <C-k> <C-o>D
" caution: 設定しないと im_control で日本語入力モードON の動きをしてしまう
inoremap <C-c> <Esc>

" コマンドラインモードでのキーマッピングをEmacs風にする
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Del>
cnoremap <C-k> <C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos()-2]<CR>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>

" ビジュアルモードでのヤンク後にカーソルを選択前の位置に戻さない(メソッド選択してコピペ時など)
vnoremap y y'>
" }}}1

" Section; Plug-ins {{{1
" Setup plug-in runtime path {{{
if isdirectory($HOME . '/.vim/bundle/neobundle.vim') " At home
	if has('vim_starting')
		set runtimepath+=~/.vim/bundle/neobundle.vim/
	endif
	call neobundle#begin(expand('~/.vim/bundle'))
	NeoBundle 'Arkham/vim-quickfixdo' " like argdo,bufdo.
	NeoBundle 'LeafCage/yankround.vim'
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
	NeoBundle 'TKNGUE/hateblo.vim' " entryの保存位置を指定できるためfork版を使用。本家へも PR でてるので、取り込まれたら見先を変える。本家は('moznion/hateblo.vim')
	NeoBundle 'assout/unite-todo'
	NeoBundle 'chase/vim-ansible-yaml'
	NeoBundle 'fuenor/im_control.vim' " TODO linux だと <C-o> の動きが変になる
	NeoBundle 'glidenote/memolist.vim'
	NeoBundle 'h1mesuke/textobj-wiw' " TODO windows/linuxで,wでのfowardが効かない(mappingはされてるっぽい)
	NeoBundle 'h1mesuke/vim-alignta'
	NeoBundle 'haya14busa/vim-migemo' " TODO windowsでmigemoれない
	NeoBundle 'kana/vim-operator-replace'
	NeoBundle 'kana/vim-operator-user'
	NeoBundle 'kana/vim-submode'
	NeoBundle 'kana/vim-textobj-entire'
	NeoBundle 'kana/vim-textobj-function'
	NeoBundle 'kana/vim-textobj-indent'
	NeoBundle 'kana/vim-textobj-line'
	NeoBundle 'kana/vim-textobj-user'
	NeoBundle 'kannokanno/previm'
	NeoBundle 'koron/codic-vim'
	NeoBundle 'koron/dicwin-vim'
	NeoBundle 'lambdalisue/vim-gista'
	NeoBundle 'mattn/emmet-vim' " markdown の url 形式取得にしか使ってない(<C-y>a)
	NeoBundle 'mattn/excitetranslate-vim'
	NeoBundle 'mattn/qiita-vim'
	NeoBundle 'mattn/vim-textobj-url'
	NeoBundle 'mattn/webapi-vim'
	NeoBundle 'pangloss/vim-javascript' " for indent only
	NeoBundle 'rhysd/vim-operator-surround' " life changing. sdb, sdf{char}.
	NeoBundle 'rhysd/vim-textobj-anyblock' " life changing. dib, dab.
	NeoBundle 'schickling/vim-bufonly'
	NeoBundle 'szw/vim-maximizer' " window の最大化・復元
	NeoBundle 'thinca/vim-qfreplace' " grep した結果を置換
	NeoBundle 'thinca/vim-quickrun'
	NeoBundle 'thinca/vim-ref'
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
	NeoBundle 'vim-scripts/DirDiff.vim' " TODO 文字化けする
	NeoBundle 'w0ng/vim-hybrid' " color scheme
	call neobundle#end()
	filetype plugin indent on " Required!
	NeoBundleCheck " Installation check.

elseif isdirectory($HOME . '/vimfiles/plugins') " At office
	let &runtimepath = &runtimepath . ',/vimfiles/plugins'
	for s:addingPath in split(glob($HOME . '/vimfiles/plugins/*'), '\n')
		if ! isdirectory(s:addingPath) || s:addingPath =~# '\~$'
			continue
		endif
		if s:addingPath =~# 'neocomplete' && ! has('lua') " work around. msysgitでvim起動時にエラーが出てしまうため
			continue
		endif
		let &runtimepath = &runtimepath . ',' . s:addingPath
	endfor
endif
" }}}

if s:has_plugin('alignta') " {{{
	xnoremap [space]a :Alignta<Space>
endif " }}}

if s:has_plugin('codic') " {{{
	nnoremap [space]c :<C-u>Codic<Space>
endif " }}}

if s:has_plugin('dicwin') " {{{
	let g:dicwin_mapleader = '[space]d'
	if has('win32') " ウィンドウ幅が広くなる問題対応 <http://saihoooooooo.hatenablog.com/entry/20120726/1343274932>
		let g:dicwin_dictpath = substitute($HOME, '\', '/', 'g') . '/vimfiles/dict/gene.txt'
	endif
endif " }}}

if s:has_plugin('excitetranslate') " {{{
	noremap [space]e :<C-u>ExciteTranslate<CR>
endif " }}}

if s:has_plugin('hateblo') " {{{
	" api_keyはvimrc.localから設定
	let g:hateblo_vim = {
				\ 'user': 'assout',
				\ 'api_key': g:hateblo_api_key,
				\ 'api_endpoint': 'https://blog.hatena.ne.jp/assout/assout.hatenablog.com/atom',
				\ 'WYSIWYG_mode': 0,
				\ 'always_yes': 0,
				\ 'edit_command': 'edit'
				\ }
	let g:hateblo_dir = '$HOME/.cache/hateblo/blog'

	nmap     [space]H   [hateblo]
	nnoremap [hateblo]  <Nop>
	nnoremap [hateblo]l :<C-u>HatebloList<CR>
	nnoremap [hateblo]c :<C-u>HatebloCreate<CR>
	nnoremap [hateblo]C :<C-u>HatebloCreateDraft<CR>
	nnoremap [hateblo]d :<C-u>HatebloDelete<CR>
	nnoremap [hateblo]u :<C-u>HatebloUpdate<CR>
endif " }}}

if s:has_plugin('im_control') " {{{
	if has('win32')
		let IM_CtrlMode = 4
	else
		let IM_CtrlMode = 1 " caution: 設定しなくても期待した挙動になるが
	endif
	if !has('gui_running')
		let IM_CtrlMode = 0
	endif
endif " }}}

if s:has_plugin('memolist') " {{{
	let g:memolist_memo_suffix = 'md'
	if s:isHome() && has('unix')
		let g:memolist_path = '~/Dropbox/memolist'
		let g:memolist_template_dir_path = '~/Dropbox/memolist'
	else
		let g:memolist_path = 'D:/admin/Documents/memolist'
		let g:memolist_template_dir_path = 'D:/admin/Documents/memolist'
	endif

	nmap     [space]m    [memolist]
	nnoremap [memolist]  <Nop>
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
	if has('lua')
		let g:neocomplete#enable_at_startup = 1
	endif
endif " }}}

if s:has_plugin('open-browser') " {{{
	if s:isHome() && has('unix') " gxでディレクトリをエクスプローラで開くことができなくなるためunixのみで有効
		let g:netrw_nogx = 1 " disable netrw's gx mapping
		nmap gx <Plug>(openbrowser-smart-search)
		vmap gx <Plug>(openbrowser-smart-search)
	endif
endif " }}}

if s:has_plugin('operator-camelize') " {{{
	map [space]C <Plug>(operator-camelize)
endif " }}}

if s:has_plugin('operator-replace') " {{{
	map [space]r <Plug>(operator-replace)
endif " }}}

if s:has_plugin('previm') " {{{
	nnoremap [space]p :<C-u>PrevimOpen<CR>
endif " }}}

if s:has_plugin('qiita-vim') " {{{
	nmap     [space]q    [Qiita]
	nnoremap [Qiita]     <Nop>
	nnoremap [Qiita]l    :<C-u>Unite qiita<CR>
	nnoremap [Qiita]<CR> :<C-u>Qiita<CR>
	nnoremap [Qiita]c    :<C-u>Qiita<CR>
	nnoremap [Qiita]e    :<C-u>Qiita -e<CR>
	nnoremap [Qiita]d    :<C-u>Qiita -d<CR>
endif " }}}

if s:has_plugin('quickrun') " {{{
	nnoremap [space]Q :<C-u>QuickRun<CR>
endif " }}}

if s:has_plugin('restart.vim') " {{{
	command! -bar RestartWithSession let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages' | Restart
endif " }}}

if s:has_plugin('singleton') && has('clientserver') && has('gui_running') " {{{
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
	let s:my_relative_move = {'description' : 'move after lcd', 'is_selectable' : 1, 'is_quit' : 0 }

	function! s:my_relative_move.func(candidates) " move 先を相対パスで指定する action
		let candidate = a:candidates[0]
		let l:dir = isdirectory(candidate.word) ? candidate.word : fnamemodify(candidate.word, ':p:h')
		execute g:unite_kind_cdable_lcd_command fnameescape(l:dir)
		call unite#take_action('move', a:candidates)
		call unite#force_redraw() " 呼ばないと表示更新されない(なぜ?)
	endfunction

	function! s:unite_my_keymappings()
		nnoremap <buffer><expr>         f unite#smart_map('f', unite#do_action('vimfiler'))
		nnoremap <buffer><expr>         v unite#smart_map('v', unite#do_action('vsplit'))
		nnoremap <buffer><expr>         m unite#smart_map('m', unite#do_action('relative_move'))
		" kind:directoryはdefaultでvimfilerにしているので下記設定は不要だが、kind:fileとかに対して実行するため
		nnoremap <buffer><expr>         x unite#smart_map('x', unite#do_action('start'))
		" vim-operator-surround の mapping と被るので nowait
		nnoremap <buffer><expr><nowait> s unite#smart_map('s', unite#do_action('split'))
		nunmap   <buffer>          <C-h>
		nunmap   <buffer>          <C-l>
		nunmap   <buffer>          <C-k>
		nmap     <buffer>         g<C-h> <Plug>(unite_delete_backward_path)
		nmap     <buffer>         g<C-l> <Plug>(unite_redraw)
		nmap     <buffer>         g<C-k> <Plug>(unite_print_candidate)
		" vim-submode の mapping と被るので nowait
		nmap     <buffer><nowait>  <C-w> <Plug>(unite_delete_backward_path)
	endfunction
	augroup vimrc
		autocmd FileType unite call s:unite_my_keymappings()
	augroup END

	call unite#custom#action('file,directory', 'relative_move', s:my_relative_move)
	call unite#custom#alias('file', 'delete', 'vimfiler__delete')
	call unite#custom#default_action('directory', 'vimfiler')
	call unite#custom#source('bookmark', 'sorters', ['sorter_ftime', 'sorter_reverse'])
	call unite#custom#source('file_rec', 'ignore_pattern', '(png\|gif\|jpeg\|jpg)$')
	call unite#custom#source('file_rec/async', 'ignore_pattern', '(png\|gif\|jpeg\|jpg)$')

	nmap     [space]u    [unite]
	nnoremap [unite]     <Nop>
	nnoremap [unite]<CR> :<C-u>Unite<CR>
	nnoremap [unite]b    :<C-u>Unite buffer -buffer-name=buffer<CR>
	nnoremap [unite]B    :<C-u>Unite bookmark -buffer-name=bookmark<CR>
	nnoremap [unite]d    :<C-u>Unite directory -buffer-name=directory<CR>
	nnoremap [unite]f    :<C-u>Unite file -buffer-name=file<CR>
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
	if s:has_plugin('yankround')
		nnoremap [unite]y :<C-u>Unite yankround -buffer-name=yankround<CR>
	else
		nnoremap [unite]y :<C-u>Unite history/yank -buffer-name=histry/yank<CR>
	endif

	if s:has_plugin('neomru') " {{{
		let g:neomru#directory_mru_limit = 100
		let g:neomru#do_validate = 0
		let g:neomru#file_mru_limit = 100
		let g:neomru#filename_format = ''

		nmap     [unite]n  [neomru]
		nnoremap [neomru]f :<C-u>Unite neomru/file -buffer-name=neomru/file<CR>
		nnoremap [neomru]d :<C-u>Unite neomru/directory -buffer-name=neomru/directory<CR>
	endif " }}}

	if s:has_plugin('unite-todo') " {{{
		let g:unite_todo_note_suffix = 'md'
		if s:isHome() && has('unix')
			let g:unite_todo_data_directory = '~/Dropbox'
		else
			let g:unite_todo_data_directory = 'D:/admin/Documents'
		endif

		function! s:todo_grep()
			let word = input('TodoGrep word: ')
			if empty(word) | return | endif
			execute ':vimgrep /' . l:word . '/ ' . g:unite_todo_data_directory . '/todo/note/*'
		endfunction

		map     [space]t         [unite-todo]
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

	nmap     [space]f       [vimfiler]
	nnoremap [vimfiler]     <Nop>
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

if s:has_plugin('vim-gista') " {{{
	let g:gista#update_on_write = 1
	nmap     [space]g    [gista]
	nnoremap [gista]     <Nop>
	nnoremap [gista]l    :<C-u>Unite gista<CR>
	nnoremap [gista]c    :<C-u>Gista<CR>
	nnoremap [gista]<CR> :<C-u>Gista<CR>
endif " }}}

if s:has_plugin('vim-maximizer') " {{{
	let g:maximizer_default_mapping_key = '<C-t>' " caution: eclipse のデフォルトショートカットにあわせ <C-m> に割り当てたいが <CR> と等価なので enter キー押下時も発動してしまう
endif " }}}

if s:has_plugin('vim-operator-surround') " {{{
	" refs <http://d.hatena.ne.jp/syngan/20140301/1393676442>
	" refs <http://www.todesking.com/blog/2014-10-11-surround-vim-to-operator-vim/>
	let g:operator#surround#blocks = deepcopy(g:operator#surround#default_blocks)
	" TODO <!-- -->の追加はできるが、削除もできるようにしたい(コメントのトグルがしたい)
	call add(g:operator#surround#blocks['-'], { 'block' : ['<!-- ', ' -->'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['c']} )

	map <silent> sa <Plug>(operator-surround-append)
	map <silent> sd <Plug>(operator-surround-delete)
	map <silent> sr <Plug>(operator-surround-replace)

	if s:has_plugin('vim-textobj-anyblock')
		nmap <silent>sab <Plug>(operator-surround-append)<Plug>(textobj-anyblock-a)
		nmap <silent>sdb <Plug>(operator-surround-delete)<Plug>(textobj-anyblock-a)
		nmap <silent>srb <Plug>(operator-surround-replace)<Plug>(textobj-anyblock-a)
	endif

	if s:has_plugin('vim-textobj-between')
		nmap <silent>saf <Plug>(operator-surround-append)<Plug>(textobj-between-a)
		nmap <silent>sdf <Plug>(operator-surround-delete)<Plug>(textobj-between-a)
		nmap <silent>srf <Plug>(operator-surround-replace)<Plug>(textobj-between-a)
	endif

	if s:has_plugin('vim-textobj-line')
		nmap <silent>sal <Plug>(operator-surround-append)<Plug>(textobj-line-a)
		nmap <silent>sdl <Plug>(operator-surround-delete)<Plug>(textobj-line-a)
		nmap <silent>srl <Plug>(operator-surround-replace)<Plug>(textobj-line-a)
	endif

	if s:has_plugin('vim-textobj-url')
		nmap <silent>sau <Plug>(operator-surround-append)<Plug>(textobj-url-a)
		" TODO no block matches to the region となる
		nmap <silent>sdu <Plug>(operator-surround-delete)<Plug>(textobj-url-a)
		" TODO apped の動きになってしまう
		nmap <silent>sru <Plug>(operator-surround-replace)<Plug>(textobj-url-a)
	endif
endif " }}}

if s:has_plugin('vim-ref') " {{{
	let g:ref_source_webdict_sites = {
				\ 'je'  : { 'url': 'http://dictionary.infoseek.ne.jp/jeword/%s', },
				\ 'ej'  : { 'url': 'http://dictionary.infoseek.ne.jp/ejword/%s', },
				\ 'wiki': { 'url': 'http://ja.wikipedia.org/wiki/%s', }, }
	let g:ref_source_webdict_sites.default = 'ej' " デフォルトサイト

	function! g:ref_source_webdict_sites.je.filter(output)
		return join(split(a:output, '\n')[15 :], '\n')
	endfunction
	function! g:ref_source_webdict_sites.ej.filter(output)
		return join(split(a:output, '\n')[15 :], '\n')
	endfunction
	function! g:ref_source_webdict_sites.wiki.filter(output)
		return join(split(a:output, '\n')[17 :], '\n')
	endfunction

	nmap     [space]R   [vim-ref]
	nnoremap [vim-ref]  <Nop>
	nnoremap [vim-ref]j :<C-u>Ref webdict je<Space>
	nnoremap [vim-ref]e :<C-u>Ref webdict ej<Space>
endif " }}}

if s:has_plugin('vim-submode') " {{{
	call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
	call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
	call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
	call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
	call submode#map('winsize', 'n', '', 'h', '<C-w><')
	call submode#map('winsize', 'n', '', 'l', '<C-w>>')
	call submode#map('winsize', 'n', '', 'k', '<C-w>-')
	call submode#map('winsize', 'n', '', 'j', '<C-w>+')

	call submode#enter_with('wrap-scroll', 'n', '', 'zh', 'zh')
	call submode#enter_with('wrap-scroll', 'n', '', 'zl', 'zl')
	call submode#enter_with('wrap-scroll', 'n', '', 'zH', 'zH')
	call submode#enter_with('wrap-scroll', 'n', '', 'zL', 'zL')
	call submode#map('wrap-scroll', 'n', '', 'h', 'zh')
	call submode#map('wrap-scroll', 'n', '', 'l', 'zl')
	call submode#map('wrap-scroll', 'n', '', 'H', '10zh')
	call submode#map('wrap-scroll', 'n', '', 'L', '10zl')

	call submode#enter_with('buffer-move', 'n', '', '[b', ':bprevious<CR>')
	call submode#enter_with('buffer-move', 'n', '', ']b', ':bnext<CR>')
	call submode#enter_with('buffer-move', 'n', '', '[B', ':bfirst<CR>')
	call submode#enter_with('buffer-move', 'n', '', ']B', ':blast<CR>')
	call submode#map('buffer-move', 'n', '', 'k', ':bprevious<CR>')
	call submode#map('buffer-move', 'n', '', 'j', ':bnext<CR>')
	call submode#map('buffer-move', 'n', '', 'K', ':bfirst<CR>')
	call submode#map('buffer-move', 'n', '', 'J', ':blast<CR>')

	call submode#enter_with('args-move', 'n', '', '[a', ':previous<CR>')
	call submode#enter_with('args-move', 'n', '', ']a', ':next<CR>')
	call submode#enter_with('args-move', 'n', '', '[A', ':first<CR>')
	call submode#enter_with('args-move', 'n', '', ']A', ':last<CR>')
	call submode#map('args-move', 'n', '', 'k', ':previous<CR>')
	call submode#map('args-move', 'n', '', 'j', ':next<CR>')
	call submode#map('args-move', 'n', '', 'K', ':first<CR>')
	call submode#map('args-move', 'n', '', 'J', ':last<CR>')

	call submode#enter_with('quickfix-move', 'n', '', '[q', ':cprevious<CR>')
	call submode#enter_with('quickfix-move', 'n', '', ']q', ':cnext<CR>')
	call submode#enter_with('quickfix-move', 'n', '', '[Q', ':cfirst<CR>')
	call submode#enter_with('quickfix-move', 'n', '', ']Q', ':clast<CR>')
	call submode#map('quickfix-move', 'n', '', 'k', ':cprevious<CR>')
	call submode#map('quickfix-move', 'n', '', 'j', ':cnext<CR>')
	call submode#map('quickfix-move', 'n', '', 'K', ':cfirst<CR>')
	call submode#map('quickfix-move', 'n', '', 'J', ':clast<CR>')

	call submode#enter_with('diff-move', 'n', '', '[c', '[c')
	call submode#enter_with('diff-move', 'n', '', ']c', ']c')
	call submode#map('diff-move', 'n', '', 'k', '[c')
	call submode#map('diff-move', 'n', '', 'j', ']c')
endif " }}}

if s:has_plugin('vim-textobj-entire') " {{{ TODO カーソル位置が戻らない(カーソル行は戻る)
	nmap yae yae``
	nmap yie yie``
	nmap =ae =ae``
	nmap =ie =ie``
endif " }}}

if s:has_plugin('vim-textobj-function') " {{{ TODO windowsで効かない(mappingはされてるっぽい)
	" text-obj-between用に f -> F に退避
	let g:textobj_function_no_default_key_mappings = 1
	omap iF <Plug>(textobj-function-i)
	omap aF <Plug>(textobj-function-a)
	vmap iF <Plug>(textobj-function-i)
	vmap aF <Plug>(textobj-function-a)
endif " }}}

if s:has_plugin('yankround') " {{{
	nmap p     <Plug>(yankround-p)
	nmap P     <Plug>(yankround-P)
	nmap <C-p> <Plug>(yankround-prev)
	nmap <C-n> <Plug>(yankround-next)
endif " }}}
" }}}1

" Section; Other Commands {{{1
filetype on
if (s:isHome() && has('unix')) || has('win32')
	colorscheme hybrid-light
else
	colorscheme peachpuff
endif
if 1 " :qで誤って終了してしまうのを防ぐためcloseに置き換える。なお Vrapper でエラーになるのでif文入れてる
	cabbrev q <C-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'close' : 'q')<CR>
endif
" }}}1

" vim:nofoldenable:
