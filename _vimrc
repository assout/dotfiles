" Index {{{1
" * Introduction
" * Begin
" * Functions and Commands
" * Auto-commands
" * Options
" * Let defines
" * Key-mappings
" * Plug-ins
" * After
" }}}1

" Section; Introduction {{{1
" # Principles/Points
" * Keep it short and simple, stupid! (500step以下に留めたい)
" * To portable! (e.g. office/home, vim/gvim/vrapper, development/server)
" * デフォルト環境(サーバなど)での操作時に混乱するカスタマイズはしない(;と:の入れ替えとか)
" * executeコマンドをキーマッピングするとき<C-u>をつけること(e.g. nnoremap hoge :<C-u>fuga)
"   (誤って範囲指定しないようにするためなので、範囲指定してほしい場合はつけないこと) <http://d.hatena.ne.jp/e_v_e/20150101/1420067539>
" * キーマッピングでは、スペースキーをプラグイン用、sキーをvim標準のプレフィックスとする

" # References
" * [Vimスクリプト基礎文法最速マスター - 永遠に未完成](http://d.hatena.ne.jp/thinca/20100201/1265009821)
" * [Big Sky :: モテる男のVim Script短期集中講座](http://mattn.kaoriya.net/software/vim/20111202085236.htm)
" * [Vimスクリプトリファレンス &mdash; 名無しのvim使い](http://nanasi.jp/code.html)
" * [Vimの極め方](http://whileimautomaton.net/2008/08/vimworkshop3-kana-presentation)
" * [Google Vimscript Style Guide](http://google-styleguide.googlecode.com/svn/trunk/vimscriptguide.xml)
" * [Google Vimscript Guide](http://google-styleguide.googlecode.com/svn/trunk/vimscriptfull.xml)
" * [Vim で使える Ctrl を使うキーバインドまとめ - 反省はしても後悔はしない](http://cohama.hateblo.jp/entry/20121023/1351003586)

" # TODOs
" * TODO たまにIMで変換候補確定後に先頭の一文字消えることがある @win
" * TODO このファイルのoutline見えるようにならないか(関数分割すればunite-outlineで見れそうだがやりすぎ)
" }}}1

" Section; Begin {{{1
set encoding=utf-8 " inner encoding(before the scriptencoding)
if has('win32')
	set termencoding=cp932
endif
scriptencoding utf-8 " before multi byte

if filereadable(expand('~/.vimrc.local'))
	source ~/.vimrc.local
endif
" }}}1

" Section; Functions and Commands {{{1
function! s:Capture(command) " command 実行結果をキャプチャ TODO 実行が遅い(silent で描画しないようにしても遅そう)
	" TODO オプションなどで buffer に出力もしたい
	if has('clipboard')
		redir @+>
	else
		redir @">
	endif
	execute a:command
	redir END
endfunction
command! -nargs=1 -complete=command Capture call <SID>Capture(<q-args>)

" TODO 未完（改行されなかった時のインデント範囲がおかしくなる）
" TODO コメント行はさむと以降のインデントベルが0になる
" TODO 未指定のときは範囲%扱いにしたい
function! s:FormatSGML() range " caution: executeにする必要ないがvintで警告になってしまうため
	" execute '%substitute/>\s*</>\r</ge' | filetype indent on | setfiletype xml | normal! gg=G

	execute 'normal!' . a:firstline . '=' . a:lastline
	execute a:firstline . ',' . a:lastline . 'substitute/>\s*</>\r</ge'
	filetype indent on
	setfiletype xml
	normal! `[=`]
endfunction
command! -range -complete=command FormatSGML <line1>,<line2>call <SID>FormatSGML()

function! s:ToggleTab() " TODO タブサイズも変更できるように(意外とめんどい)
	setlocal expandtab! | retab " caution: retab! は使わない(意図しない空白も置換されてしまうため)
	if ! &expandtab " <http://vim-jp.org/vim-users-jp/2010/04/30/Hack-143.html>
		execute '%substitute@^\v(%( {' . &tabstop . '})+)@\=repeat("\t", len(submatch(1))/' . &tabstop . ')@e' | normal! ``
	endif
endfunction
command! -complete=command ToggleTab call <SID>ToggleTab()

function! s:InsertString(pos, str) range
	execute a:firstline . ',' . a:lastline . 'substitute/' . a:pos . '/' . substitute(a:str, '/', '\\/', 'g')
endfunction
command! -range -nargs=1 -complete=command InsertPrefix <line1>,<line2>call <SID>InsertString('^', <f-args>)
command! -range -nargs=1 -complete=command InsertSuffix <line1>,<line2>call <SID>InsertString('$', <f-args>)

" TODO 超汚い。あとたまにバグる(カレントバッファがPreviewになってしまう)
function! s:DictionaryTranslate(...) " required gene.txt, kaoriya/dicwin.vimで良いが和英したいため
	let l:word = a:0 == 0 ? expand('<cword>') : a:1
	call histadd('cmd', 'DictionaryTranslate '  . l:word)
	if l:word ==# '' | return | endif
	" TODO relative path from home directory
	let l:gene_path = has('unix') ? '~/.vim/dict/gene.txt' : $HOME . '/vimfiles/dict/gene95/GENE.TXT'
	let l:jpn_to_eng = l:word !~? '^[a-z_]\+$'
	let l:output_option = l:jpn_to_eng ? '-B 1' : '-A 1' " 和英 or 英和

	silent pedit Translate\ Result | wincmd P | %delete " 前の結果が残っていることがあるため
	setlocal buftype=nofile noswapfile modifiable
	" TODO 日本語が-wオプションだとあまり取得できない -> 理想は完全一致->単語一致->部分一致の順にすべて表示する
	silent execute 'read !grep -ihw' l:output_option l:word l:gene_path
	silent 0delete

	" 完全一致したものを上部に移動
	let l:esc = @z
	let @z = ''
	while search('^' . l:word . '$', 'Wc') > 0
		silent execute line('.') - l:jpn_to_eng . 'delete Z 2'
	endwhile
	silent 0put z
	let @z = l:esc
	silent call append(line('.'), '==')
	silent 1delete
	silent wincmd p
endfunction
command! -nargs=? -complete=command DictionaryTranslate call <SID>DictionaryTranslate(<f-args>)

function! s:IsPluginEnabled() " pluginが有効か返す
	return has('unix') ? isdirectory($HOME . '/.vim/bundle') : isdirectory($HOME . '/vimfiles/plugins')
endfunction

function! s:HasPlugin(plugin) " pluginが存在するか返す
	return !empty(matchstr(&runtimepath, a:plugin))
endfunction

function! s:RestoreCursorPosition()
	let ignore_filetypes = ['gitcommit']
	if index(ignore_filetypes, &l:filetype) >= 0
		return
	endif

	if line("'\"") > 1 && line("'\"") <= line('$')
		execute 'normal! g`"'
	endif
endfunction

command! -bang BufClear %bdelete<bang>
command! -bang BClear   BufClear<bang>
" }}}1

" Section; Auto-commands {{{1
augroup vimrc
	autocmd!
	" double byte space highlight
	autocmd VimEnter,Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
	autocmd VimEnter,WinEnter * match DoubleByteSpace /　/
	" set markdown filetype
	autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
	" enabe spell on markdown file
	if &termencoding ==# 'utf-8' || has('gui_running')
		autocmd FileType markdown highlight! def link markdownItalic LineNr | setlocal spell
	endif
	" 改行時の自動コメント継続をやめる(o,Oコマンドでの改行時のみ)
	autocmd FileType * set textwidth=0 formatoptions-=o
	" QuickFixを自動で開く、QuickFix内<CR>で選択できるようにする
	autocmd QuickfixCmdPost make,grep,grepadd,vimgrep,helpgrep if len(getqflist()) != 0 | copen | endif | set modifiable nowrap
	if executable('python')
		autocmd BufNewFile,BufRead *.json command! -range=% -complete=command -buffer FormatJSON <line1>,<line2>!python -m json.tool
	endif
	" ansible plugin での設定だけだとたまにハードタブのままになっちゃうのでここで指定
	autocmd FileType yaml,ansible setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
	" restore cursor position
	autocmd BufReadPost * call s:RestoreCursorPosition()
augroup END
" }}}1

" Section; Options {{{1
" TODO 行末に行コメント入れるとvrapperで解釈されない。workaroundとしてコメントは別行に書く
set autoindent
set nobackup
set clipboard=unnamed,unnamedplus
set cmdheight=1
if has('patch-7.4.399')
	set cryptmethod=blowfish2
endif
set diffopt& diffopt+=vertical
set noexpandtab
set fileencodings=utf-8,ucs-bom,iso-2020-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,latin,latin1,utf-8
if has('folding')
	set foldlevelstart=0
	set foldmethod=marker
endif
" フォーマットオプション(-oでo,Oコマンドでの改行時のコメント継続をなくす)
set formatoptions& formatoptions-=o
if executable('grep')
	set grepprg=grep\ -nH
endif
" if executable('pt')
"   set grepprg=pt\ --nogroup\ -iS
" endif
" If true Vim master, use English help file. NeoBundle 'vim-jp/vimdoc-ja'. :h index or :h index@ja .
set helplang=en,ja
set hidden
set history=200
set hlsearch
set ignorecase
set incsearch
set iskeyword& iskeyword-=_
" Open Vim internal help by K command
set keywordprg=:help
set list
set listchars=tab:>.,trail:_,extends:\
set laststatus=2
" マクロなどを実行中は描画を中断
set lazyredraw
set number
" インクリメンタル/デクリメンタルを常に10進数として扱う
set nrformats=""
set scrolloff=5
" caution: 0 だと tabstop の値が使われるが vim version によって指定不可なので tabstop と同じ値を直接指定
set shiftwidth=4
set showcmd
set showtabline=1
set sidescrolloff=5
set smartcase
set smartindent
if has('unix')
	set spellfile=~/Dropbox/spell/en.utf-8.add
else
	set spellfile=D:/admin/Documents/spell/en.utf-8.add
endif
set splitbelow
set splitright
" スペルチェックで日本語は除外する
set spelllang& spelllang+=cjk
set tags& tags+=.git/tags
set tabstop=4
" 自動改行をなくす
set textwidth=0
set title
if has('persistent_undo')
	set noundofile
endif
set wildmenu
set nowrap
set nowrapscan
if has('win32')
	" swapfile作成有無(offにするとvimfilerでのネットワークフォルダ閲覧が高速化するかも(効果は不明))
	set noswapfile
endif
" }}}1

" Section; Let defines {{{1
let g:netrw_liststyle = 3 " netrwのデフォルト表示スタイル変更
let b:is_bash = 1 " shellのハイライトをbash基準にする
" }}}1

" Section; Key-mappings {{{1

" caution: 前は<C-j>を<Esc>に割り当ててたけどbashとかだとEnter扱いでややこしいからやめた
" あとなにかのpluginでjk同時押しも試したけど合わなかった(visual modeだとできないし、jのあとキー入力待ちになるの気持ちわるい)

" Normal,Visual mode basic mappings {{{
noremap  /    /\v
noremap  ?    ?\v
nnoremap j    gj
nnoremap k    gk
nnoremap gj   j
nnoremap gk   k
nnoremap Y    y$
nnoremap <CR> i<CR><Esc>
" ビジュアルモードでのヤンク後にカーソルを選択前の位置に戻さない(メソッド選択してコピペ時など)
vnoremap y    y'>
" }}}

" Shortcut key prefix mappings {{{

" [shourtcut]a,d,rはsurround-pluginで使用
map      s           [shortcut]
map      [shortcut]  <Nop>
noremap  [shortcut]? ?
noremap  [shortcut]/ /
map      [shortcut]a <Nop>
nnoremap [shortcut]b :bdelete<CR>
map      [shortcut]d <Nop>
noremap  [shortcut]h ^
map      [shortcut]i [insert]
noremap  [shortcut]j 10j
noremap  [shortcut]k 10k
noremap  [shortcut]l g_
nnoremap [shortcut]n :nohlsearch<CR>
nmap     [shortcut]o [open]
map      [shortcut]r <Nop>
nnoremap [shortcut]t :<C-u>DictionaryTranslate<CR>
nnoremap [shortcut]u :update $MYVIMRC<Bar>:update $MYGVIMRC<Bar>:source $MYVIMRC<Bar>:source $MYGVIMRC<CR>
noremap  [shortcut]v :vsplit<CR>

" TODO to plugin
noremap [insert]       <Nop>
noremap <silent><expr> [insert]p ':InsertPrefix ' . input('prefix:') . '<CR>'
noremap <silent>       [insert]*  :InsertPrefix * <CR>
noremap <silent>       [insert]1  :InsertPrefix # <CR>A
noremap <silent>       [insert]2  :InsertPrefix ## <CR>A
noremap <silent>       [insert]3  :InsertPrefix ### <CR>A
noremap <silent>       [insert]4  :InsertPrefix #### <CR>A
noremap <silent>       [insert]>  :InsertPrefix > <CR>
noremap <silent>       [insert]T  :InsertPrefix TODO <CR>
noremap <silent>       [insert]f  :InsertPrefix file://<CR>
noremap <silent><expr> [insert]s ':InsertSuffix ' . input('suffix:') . '<CR>'
noremap <silent><expr> [insert]d ':InsertSuffix ' . strftime('\ @%Y-%m-%d') . '<CR>'
noremap <silent><expr> [insert]t ':InsertSuffix ' . strftime('\ @%H:%M:%S') . '<CR>'
noremap <silent><expr> [insert]n ':InsertSuffix ' . strftime('\ @%Y-%m-%d %H:%M:%S') . '<CR>'
noremap <silent><expr> [insert]a ':InsertSuffix \ @' . input('author:') . '<CR>'
noremap <silent>       [insert]l  :InsertSuffix \<Space>\ <CR>

nnoremap [open]         <Nop>
" resolveしなくても開けるがfugitiveで対象とするため
" caution: <silent>つけないで<expr>だけだとvrapperが有効にならない
nnoremap <silent><expr> [open]v  ':<C-u>edit ' . resolve(expand($MYVIMRC)) . '<CR>'
if has('win32')
	nnoremap [open]i :<C-u>edit D:\admin\Documents\ipmsg.log<CR>
endif
" }}}

" Ctrl-key prefix mappings {{{
nnoremap <C-h>     <C-w>h
nnoremap <C-j>     <C-w>j
nnoremap <C-k>     <C-w>k
nnoremap <C-l>     <C-w>l
nnoremap <C-Left>  <C-w>H
nnoremap <C-Down>  <C-w>J
nnoremap <C-Up>    <C-w>K
nnoremap <C-Right> <C-w>L

" caution: ほんとは<C-w>vを<C-S-s>とかに割り当てたいが<C-s>と区別されない。やろうとするとめんどいっぽい。
nnoremap <C-c> <C-w>c
nnoremap <C-z> <C-w>z

" tab操作 caution: <TAB> == <C-i>
nnoremap <C-TAB>   gt
nnoremap <C-S-TAB> gT

" Use ':tjump' instead of ':tag'.
nnoremap <C-]> g<C-]>
" }}}

" []key prefix mappings {{{ TODO plugin用プレフィックスと被ると待たされる
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
nnoremap [g :tbprevious<CR>
nnoremap ]g :tnext<CR>
nnoremap [G :tfirst<CR>
nnoremap ]G :tlast<CR>
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
" }}}

" Insert mode mappings {{{
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Del>
" TODO im_control plug-in が有効だと効かない(linux のみ)
inoremap <C-k> <C-o>D
" caution: <C-]>に慣れるため無効化。Escapeとして使用したくなったときはim_controlで日本語入力モードONの動きをしてしまうので<Esc>にmappingすること。
inoremap <C-c> <Nop>
" }}}

" Command-line mode mappings {{{
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
" caution: <C-]>に慣れるため無効化 TODO コマンドの中断ができなくなる?
cnoremap <C-c> <Nop>
" }}}1

" Section; Plug-ins {{{1
if isdirectory($HOME . '/.vim/bundle/neobundle.vim') " At home
	if has('vim_starting')
		set runtimepath+=~/.vim/bundle/neobundle.vim/
	endif
	call neobundle#begin(expand('~/.vim/bundle'))

	NeoBundle 'Arkham/vim-quickfixdo' " like argdo, bufdo.
	NeoBundle 'Jagua/vim-ref-gene', {'depends' : ['thinca/vim-ref', 'Shougo/unite.vim']}
	NeoBundle 'LeafCage/vimhelpgenerator'
	NeoBundle 'LeafCage/yankround.vim', {'depends' : ['Shougo/unite.vim']}
	NeoBundle 'Shougo/neobundle.vim', {'depends' : ['Shougo/vimproc', 'Shougo/unite.vim']}
	NeoBundle 'Shougo/neocomplete', {'disabled' : !has('lua')}
	NeoBundle 'Shougo/neomru.vim', {'depends' : ['Shougo/unite.vim']}
	NeoBundle 'Shougo/unite-outline', {'depends' : ['Shougo/unite.vim']}
	NeoBundle 'Shougo/unite.vim', {'depends' : ['Shougo/vimproc']}
	NeoBundle 'Shougo/vimfiler.vim', {'depends' : ['Shougo/unite.vim']}
	NeoBundle 'Shougo/vimproc', { 'build' : { 'windows' : 'make -f make_mingw32.mak', 'cygwin' : 'make -f make_cygwin.mak', 'mac' : 'make -f make_mac.mak', 'unix' : 'make -f make_unix.mak', }, }
	NeoBundle 'TKNGUE/hateblo.vim', {'depends' : ['mattn/webapi-vim', 'Shougo/unite.vim']} " entryの保存位置を指定できるためfork版を使用。本家へもPRでてるので、取り込まれたら見先を変える。本家は('moznion/hateblo.vim')
	NeoBundle 'assout/unite-todo', {'depends' : ['Shougo/unite.vim']}
	NeoBundle 'chase/vim-ansible-yaml'
	NeoBundle 'fuenor/im_control.vim' " TODO linuxだと<C-o>の動きが変になる
	NeoBundle 'glidenote/memolist.vim', {'depends' : ['Shougo/unite.vim']}
	NeoBundle 'gregsexton/VimCalc', {'disabled' : !executable('python')}
	NeoBundle 'h1mesuke/vim-alignta', {'depends' : ['Shougo/unite.vim']}
	NeoBundle 'haya14busa/vim-migemo', {'disabled' : !executable('cmigemo')}
	NeoBundle 'itchyny/calendar.vim'
	NeoBundle 'kana/vim-gf-user'
	NeoBundle 'kana/vim-submode'
	NeoBundle 'kannokanno/previm', {'depends' : ['tyru/open-browser.vim']}
	NeoBundle 'koron/codic-vim' " TODO vimprocなどで非同期化されてる？
	NeoBundle 'lambdalisue/vim-gista', {'depends': ['Shougo/unite.vim', 'tyru/open-browser.vim']}
	NeoBundle 'mattn/emmet-vim' " markdownのurl 形式取得にしか使ってない(<C-y>a)
	NeoBundle 'mattn/excitetranslate-vim', {'depends': ['mattn/webapi-vim']}
	NeoBundle 'mattn/qiita-vim', {'depends' : ['Shougo/unite.vim']}
	NeoBundle 'mattn/webapi-vim'
	NeoBundle 'pangloss/vim-javascript' " for indent only
	NeoBundle 'rhysd/unite-codic.vim', {'depends': ['Shougo/unite.vim', 'koron/codic-vim']}
	NeoBundle 'schickling/vim-bufonly'
	NeoBundle 'szw/vim-maximizer' " windowの最大化・復元
	NeoBundle 'szw/vim-tags', {'disabled' : !executable('ctags')}
	NeoBundle 'thinca/vim-localrc'
	NeoBundle 'thinca/vim-qfreplace' " grepした結果を置換
	NeoBundle 'thinca/vim-quickrun'
	NeoBundle 'thinca/vim-ref'
	NeoBundle 'thinca/vim-singleton', {'disabled' : !has('clientserver')}
	NeoBundle 'tomtom/tcomment_vim'
	NeoBundle 'tpope/vim-fugitive', {'disabled' : !executable('git')}
	NeoBundle 'tyru/open-browser.vim'
	NeoBundle 'tyru/restart.vim'
	NeoBundle 'vim-jp/vimdoc-ja'
	NeoBundle 'vim-scripts/DirDiff.vim' " TODO 文字化けする
	NeoBundle 'w0ng/vim-hybrid' " color scheme

	" operator {{{
	NeoBundle 'kana/vim-operator-user'
	NeoBundle 'kana/vim-operator-replace', {'depends': ['kana/vim-operator-user']}
	NeoBundle 'rhysd/vim-operator-surround', {'depends': ['kana/vim-operator-user']} " life changing. sdb, sdf{char}.
	NeoBundle 'syngan/vim-operator-inserttext', {'depends': ['kana/vim-operator-user']}
	NeoBundle 'tyru/operator-camelize.vim', {'depends': ['kana/vim-operator-user']}
	" }}}

	" textobj {{{
	NeoBundle 'kana/vim-textobj-user'
	NeoBundle "sgur/vim-textobj-parameter", {'depends': ['kana/vim-textobj-user']}
	NeoBundle 'kana/vim-textobj-entire', {'depends': ['kana/vim-textobj-user']}
	NeoBundle 'kana/vim-textobj-function', {'depends': ['kana/vim-textobj-user']} " caution: windows(非neobundle)でafter/ftpluginが読み込まれないっぽいので Section; Plug-ins でruntimepath強引に登録している
	NeoBundle 'kana/vim-textobj-indent', {'depends': ['kana/vim-textobj-user']}
	NeoBundle 'kana/vim-textobj-line', {'depends': ['kana/vim-textobj-user']}
	NeoBundle 'mattn/vim-textobj-url', {'depends': ['kana/vim-textobj-user']}
	NeoBundle 'rhysd/vim-textobj-anyblock', {'depends': ['kana/vim-textobj-user']} " life changing. dib, dab.
	NeoBundle 'thinca/vim-textobj-between', {'depends': ['kana/vim-textobj-user']} " life changing. dif{char}, daf{char}
	NeoBundle 'thinca/vim-textobj-comment', {'depends': ['kana/vim-textobj-user']}
	" }}}

	call neobundle#end()
	filetype plugin indent on " Required!
	NeoBundleCheck " Installation check.

elseif isdirectory($HOME . '/vimfiles/plugins') " At office
	if has('vim_starting')
		set runtimepath+=',/vimfiles/plugins'
		for s:addingPath in split(expand(glob($HOME . '/vimfiles/plugins/*'), glob($HOME . '/vimfiles/plugins/*/after')), '\n')
			if ! isdirectory(s:addingPath) || s:addingPath =~# '\~$' | continue | endif
			if s:addingPath =~# 'neocomplete' && ! has('lua') | continue | endif " workaround. msysgitでvim起動時にエラーが出てしまうため
			let &runtimepath = &runtimepath . ',' . s:addingPath
		endfor
	endif
endif

" plugin prefix mappings {{{
if s:IsPluginEnabled()
	" vimfilerなどpluginと競合防ぐため[plugin]にわりあてている
	map  <Space>   [plugin]
	map  [plugin]  <Nop>
	xmap [plugin]a [alignta]
	map  [plugin]c [camelize]
	nmap [plugin]e [excite]
	nmap [plugin]f [fugitive]
	nmap [plugin]g [gista]
	nmap [plugin]h [hateblo]
	nmap [plugin]m [memolist]
	nmap [plugin]p [previm]
	nmap [plugin]q [qiita]
	nmap [plugin]Q [quickrun]
	nmap [plugin]r [ref]
	nmap [plugin]s [sub]
	map  [plugin]t [todo]
	nmap [plugin]u [unite]
	nmap [plugin]/ [migemo]

	map  R           [replace]
	nmap p           [yankround]
	nmap P           [Yankround]
	map  [shortcut]a [surround-a]
	map  [shortcut]d [surround-d]
	map  [shortcut]r [surround-r]
endif
" }}}

if s:HasPlugin('alignta') " {{{
	xnoremap [alignta]a :Alignta<Space>
	" 空白区切りの要素を整列(e.g. nmap hoge fuga)(最初の2要素のみ)(コメント行は除く)
	xnoremap [alignta]b :Alignta<Space>v/^" <<0 \s\S/2
endif " }}}

if s:HasPlugin('calendar.vim') " {{{
	let g:calendar_google_calendar = has('unix') ? 1 : 0
	let g:calendar_google_task = has('unix') ? 1 : 0
endif " }}}

if s:HasPlugin('excitetranslate') " {{{
	noremap [excite] :<C-u>ExciteTranslate<CR>
endif " }}}

if s:HasPlugin('fugitive') " {{{ TODO fugitive が有効なときのみマッピングしたい
	nnoremap [fugitive]c :Gcommit -m ""<Left>
	nnoremap [fugitive]d :Gdiff<CR>
	nnoremap [fugitive]p :Git push<CR>
endif " }}}

if s:HasPlugin('hateblo') " {{{
	let g:hateblo_vim = {
				\ 'user': 'assout',
				\ 'api_key': g:hateblo_api_key,
				\ 'api_endpoint': 'https://blog.hatena.ne.jp/assout/assout.hatenablog.com/atom',
				\ 'WYSIWYG_mode': 0,
				\ 'always_yes': 0,
				\ 'edit_command': 'edit'
				\ } " api_keyはvimrc.localから設定
	let g:hateblo_dir = '$HOME/.cache/hateblo/blog'

	nnoremap [hateblo]  <Nop>
	nnoremap [hateblo]l :<C-u>HatebloList<CR>
	nnoremap [hateblo]c :<C-u>HatebloCreate<CR>
	nnoremap [hateblo]C :<C-u>HatebloCreateDraft<CR>
	nnoremap [hateblo]d :<C-u>HatebloDelete<CR>
	nnoremap [hateblo]u :<C-u>HatebloUpdate<CR>
endif " }}}

if s:HasPlugin('hybrid') " {{{
	colorscheme hybrid-light
endif " }}}

if s:HasPlugin('im_control') " {{{
	let g:IM_CtrlMode = has('unix') ? 1 : 4 " caution: linuxのときは設定しなくても期待した挙動になるけど一応
	if !has('gui_running')
		let g:IM_CtrlMode = 0
	endif
endif " }}}

if has('kaoriya') " {{{
	let g:plugin_hz_ja_disable = 1 " hz_ja plugin無効
	let g:plugin_dicwin_disable = 1 " dicwin plugin無効
else
	command! -nargs=0 CdCurrent cd %:p:h
endif " }}}

if s:HasPlugin('memolist') " {{{
	let g:memolist_memo_suffix = 'md'
	let g:memolist_path = has('unix') ? '~/Dropbox/memolist' : 'D:/admin/Documents/memolist'
	let g:memolist_template_dir_path = g:memolist_path

	nnoremap [memolist]  <Nop>
	nnoremap [memolist]a :<C-u>MemoNew<CR>
	nnoremap [memolist]g :<C-u>MemoGrep<CR>

	if s:HasPlugin('unite')
		let g:unite_source_alias_aliases = { 'memolist' : { 'source' : 'file', 'args' : g:memolist_path } }
		call unite#custom_source('memolist', 'sorters', ['sorter_ftime', 'sorter_reverse'])
		call unite#custom_source('memolist', 'matchers', ['converter_tail_abbr', 'matcher_default'])
		nnoremap [memolist]l :<C-u>Unite memolist -buffer-name=memolist<CR>
	else
		nnoremap [memolist]l :<C-u>MemoList<CR>
	endif
endif " }}}

if s:HasPlugin('neocomplete') " {{{
	let g:neocomplete#enable_at_startup = has('lua') && has('unix') ? 1 : 0 " 基本は開発時のみ必要なので
endif " }}}

if s:HasPlugin('open-browser') " {{{
	if has('unix') " gxでディレクトリをエクスプローラで開くことができなくなるためunixのみで有効
		let g:netrw_nogx = 1 " disable netrw's gx mapping
		nmap gx <Plug>(openbrowser-smart-search)
		vmap gx <Plug>(openbrowser-smart-search)
	endif
endif " }}}

if s:HasPlugin('operator-camelize') " {{{
	map [camelize] <Plug>(operator-camelize-toggle)
endif " }}}

if s:HasPlugin('operator-replace') " {{{
	map [replace] <Plug>(operator-replace)
endif " }}}

if s:HasPlugin('previm') " {{{
	nnoremap [previm] :<C-u>PrevimOpen<CR>
endif " }}}

if s:HasPlugin('qiita-vim') " {{{
	nnoremap [qiita]     <Nop>
	nnoremap [qiita]l    :<C-u>Unite qiita<CR>
	nnoremap [qiita]<CR> :<C-u>Qiita<CR>
	nnoremap [qiita]c    :<C-u>Qiita<CR>
	nnoremap [qiita]e    :<C-u>Qiita -e<CR>
	nnoremap [qiita]d    :<C-u>Qiita -d<CR>
endif " }}}

if s:HasPlugin('quickrun') " {{{
	nnoremap [quickrun] :<C-u>QuickRun<CR>
endif " }}}

if s:HasPlugin('restart.vim') " {{{
	command! -bar RestartWithSession let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages' | Restart
endif " }}}

if s:HasPlugin('singleton') && has('gui_running') " {{{
	let g:singleton#opener = 'vsplit'
	call singleton#enable()
endif " }}}

if s:HasPlugin('tcomment_vim') " {{{
	let g:tcommentTextObjectInlineComment = 'iC'
	call tcomment#DefineType('java', '// %s')
endif " }}}

if s:HasPlugin('unite') " {{{
	let g:unite_enable_ignore_case = 1
	let g:unite_enable_smart_case = 1
	let g:unite_source_grep_max_candidates = 200
	let s:my_relative_move = {'description' : 'move after lcd', 'is_selectable' : 1, 'is_quit' : 0 }

	function! s:my_relative_move.func(candidates) " move先を相対パスで指定するaction
		let l:candidate = a:candidates[0]
		let l:dir = isdirectory(l:candidate.word) ? l:candidate.word : fnamemodify(l:candidate.word, ':p:h')
		execute g:unite_kind_cdable_lcd_command fnameescape(l:dir)
		call unite#take_action('move', a:candidates)
		call unite#force_redraw() " 呼ばないと表示更新されない
	endfunction

	function! s:unite_my_keymappings()
		nnoremap <buffer><expr>         f unite#smart_map('f', unite#do_action('vimfiler'))
		nnoremap <buffer><expr>         m unite#smart_map('m', unite#do_action('relative_move'))
		nnoremap <buffer><expr>         v unite#smart_map('v', unite#do_action('vsplit'))
		nnoremap <buffer><expr>         x unite#smart_map('x', unite#do_action('start'))
		nnoremap <buffer><expr><nowait> s unite#smart_map('s', unite#do_action('split'))
		nunmap   <buffer>  <C-h>
		nunmap   <buffer>  <C-l>
		nunmap   <buffer>  <C-k>
		nmap     <buffer> g<C-h> <Plug>(unite_delete_backward_path)
		nmap     <buffer> g<C-l> <Plug>(unite_redraw)
		nmap     <buffer> g<C-k> <Plug>(unite_print_candidate)
		nmap     <buffer>  <C-w> <Plug>(unite_delete_backward_path)
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
	if has('win32') " windowsではよく日本語使うので
		call unite#filters#matcher_default#use(['matcher_migemo'])
	endif

	nnoremap [unite]     <Nop>
	nnoremap [unite]<CR> :<C-u>Unite<CR>
	nnoremap [unite]b    :<C-u>Unite buffer -buffer-name=buffer<CR>
	nnoremap [unite]B    :<C-u>Unite bookmark -buffer-name=bookmark<CR>
	nnoremap [unite]d    :<C-u>Unite directory -buffer-name=directory<CR>
	nnoremap [unite]f    :<C-u>Unite file -buffer-name=file<CR>
	nnoremap [unite]g    :<C-u>Unite grep -buffer-name=grep -no-empty<CR>
	nnoremap [unite]m    :<C-u>Unite mapping -buffer-name=mapping<CR>
	nnoremap [unite]o    :<C-u>Unite outline -buffer-name=outline -no-quit -vertical -winwidth=30 -direction=botright<CR>
	nnoremap [unite]r    :<C-u>Unite resume -buffer-name=resume<CR>
	nnoremap [unite]R    :<C-u>Unite register -buffer-name=register<CR>
	nnoremap [unite]s    :<C-u>Unite find -buffer-name=find<CR>
	nnoremap [unite]t    :<C-u>Unite tab -buffer-name=tab<CR>
	nnoremap [unite]w    :<C-u>Unite window -buffer-name=window<CR>
	if has('unix')
		nnoremap [unite]D :<C-u>Unite directory_rec/async -buffer-name=directory_rec/async<CR>
		nnoremap [unite]F :<C-u>Unite file_rec/async -buffer-name=file_rec/async<CR>
	else
		nnoremap [unite]D :<C-u>Unite directory_rec -buffer-name=directory_rec<CR>
		nnoremap [unite]F :<C-u>Unite file_rec -buffer-name=file_rec<CR>
	endif
	if s:HasPlugin('yankround')
		nnoremap [unite]y :<C-u>Unite yankround -buffer-name=yankround<CR>
	else
		nnoremap [unite]y :<C-u>Unite history/yank -buffer-name=histry/yank<CR>
	endif

	if s:HasPlugin('neomru') " {{{
		let g:neomru#directory_mru_limit = 200
		let g:neomru#do_validate = 0
		let g:neomru#file_mru_limit = 200
		let g:neomru#filename_format = ''

		nmap     [unite]n  [neomru]
		nnoremap [neomru]f :<C-u>Unite neomru/file -buffer-name=neomru/file<CR>
		nnoremap [neomru]d :<C-u>Unite neomru/directory -buffer-name=neomru/directory<CR>
	endif " }}}

	if s:HasPlugin('unite-codic') " {{{
		nnoremap <expr> [unite]c ':<C-u>Unite codic -vertical -winwidth=30 -direction=botright -input=' . expand('<cword>') . '<CR>'
		nnoremap        [unite]C  :<C-u>Unite codic -vertical -winwidth=30 -direction=botright -start-insert<CR>
	endif " }}}

	if s:HasPlugin('unite-todo') " {{{
		let g:unite_todo_note_suffix = 'md'
		let g:unite_todo_data_directory = has('unix') ? '~/Dropbox' : 'D:/admin/Documents'

		noremap  [todo]     <Nop>
		noremap  [todo]<CR> :UniteTodoAddSimple -tag -memo<CR>
		noremap  [todo]a    :UniteTodoAddSimple<CR>
		noremap  [todo]t    :UniteTodoAddSimple -tag<CR>
		noremap  [todo]m    :UniteTodoAddSimple -memo<CR>
		nnoremap [todo]l    :Unite todo:undone -buffer-name=todo<CR>
		nnoremap [todo]L    :Unite todo -buffer-name=todo<CR>
		" TODO change to external grep
		nnoremap <expr> [todo]g ':vimgrep /' . input('TodoGrep word: ') . '/ ' . g:unite_todo_data_directory . '/todo/note/*<CR>'
	endif " }}}
endif " }}}

if s:HasPlugin('vimfiler') " {{{
	let g:vimfiler_safe_mode_by_default = 0 " This variable controls vimfiler enter safe mode by default.
	let g:vimfiler_as_default_explorer = 1 " If this variable is true, Vim use vimfiler as file manager instead of |netrw|.
endif " }}}

if s:HasPlugin('vim-ansible-yaml') " {{{
	let g:ansible_options = {'ignore_blank_lines': 1}
endif " }}}

if s:HasPlugin('vim-gf-user') " {{{
	function! GfFile() " refs <http://d.hatena.ne.jp/thinca/20140324/1395590910>
		let path = expand('<cfile>')
		let line = 0
		if path =~# ':\d\+:\?$'
			let line = matchstr(path, '\d\+:\?$')
			let path = matchstr(path, '.*\ze:\d\+:\?$')
		endif
		if !filereadable(path)
			return 0
		endif
		return { 'path': path, 'line': line, 'col': 0, }
	endfunction
	call gf#user#extend('GfFile', 1000)
endif " }}}

if s:HasPlugin('vim-gista') " {{{
	let g:gista#github_user = 'assout'
	let g:gista#update_on_write = 1
	nnoremap [gista]     <Nop>
	nnoremap [gista]l    :<C-u>Unite gista<CR>
	nnoremap [gista]c    :<C-u>Gista<CR>
	nnoremap [gista]<CR> :<C-u>Gista<CR>
endif " }}}

if s:HasPlugin('vim-maximizer') " {{{
	let g:maximizer_default_mapping_key = '<C-t>' " 't'oggle window maximize.
endif " }}}

if s:HasPlugin('vim-migemo') " {{{
	if has('migemo')
		if has('vim_starting') | call migemo#SearchChar(0) | endif " caution: probably slow
		nnoremap [migemo] g/
	else
		nnoremap [migemo] :<C-u>Migemo<Space>
	endif
endif " }}}

if s:HasPlugin('vim-operator-surround') " {{{
	" refs <http://d.hatena.ne.jp/syngan/20140301/1393676442>
	" refs <http://www.todesking.com/blog/2014-10-11-surround-vim-to-operator-vim/>
	let g:operator#surround#blocks = deepcopy(g:operator#surround#default_blocks)
	call add(g:operator#surround#blocks['-'], { 'block' : ['<!-- ', ' -->'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['c']} )

	map <silent> [surround-a] <Plug>(operator-surround-append)
	map <silent> [surround-d] <Plug>(operator-surround-delete)
	map <silent> [surround-r] <Plug>(operator-surround-replace)

	if s:HasPlugin('vim-textobj-anyblock')
		nmap <silent>[surround-a]b <Plug>(operator-surround-append)<Plug>(textobj-anyblock-a)
		nmap <silent>[surround-d]b <Plug>(operator-surround-delete)<Plug>(textobj-anyblock-a)
		nmap <silent>[surround-r]b <Plug>(operator-surround-replace)<Plug>(textobj-anyblock-a)
	endif

	if s:HasPlugin('vim-textobj-between')
		nmap <silent>[surround-a]f <Plug>(operator-surround-append)<Plug>(textobj-between-a)
		nmap <silent>[surround-d]f <Plug>(operator-surround-delete)<Plug>(textobj-between-a)
		nmap <silent>[surround-r]f <Plug>(operator-surround-replace)<Plug>(textobj-between-a)
	endif

	if s:HasPlugin('vim-textobj-line')
		nmap <silent>[surround-a]l <Plug>(operator-surround-append)<Plug>(textobj-line-a)
		nmap <silent>[surround-d]l <Plug>(operator-surround-delete)<Plug>(textobj-line-a)
		nmap <silent>[surround-r]l <Plug>(operator-surround-replace)<Plug>(textobj-line-a)
	endif

	if s:HasPlugin('vim-textobj-url')
		nmap <silent>[surround-a]u <Plug>(operator-surround-append)<Plug>(textobj-url-a)
		" TODO no block matches to the region となる
		nmap <silent>[surround-d]u <Plug>(operator-surround-delete)<Plug>(textobj-url-a)
		" TODO appendの動きになってしまう
		nmap <silent>[surround-r]u <Plug>(operator-surround-replace)<Plug>(textobj-url-a)
	endif
endif " }}}

if s:HasPlugin('vim-ref') " {{{
	nnoremap [ref]  <Nop>

	if executable('elinks') || executable('w3m') || executable('links')|| executable('lynx')
		let g:ref_source_webdict_sites = {
					\ 'je'  : { 'url': 'http://dictionary.infoseek.ne.jp/jeword/%s', 'line': 15},
					\ 'ej'  : { 'url': 'http://dictionary.infoseek.ne.jp/ejword/%s', 'line': 15},
					\ 'wiki': { 'url': 'http://ja.wikipedia.org/wiki/%s', 'line': 23}, }
		let g:ref_source_webdict_sites.default = 'ej'
		let g:ref_source_webdict_use_cache = 1

		nnoremap [ref]w :<C-u>Ref webdict<Space>
		nnoremap [ref]wj :<C-u>Ref webdict je<Space>
		nnoremap [ref]we :<C-u>Ref webdict ej<Space>
	endif

	" TODO 選択範囲の単語で検索
	" TODO unite-actioinでyank
	" TODO unite重い
	" TODO コマンド履歴に残したい
	" TODO 和英ができない
	" TODO キャッシュ化されている？
	if s:HasPlugin('vim-ref-gene')
		nnoremap <expr> [ref]g ':<C-u>Ref gene<Space>'
		nnoremap <expr> [ref]G ':<C-u>Ref gene<Space>' . expand('<cword>') . '<CR>'
	endif
endif " }}}

if s:HasPlugin('vim-submode') " {{{ caution: prefix含めsubmode nameが長すぎるとInvalid argumentとなる(e.g. prefixを[submode]とするとエラー)
	nnoremap [sub]    <Nop>

	call submode#enter_with('winsize', 'n', '', '[sub]w', '<Nop>')
	call submode#map('winsize', 'n', '', 'h', '<C-w><')
	call submode#map('winsize', 'n', '', 'l', '<C-w>>')
	call submode#map('winsize', 'n', '', 'k', '<C-w>-')
	call submode#map('winsize', 'n', '', 'j', '<C-w>+')

	call submode#enter_with('scroll', 'n', '', '[sub]s', '<Nop>')
	call submode#map('scroll', 'n', '', 'h', 'zh')
	call submode#map('scroll', 'n', '', 'l', 'zl')
	call submode#map('scroll', 'n', '', 'H', '10zh')
	call submode#map('scroll', 'n', '', 'L', '10zl')

	call submode#enter_with('buffer', 'n', '', '[sub]b', '<Nop>')
	call submode#map('buffer', 'n', '', 'k', ':bprevious<CR>')
	call submode#map('buffer', 'n', '', 'j', ':bnext<CR>')
	call submode#map('buffer', 'n', '', 'K', ':bfirst<CR>')
	call submode#map('buffer', 'n', '', 'J', ':blast<CR>')

	" TODO 先頭と末尾に行き過ぎたときエラーでsubmode抜けたくない
	call submode#enter_with('args', 'n', '', '[sub]a', '<Nop>')
	call submode#map('args', 'n', '', 'k', ':previous<CR>')
	call submode#map('args', 'n', '', 'j', ':next<CR>')
	call submode#map('args', 'n', '', 'K', ':first<CR>')
	call submode#map('args', 'n', '', 'J', ':last<CR>')

	" TODO 先頭と末尾に行き過ぎたときエラーでsubmode抜けたくない
	call submode#enter_with('quickfix', 'n', '', '[sub]q', '<Nop>')
	call submode#map('quickfix', 'n', '', 'k', ':cprevious<CR>')
	call submode#map('quickfix', 'n', '', 'j', ':cnext<CR>')
	call submode#map('quickfix', 'n', '', 'K', ':cfirst<CR>')
	call submode#map('quickfix', 'n', '', 'J', ':clast<CR>')

	" TODO いまいち効かないときがある(Submode表記はされつづけるけど一行ごとにカーソル移動しちゃうときがある)
	call submode#enter_with('diff', 'n', '', '[sub]d', '<Nop>')
	call submode#map('diff', 'n', '', 'k', '[c')
	call submode#map('diff', 'n', '', 'j', ']c')
endif " }}}

if s:HasPlugin('vim-tags') " {{{
	let g:vim_tags_auto_generate = has('unix') ? 1 : 0
endif " }}}

if s:HasPlugin('vim-textobj-between') " {{{
	" textobj-functionとかぶるので変更(textobj-functionのマッピングはvrapperと合わせたいのでこちらを変える)
	let g:textobj_between_no_default_key_mappings = 1 " d(istance)に変える。。
	omap id <Plug>(textobj-between-i)
	omap ad <Plug>(textobj-between-a)
	vmap id <Plug>(textobj-between-i)
	vmap ad <Plug>(textobj-between-a)
endif " }}}

if s:HasPlugin('vim-textobj-entire') " {{{ TODO カーソル行位置は戻るが列位置が戻らない)
	nmap yae yae``
	nmap yie yie``
	nmap =ae =ae``
	nmap =ie =ie``
endif " }}}

if s:HasPlugin('vim-textobj-parameter') " {{{ vrapper textobj-argsと合わせる
	let g:textobj_parameter_no_default_key_mappings = 1
	omap ia <Plug>(textobj-parameter-i)
	omap aa <Plug>(textobj-parameter-a)
	vmap ia <Plug>(textobj-parameter-i)
	vmap aa <Plug>(textobj-parameter-a)
endif " }}}

if s:HasPlugin('yankround') " {{{ TODO 未保存のバッファでpするとエラーがでる(Could not get security context security...) <http://lingr.com/room/vim/archives/2014/04/13>
	nmap [yankround] <Plug>(yankround-p)
	nmap [Yankround] <Plug>(yankround-P)
	nmap <C-p> <Plug>(yankround-prev)
	nmap <C-n> <Plug>(yankround-next)
endif " }}}
" }}}1

" Section; After {{{1
filetype on

" :qで誤って終了してしまうのを防ぐためcloseに置き換える。caution: Vrapperでエラーになる
cabbrev q <C-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'close' : 'q')<CR>

nohlsearch " Don't (re)highlighting the last search pattern on reloading.
" }}}1

" vim:nofoldenable:

