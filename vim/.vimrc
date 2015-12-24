" # Index {{{1
" * Introduction
" * Begin
" * Functions and Commands
" * Let defines
" * Auto-commands
" * Options
" * Key-mappings
" * Plug-ins
" * After
" }}}1

" # Introduction {{{1
"
" ## Principles
" * Keep it short and simple, stupid! (500step以下に留めたい)
" * To portable! (e.g. office/home, vim/gvim/vrapper, development/server)
" * デフォルト環境(サーバなど)での操作時に混乱するカスタマイズはしない(;と:の入れ替えとか)(sだけはつぶしちゃう)
" * キーマッピングでは、スペースキーをプラグイン用、sキーをvim標準のプレフィックスとする
"
" ## Caution
" * executeコマンドをキーマッピングするとき<C-u>をつけること(e.g. nnoremap hoge :<C-u>fuga)
"   (誤って範囲指定しないようにするためなので、範囲指定してほしい場合はつけないこと) <http://d.hatena.ne.jp/e_v_e/20150101/1420067539>
" * vim-emacscommandline pluginは使わない。(commandlineでのescがキー入力待ちになるため)
" * '|' は :normal コマンドの一部として処理されるので、このコマンドの後に他のコマンドを続けて書けません。Refs. <:help normal>
" * 'noremap <expr> {lhs} {rhs}'のようにするとVrapperが有効にならない(noremap <expr>{lhs} {rhs}とするとOK、またはnoremap <silent><expr> {lhs} {rhs}もOK)
" * vimrcの設定ファイルはLinuxでは~/.vim, ~/.vimrcにする。Windowsでは~/vimfiles,~/_vimrcにする。(MSYS2も考慮するため)
"
" ## References
" * [Vimスクリプト基礎文法最速マスター - 永遠に未完成](http://d.hatena.ne.jp/thinca/20100201/1265009821)
" * [Big Sky :: モテる男のVim Script短期集中講座](http://mattn.kaoriya.net/software/vim/20111202085236.htm)
" * [Vimスクリプトリファレンス &mdash; 名無しのvim使い](http://nanasi.jp/code.html)
" * [Vimの極め方](http://whileimautomaton.net/2008/08/vimworkshop3-kana-presentation)
" * [Google Vimscript Style Guide](http://google-styleguide.googlecode.com/svn/trunk/vimscriptguide.xml)
" * [Google Vimscript Guide](http://google-styleguide.googlecode.com/svn/trunk/vimscriptfull.xml)
" * [Vim で使える Ctrl を使うキーバインドまとめ - 反省はしても後悔はしない](http://cohama.hateblo.jp/entry/20121023/1351003586)
"
" ## TODOs
" * TODO たまにIMで変換候補確定後に先頭の一文字消えることがある @win
" * TODO neocompleteでたまに日本語入力が変になる
" * TODO setなどの末尾にコメント入れるとVrapperで適用されない
" * TODO autoindent, smartindent, cindent, indentkeys関係見直す(特に問題があるわけではないがあまりわかってない)
" * TODO filetype syntax on, off関係見直す(特に問題があるわけではないがあまりわかってない)
" * TODO Add performance test for travisci (per plugin actual)
" * TODO Switch, Cycle 系のpluginで"[true, false], [public, private, ...], [#, ##, ...], [foo, bar, ...] あたりを入れる(speeddatingとコンフリクトに注意)
" }}}1

" # Begin {{{1

set encoding=utf-8 " inner encoding(before the scriptencoding)
scriptencoding utf-8 " before multi byte

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

" }}}1

" # Functions and Commands {{{1

function! s:IsHome()
  return $USERNAME ==# 'oji'
endfunction

function! s:IsOffice()
  return $USERNAME ==# 'admin'
endfunction

function! s:IsJenkins()
  return exists('$BUILD_NUMBER')
endfunction

function! s:IsPluginEnabled() " pluginが有効か返す
  return isdirectory(s:bundlePath) && &loadplugins
endfunction

function! s:HasPlugin(plugin) " pluginが存在するか返す
  return !empty(matchstr(&runtimepath, a:plugin)) && &loadplugins
endfunction

function! s:RestoreCursorPosition()
  let l:ignore_filetypes = ['gitcommit']
  if index(l:ignore_filetypes, &l:filetype) >= 0
    return
  endif
  if line("'\"") > 1 && line("'\"") <= line('$')
    normal! g`"
  endif
endfunction

" TODO undoしても&expandtabの値は戻らないので注意
function! s:MyToggleExpandTab()
  setlocal expandtab! | retab " Caution: retab! は使わない(意図しない空白も置換されてしまうため)
  if ! &expandtab " <http://vim-jp.org/vim-users-jp/2010/04/30/Hack-143.html>
    " Refs. <:help restore-position>
    normal! msHmt
    execute '%substitute@^\v(%( {' . &l:tabstop . '})+)@\=repeat("\t", len(submatch(1))/' . &l:tabstop . ')@e' | normal! 'tzt`s
  endif
endfunction
command! MyToggleExpandTab call <SID>MyToggleExpandTab()

" TODO undoしても&tabstopの値は戻らないので注意
function! s:MyChangeTabstep(size)
  if &l:expandtab
    " Refs. <:help restore-position>
    normal! msHmt
    execute '%substitute@\v^(%( {' . &l:tabstop . '})+)@\=repeat(" ", len(submatch(1)) / ' . &l:tabstop . ' * ' . a:size . ')@eg' | normal! 'tzt`s
  endif
  let &l:tabstop = a:size
  let &l:shiftwidth = a:size
endfunction
command! -nargs=1 MyChangeTabstep call <SID>MyChangeTabstep(<q-args>)

" Caution: 引数にスペースを含めるにはバックスラッシュを前置します Refs. <:help f-args>
function! s:InsertString(pos, str) range
  execute a:firstline . ',' . a:lastline . 'substitute/' . a:pos . '/' . substitute(a:str, '/', '\\/', 'g')
endfunction
command! -range -nargs=1 MyPrefix <line1>,<line2>call <SID>InsertString('^', <f-args>)
command! -range -nargs=1 MySuffix <line1>,<line2>call <SID>InsertString('$', <f-args>)

" TODO 消す。(Refソース or Uniteソースにする)(Ref-geneがあるが和英ができないっぽい)
" TODO 超汚い。あとたまにバグる(カレントバッファがPreviewになってしまう)
" TODO あいまい検索的なものがほしい(vim spellの`z=`的なもの)
function! s:MyTranslate(...) " required gene.txt, kaoriya/dicwin.vimで良いが和英したいため
  let l:word = a:0 == 0 ? expand('<cword>') : a:1
  call histadd('cmd', 'MyTranslate '  . l:word)
  if l:word ==# '' " Caution: if-endifをパイプで一行で書くと特定環境(office)でvimrcが無効になる
    return
  endif
  let l:gene_path = s:IsHome() ? '~/.vim/dict/gene.txt' : '~/vimfiles/dict/gene95/GENE.TXT'
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
  while search('\c^' . l:word . '$', 'Wc') > 0
    silent execute line('.') - l:jpn_to_eng . 'delete Z 2'
  endwhile
  if @z !=# '' " Caution: 特定環境(office)でput zのエラーが出るため
    silent 0put z
  endif
  let @z = l:esc
  silent call append(line('.'), '==')
  silent 1delete
  silent wincmd p
endfunction
command! -nargs=? MyTranslate call <SID>MyTranslate(<f-args>)

function! s:MyHere()
  if s:IsOffice()
    " Caution: Windowsで set shellslashしているときうまく開かないため設定。
    " Caution: |(<BAR>)で一行で書くこともできるが外部コマンド実行時は<BAR>は使えない。-> <NL>を使えば可能だが(Refs. :help :bar)、NULL文字扱いされちゃうらしく当ファイルがGitでバイナリファイル扱いされてしまう。
    setlocal noshellslash
    !start explorer.exe "%:h"
    " TODO エスケープした値を復元するように直す
    setlocal shellslash
  else
    !nautilus %:h &
  endif
endfunction
command! MyHere call <SID>MyHere()

command! -bang MyBufClear %bdelete<bang>
command! -range=% MyTrimSpace <line1>,<line2>s/[ \t]\+$// | nohlsearch | normal! ``
command! -range=% MyDelBlankLine <line1>,<line2>v/\S/d | nohlsearch

" }}}1

" # Let defines {{{1

let g:is_bash = 1 " shellのハイライトをbash基準にする。Refs. <:help sh.vim>
let g:loaded_matchparen = 1 " Refs. <:help matchparen>
let g:netrw_liststyle = 3 " netrwのデフォルト表示スタイル変更

if s:IsJenkins()
  let s:bundlePath = expand('$WORKSPACE/target/bundle/')
elseif s:IsOffice()
  let s:bundlePath = expand('~/vimfiles/bundle/') " Caution: Windowsだとデフォルトで~/.vimにruntimepath通さないのでvimfilesにする(migemo pluginがデフォルトでruntimepathとしてにいってくれたりする)
else
  let s:bundlePath = expand('~/.vim/bundle/')
endif

if has('win32unix') " For mintty. Caution: Gnome terminalでは不可。office devはキーが不正になった。
  let &t_ti .= "\e[1 q"
  let &t_SI .= "\e[5 q"
  let &t_EI .= "\e[1 q"
  let &t_te .= "\e[0 q"
endif

" Disable unused built-in plugins {{{
let g:loaded_gzip              = 1
let g:loaded_tar               = 1
let g:loaded_tarPlugin         = 1
let g:loaded_zip               = 1
let g:loaded_zipPlugin         = 1
let g:loaded_rrhelper          = 1
let g:loaded_2html_plugin      = 1
let g:loaded_vimball           = 1
let g:loaded_vimballPlugin     = 1
let g:loaded_getscript         = 1
let g:loaded_getscriptPlugin   = 1
let g:loaded_netrw             = 1
let g:loaded_netrwPlugin       = 1
let g:loaded_netrwSettings     = 1
let g:loaded_netrwFileHandlers = 1
" }}}

" }}}1

" # Auto-commands {{{1

augroup vimrc " Caution: FileType Eventのハンドリングは<# After>に定義する
  autocmd!

  " Double byte space highlight
  autocmd Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
  autocmd VimEnter,WinEnter * match DoubleByteSpace /　/
  " QuickFixを自動で開く " Caution: grep, makeなど以外では呼ばれない (e.g. watchdogs, syntastic)
  autocmd QuickfixCmdPost [^l]* nested if len(getqflist()) != 0  | copen | endif
  autocmd QuickfixCmdPost l*    nested if len(getloclist(0)) != 0 | lopen | endif
  " QuickFix内<CR>で選択できるようにする(上記QuickfixCmdPostでも設定できるが、watchdogs, syntasticの結果表示時には呼ばれないため別で設定)
  autocmd BufReadPost quickfix,loclist setlocal modifiable nowrap " TODO quickfix表示されたままwatchdogs再実行するとnomodifiableのままとなることがある
  " Set freemaker filetype
  autocmd BufNewFile,BufRead *.ftl nested setfiletype html.ftl
  " Set markdown filetype TODO 最新のvimでは不要
  autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} setfiletype markdown
  " Restore cusor position
  autocmd BufWinEnter * call s:RestoreCursorPosition()

augroup END

" }}}1

" # Options {{{1

set autoindent
set background=dark
set backspace=indent,eol,start
set nobackup
" Caution: smartindent使わない(コマンド ">>" を使ったとき、'#' で始まる行は右に移動しないため。Refs. :help si) TODO cindnetにしても移動しなくなってしまったので暫定コメントアウトする
" set cindent
set clipboard=unnamed,unnamedplus
set cmdheight=1
if has('patch-7.4.399')
  set cryptmethod=blowfish2
endif
set diffopt& diffopt+=vertical
set expandtab
set fileencodings=utf-8,ucs-bom,iso-2020-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,latin,latin1,utf-8
if has('folding')
  set foldlevelstart=0
  set foldmethod=marker
endif
" フォーマットオプション(-oでo, Oコマンドでの改行時のコメント継続をなくす)
set formatoptions& formatoptions-=o
" TODO Windows Gvimで~からのパスをgrepすると結果ファイルが表示できない(D:\d\hoge\fuga のように解釈されてるっぽい)(/d/admin/hogeも同様にNG)
" Caution: Windowsで"hoge\*"という指定するとNo such file or directoryと表示される。('/'区切りの場合うまくいく)
set grepprg=grep\ -nH\ --binary-files=without-match\ --exclude-dir=.git
" keywordprgで日本語優先にしたいため
set helplang=ja,en
set hidden
set history=200
set hlsearch
set ignorecase
set incsearch
" TODO やっぱ↓をやめるので_区切りのテキストオブジェクトが別途ほしい
" set iskeyword-=_
" <<,>>で#をインデントできるようにする
set indentkeys-=0#
" vim-refとの兼ね合いでここではhelp
set keywordprg=:help
set list
set listchars=tab:>.,trail:_,extends:\
set laststatus=2
" マクロなどを実行中は描画を中断
set lazyredraw
if !has('folding') " TODO workaround. 当ファイルのfoldenableが特定環境(office)でエラーが出る
  set modelines=0
endif
set number
" インクリメンタル/デクリメンタルを常に10進数として扱う
set nrformats=""
set scrolloff=5
if has('win32')
  " Caution: 関係するオプション(shellcmdflag等)の設定も必要かも -> 自動設定されるっポイ
  " TODO 副作用ありのためコメントアウト (watchdogsでcmd.exeに依存したチェックをしている箇所が動かなくなる など)
  " set shell=bash.exe

  " Caution: Windowsでgrep時バックスラッシュだとパスと解釈されないことがあるために設定。
  " Caution: GUI, CUIでのtags利用時のパスセパレータ統一のために設定。
  " Caution: 副作用があることに注意(Refs. <https://github.com/vim-jp/issues/issues/43>)
  "  * TODO Windowsでgxでエクスプローラ開けなくなる
  set shellslash
endif
set shiftwidth=2
set showcmd
set showtabline=1
set shortmess& shortmess+=atTO
set sidescrolloff=5
set smartcase
if s:IsHome()
  set spellfile=~/Dropbox/spell/en.utf-8.add
else
  set spellfile=~/Documents/spell/en.utf-8.add
endif
set softtabstop=0
set splitbelow
set splitright
" スペルチェックで日本語は除外する
set spelllang& spelllang+=cjk
if has('path_extra')
  set tags& tags=./.tags;
else
  set tags& tags=./.tags
endif
set tabstop=2
" 自動改行をなくす
set textwidth=0
set title
set ttimeoutlen=0
if has('persistent_undo')
  set noundofile
endif
set wildmenu
" set wildmode=list:longest
set nowrap
set nowrapscan
if has('win32')
  " swapfile作成有無(offにするとvimfilerでのネットワークフォルダ閲覧が高速化するかも(効果は不明))
  set noswapfile
endif

" }}}1

" # Key-mappings {{{1

" caution: 前は<C-j>を<Esc>に割り当ててたけどbashとかだとEnter扱いでややこしいからやめた
" あとなにかのpluginでjk同時押しも試したけど合わなかった(visual modeだとできないし、jのあとキー入力待ちになるの気持ちわるい)

" Normal, Visual mode basic mappings {{{
nnoremap j    gj
nnoremap k    gk
nnoremap gj   j
nnoremap gk   k
nnoremap Y    y$
nnoremap <CR> i<CR><Esc>
" ビジュアルモードでのヤンク後にカーソルを選択前の位置に戻さない(メソッド選択してコピペ時など)
vnoremap y    y`>
" }}}

" Shortcut key prefix mappings {{{

" <SID>[shortcut]a, d, rはsurround-pluginで使用
" <SID>[shortcut]mはmaximizer-pluginで使用
noremap  gs               s
map      s                <SID>[shortcut]
noremap  <SID>[shortcut]  <Nop>
noremap  <SID>[shortcut]/ /\v
noremap  <SID>[shortcut]? ?\v
noremap  <SID>[shortcut]a <Nop>
nnoremap <SID>[shortcut]c <C-w>c
noremap  <SID>[shortcut]d <Nop>
nnoremap <SID>[shortcut]h <C-w>h
map      <SID>[shortcut]i <SID>[insert]
nnoremap <SID>[shortcut]j <C-w>j
nnoremap <SID>[shortcut]k <C-w>k
nnoremap <SID>[shortcut]l <C-w>l
noremap  <SID>[shortcut]m <Nop>
nnoremap <SID>[shortcut]n :<C-u>nohlsearch<CR>
nmap     <SID>[shortcut]o <SID>[open]
nnoremap <SID>[shortcut]p :<C-u>split<CR>
noremap  <SID>[shortcut]r <Nop>
nnoremap <SID>[shortcut]t :<C-u>MyTranslate<CR>
if has('gui_running') " Caution: autocmd FileTypeイベントを発効する
  nnoremap <SID>[shortcut]u :<C-u>source $MYVIMRC<Bar>:source $MYGVIMRC<Bar>:filetype detect<CR>
else
  nnoremap <SID>[shortcut]u :<C-u>source $MYVIMRC<Bar>:filetype detect<CR>
endif
nnoremap       <SID>[shortcut]v :<C-u>vsplit<CR>
nnoremap       <SID>[shortcut]x :<C-u>bdelete<CR>
nnoremap       <SID>[shortcut]z :<C-u>pclose<CR>
nnoremap <expr><SID>[shortcut]] ':ptag ' . expand("<cword>") . '<CR>'

" TODO To plugin or function
noremap       <SID>[insert]  <Nop>
noremap <expr><SID>[insert]p ':MyPrefix ' . input('prefix:') . '<CR>'
noremap       <SID>[insert]*  :MyPrefix * <CR>
noremap       <SID>[insert]1  :MyPrefix # <CR>A
noremap       <SID>[insert]2  :MyPrefix ## <CR>A
noremap       <SID>[insert]3  :MyPrefix ### <CR>A
noremap       <SID>[insert]4  :MyPrefix #### <CR>A
noremap       <SID>[insert]>  :MyPrefix > <CR>
noremap       <SID>[insert]T  :MyPrefix TODO <CR>
noremap       <SID>[insert]f  :MyPrefix file://<CR>
noremap <expr><SID>[insert]s ':MySuffix ' . input('suffix:') . '<CR>'
noremap <expr><SID>[insert]d ':MySuffix ' . strftime('\ @%Y-%m-%d') . '<CR>'
noremap <expr><SID>[insert]t ':MySuffix ' . strftime('\ @%H:%M:%S') . '<CR>'
noremap <expr><SID>[insert]n ':MySuffix ' . strftime('\ @%Y-%m-%d %H:%M:%S') . '<CR>'
noremap <expr><SID>[insert]a ':MySuffix \ @' . input('author:') . '<CR>'
noremap       <SID>[insert]l  :MySuffix \<Space>\ <CR>

nnoremap <SID>[open] <Nop>
" resolveしなくても開けるがfugitiveで対象とするため
" TODO Windowsのとき$MYVIMRCの展開だと対象にならない(シンボリックリンクを解決できない？)
let g:myvimrcPath = has('unix') ? resolve(expand($MYVIMRC)) : '~/Development/dotfiles/vim/.vimrc'
nnoremap <expr><SID>[open]v ':<C-u>edit ' . g:myvimrcPath . '<CR>'
if s:IsOffice()
  nnoremap <SID>[open]i :<C-u>edit ~/Tools/ChatAndMessenger/logs/どなどな.log<CR>
endif
" }}}

" Ctrl, Alt key prefix mappings {{{
nnoremap <M-h> gT
nnoremap <M-l> gt
nnoremap <M-t> :<C-u>tabedit<CR>
nnoremap <M-c> :<C-u>tabclose<CR>

" Use ':tjump' instead of ':tag'. -> Caution: 下記の設定はしない!(vimrcとかをシンボリックリンク作ってる場合ちょいちょい重複してうざいため)
" nnoremap <C-]> g<C-]>
" }}}

" Like unimpaired plugin mappings {{{
if ! s:HasPlugin('vim-unimpaired')
  nnoremap [a     :previous<CR>
  nnoremap ]a     :next<CR>
  nnoremap [A     :first<CR>
  nnoremap ]A     :last<CR>
  nnoremap [b     :bprevious<CR>
  nnoremap ]b     :bnext<CR>
  nnoremap [B     :bfirst<CR>
  nnoremap ]B     :blast<CR>
  nnoremap [l     :lprevious<CR>
  nnoremap ]l     :lnext<CR>
  nnoremap [L     :lfirst<CR>
  nnoremap ]L     :llast<CR>
  nnoremap [<C-L> :lpfile<CR>
  nnoremap ]<C-L> :llast<CR>
  nnoremap [q     :cprevious<CR>
  nnoremap ]q     :cnext<CR>
  nnoremap [Q     :cfirst<CR>
  nnoremap ]Q     :clast<CR>
  nnoremap [<C-Q> :cpfile<CR>
  nnoremap ]<C-Q> :cnfile<CR>
  nnoremap [t     :tbprevious<CR>
  nnoremap ]t     :tnext<CR>
  nnoremap [T     :tfirst<CR>
  nnoremap ]T     :tlast<CR>
endif
" Adding to unimpaired plugin mapping
nnoremap [g     :tabprevious<CR>
nnoremap ]g     :tabnext<CR>
nnoremap [G     :tabfirst<CR>
nnoremap ]G     :tablast<CR>
nnoremap [w     :wincmd W<CR>
nnoremap ]w     :wincmd w<CR>
nnoremap [W     :wincmd t<CR>
nnoremap ]W     :wincmd b<CR>
" }}}

" Insert mode mappings {{{
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Del>
inoremap <C-k> <C-o>D
inoremap <M-b> <S-Left>
inoremap <M-f> <S-Right>
inoremap <M-d> <C-o>dw
" TODO <C-M-h>での一単語Backspace(<C-w>はできている)
" }}}

" Command-line mode mappings {{{
" TODO 一単語Delete
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-d> <Del>
cnoremap <C-k> <C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos()-2]<CR>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
" }}}

" }}}1

" # Plug-ins {{{1
if s:IsPluginEnabled() && isdirectory(expand(s:bundlePath . 'neobundle.vim')) && ! has('win32unix')
  if has('vim_starting')
    let &runtimepath = &runtimepath . ',' . s:bundlePath . 'neobundle.vim/'
  endif
  call g:neobundle#begin(expand(s:bundlePath))

  " Caution: dependsはパフォーマンス悪いかもしれないから使わない
  " General {{{
  NeoBundle     'Jagua/vim-ref-gene'
  NeoBundle     'KazuakiM/vim-qfsigns' " For watchdogs.
  NeoBundleLazy 'LeafCage/vimhelpgenerator', { 'autoload' : { 'commands' : ['VimHelpGenerator','VimHelpGeneratorVirtual'], }, }
  NeoBundle     'LeafCage/yankround.vim', {'disabled' : exists('$BUILD_NUMBER')} " TODO Jenkinsだとエラー
  NeoBundle     'Shougo/neobundle.vim', {'disabled' : !executable('git')}
  NeoBundle     'Shougo/neocomplete', {'disabled' : !has('lua')}
  NeoBundle     'Shougo/neomru.vim', {'disabled' : !has('lua') || exists('$BUILD_NUMBER')} " TODO Jenkinsだとエラー
  NeoBundle     'Shougo/unite-outline'
  NeoBundle     'Shougo/unite.vim'
  NeoBundle     'Shougo/vimfiler.vim'
  NeoBundle     'Shougo/vimproc', {'disabled' : has('kaoriya'), 'build' : { 'Windows' : 'make -f make_mingw32.mak', 'cygwin' : 'make -f make_cygwin.mak', 'mac' : 'make -f make_mac.mak', 'unix' : 'make -f make_unix.mak', }, }
  NeoBundle     'TKNGUE/hateblo.vim', {'disabled' : has('win32') || exists('$BUILD_NUMBER')} " entryの保存位置を指定できるためfork版を使用。本家へもPRでてるので、取り込まれたら見先を変える。本家は('moznion/hateblo.vim') TODO Jenkinsだとエラー
  NeoBundle     'aklt/plantuml-syntax'
  NeoBundle     'assout/unite-todo'
  NeoBundle     'chaquotay/ftl-vim-syntax'
  NeoBundle     'dannyob/quickfixstatus' " For watchdogs. TODO syntasticと競合するっぽい
  NeoBundle     'elzr/vim-json' " For json filetype
  NeoBundle     'fuenor/im_control.vim'
  NeoBundle     'glidenote/memolist.vim'
  NeoBundle     'godlygeek/tabular' " For taburize markdown table
  NeoBundle     'gregsexton/VimCalc', {'disabled' : !has('python2')} " TODO msys2のpythonだと有効にならない
  NeoBundle     'h1mesuke/vim-alignta'
  NeoBundle     'haya14busa/vim-migemo', {'disabled' : !executable('cmigemo')}
  NeoBundle     'https://raw.githubusercontent.com/mrichie/vimfiles/master/plugin/hz_ja.vim', {'script_type' : 'plugin', 'disabled' : has('kaoriya')} " TODO homeでエラーメッセージ出るっポイ(これが原因か不明だが)
  NeoBundle     'itchyny/calendar.vim'
  NeoBundle     'kana/vim-fakeclip'
  NeoBundle     'kana/vim-gf-user'
  NeoBundle     'kana/vim-submode'
  if s:IsHome()
    NeoBundle 'kannokanno/previm'
  else
    NeoBundle 'kannokanno/previm', {'rev' : '1.3' } " TODO 最新版だとIE Tabで表示されない(印刷プレビュー使いたい) TODO このバージョンはCSS指定できないので大元のcssを編集しちゃう(h1~6のフォントサイズを小さく) TODO ファイルによって表示されない(memolist Windowsとか)
  endif
  NeoBundle     'koron/codic-vim' " TODO vimprocなどで非同期化されてる？
  NeoBundle     'lambdalisue/vim-gista', {'disabled' : !executable('curl') && !executable('wget')}
  NeoBundle     'mattn/benchvimrc-vim' " TODO msys2 vimだと_vimrc見てくれない(暫定で書き換えちゃう)
  NeoBundle     'mattn/emmet-vim' " markdownのurlタイトル取得:<C-y>a コメントアウトトグル : <C-y>/
  NeoBundle     'mattn/qiita-vim'
  NeoBundle     'mattn/webapi-vim', {'disabled' : !executable('curl') && !executable('wget')}
  NeoBundle     'medihack/sh.vim' " For function block indentation, caseラベルをインデントしたい場合、let g:sh_indent_case_labels = 1
  NeoBundle     'nathanaelkane/vim-indent-guides'
  NeoBundle     'osyo-manga/shabadou.vim' " For watchdogs.
  NeoBundle     'osyo-manga/vim-watchdogs'
  NeoBundle     'pangloss/vim-javascript' " For indent only
  NeoBundle     'rhysd/unite-codic.vim' " TODO 辞書提供なくなったぽっいので古いかも
  NeoBundle     'schickling/vim-bufonly'
  " NeoBundle     'scrooloose/syntastic' " TODO quickfixstatusと競合するっぽい
  NeoBundle     'szw/vim-maximizer' " Windowの最大化・復元
  NeoBundle     't9md/vim-textmanip'
  NeoBundle     'thinca/vim-localrc'
  NeoBundle     'thinca/vim-qfreplace' " grepした結果を置換
  NeoBundle     'thinca/vim-quickrun'
  NeoBundle     'thinca/vim-ref'
  NeoBundle     'thinca/vim-singleton', {'disabled' : !has('clientserver')} " Caution: 引数無しで起動すると二重起動される
  NeoBundle     'tomtom/tcomment_vim'
  NeoBundle     'tpope/vim-abolish'
  NeoBundle     'tpope/vim-fugitive', {'disabled' : !executable('git')}
  NeoBundle     'tpope/vim-repeat'
  NeoBundle     'tpope/vim-speeddating'
  NeoBundle     'tpope/vim-unimpaired'
  NeoBundle     'tsukkee/unite-tag'
  NeoBundle     'tyru/capture.vim'
  NeoBundle     'tyru/open-browser.vim' " TODO シングルクォートで囲まれたURLが開けない@office(gui, cui)(e.g. 'http://hoge')
  if s:IsHome()
    NeoBundle 'tyru/restart.vim'
  else
    NeoBundle 'tyru/restart.vim', {'rev' : 'v0.0.8' } " TODO 最新版はWindowsで異常終了する
  endif
  NeoBundle     'ujihisa/unite-colorscheme'
  NeoBundle     'vim-jp/vimdoc-ja' " TODO msys2で有効にならない(runtimeに手動追加しても)
  NeoBundle     'vim-scripts/DirDiff.vim' " TODO 文字化けする
  NeoBundle     'vim-scripts/HybridText'
  NeoBundleLazy 'xolox/vim-easytags', { 'autoload' : { 'filetypes' : ['vim', 'sh'], }, }
  NeoBundle     'xolox/vim-misc' " For easytags.
  NeoBundle     'xolox/vim-shell' " For easytags.
  " }}}

  " User Operators {{{
  NeoBundle     'kana/vim-operator-user'
  NeoBundle     'kana/vim-operator-replace'
  NeoBundle     'rhysd/vim-operator-surround' " life changing. sdb, sab.
  NeoBundle     'syngan/vim-operator-inserttext'
  NeoBundle     'tyru/operator-camelize.vim'
  " }}}

  " User Textobjects {{{
  NeoBundle     'kana/vim-textobj-user'
  NeoBundle     'kana/vim-textobj-entire'
  NeoBundle     'kana/vim-textobj-function'
  NeoBundle     'kana/vim-textobj-indent'
  NeoBundle     'kana/vim-textobj-line'
  NeoBundle     'mattn/vim-textobj-url'
  NeoBundle     'rhysd/vim-textobj-anyblock' " life changing. dib, dab.
  NeoBundle     'sgur/vim-textobj-parameter'
  NeoBundle     'thinca/vim-textobj-between'
  NeoBundle     'thinca/vim-textobj-comment'
  " }}}

  " Colorschemes {{{
  NeoBundle     'altercation/vim-colors-solarized'
  NeoBundle     'chriskempson/vim-tomorrow-theme'
  NeoBundle     'sickill/vim-monokai'
  NeoBundle     'tomasr/molokai'
  NeoBundle     'w0ng/vim-hybrid'
  " }}}

  call g:neobundle#end()
  " filetype plugin indent on " Required! Caution: 最後にまとめてやる
  " Caution: NeoBundleCheckはやらない（パフォーマンス）
elseif s:IsPluginEnabled() && isdirectory(expand(s:bundlePath . 'neobundle.vim')) && has('win32unix')
  " MSYS2 Plugin settings {{{
  " TODO すべてだと遅いので必要最小限のもののみ個別にパス通す
  " TODO watchdogs遅い(+300ms)
  " TODO easytags遅い
        " \  'vim-watchdogs',
        " \  'vim-easytags',
        " \  'vim-shell',
  let s:plugins = [
        \  'benchvimrc-vim',
        \  'capture.vim',
        \  'im_control.vim',
        \  'memolist.vim',
        \  'neomru.vim',
        \  'open-browser.vim',
        \  'previm',
        \  'quickfixstatus',
        \  'sh.vim',
        \  'shabadou.vim',
        \  'tcomment_vim',
        \  'unite-outline',
        \  'unite-tag',
        \  'unite-todo',
        \  'unite.vim',
        \  'vim-alignta',
        \  'vim-hybrid',
        \  'vim-indent-guides',
        \  'vim-javascript',
        \  'vim-maximizer',
        \  'vim-misc',
        \  'vim-operator-replace',
        \  'vim-operator-surround',
        \  'vim-operator-user',
        \  'vim-qfsigns',
        \  'vim-quickrun',
        \  'vim-ref',
        \  'vim-ref-gene',
        \  'vim-repeat',
        \  'vim-submode',
        \  'vim-textobj-anyblock',
        \  'vim-textobj-between',
        \  'vim-textobj-entire',
        \  'vim-textobj-function',
        \  'vim-textobj-parameter',
        \  'vim-textobj-url',
        \  'vim-textobj-user',
        \  'vimfiler.vim',
        \  'yankround.vim',
        \]

  for s:plugin in s:plugins
    let &runtimepath = &runtimepath . ',' . s:bundlePath . s:plugin
  endfor

  " }}}
endif

" Plugin prefix mappings {{{
if s:IsPluginEnabled()
  map  <Space>              <SID>[plugin]
  map  <SID>[plugin]<Space> <SID>[sub_plugin]

  xmap <SID>[plugin]a       <SID>[alignta]
  map  <SID>[plugin]c       <SID>[camelize]
  nmap <SID>[plugin]f       <SID>[fugitive]
  map  <SID>[plugin]g       <SID>[gista]
  nmap <SID>[plugin]m       <SID>[memolist]
  map  <SID>[plugin]o       <SID>[open-browser]
  map  <SID>[plugin]O       <SID>[Open-browser]
  nmap <SID>[plugin]p       <SID>[previm]
  nmap <SID>[plugin]q       <SID>[quickrun]
  map  <SID>[plugin]r       <SID>[replace]
  map  <SID>[plugin]t       <SID>[todo]
  nmap <SID>[plugin]u       <SID>[unite]
  nmap <SID>[plugin]w       <SID>[watchdogs]
  nmap <SID>[plugin]W       <SID>[Watchdogs]
  nmap <SID>[plugin]/       <SID>[migemo]
  " TODO <SID>つけれない(つけないと"[s"と入力した時にキー入力待ちが発生してしまう)
  nmap <SID>[plugin][       [subP]
  nmap <SID>[plugin]]       [subN]

  map  <SID>[sub_plugin]h   <SID>[hateblo]
  nmap <SID>[sub_plugin]q   <SID>[qiita]
  " TODO 押しづらい
  nmap <SID>[sub_plugin]r   <SID>[ref]
  map  <SID>[sub_plugin]s   <SID>[syntastic]

  nmap p                <Plug>(yankround-p)
  nmap P                <Plug>(yankround-P)
  nmap <C-p>            <Plug>(yankround-prev)
  nmap <C-n>            <Plug>(yankround-next)
  map  <SID>[shortcut]a <SID>[surround-a]
  map  <SID>[shortcut]d <SID>[surround-d]
  map  <SID>[shortcut]r <SID>[surround-r]
  map  <SID>[shortcut]m <SID>[maximizer]
endif
" }}}

if s:HasPlugin('calendar.vim') " {{{
  let g:calendar_google_calendar = s:IsHome() ? 1 : 0
  let g:calendar_google_task = s:IsHome() ? 1 : 0
endif " }}}

if s:HasPlugin('fugitive') " {{{ TODO fugitiveが有効なときのみマッピングしたい TODO Windows で fugitive バッファ側の保存時にエラー(:Gwはうまくいく)
  nnoremap <SID>[fugitive]<CR>   :Git<Space>
  nnoremap <SID>[fugitive]cm<CR> :Gcommit<CR>
  nnoremap <SID>[fugitive]cmm    :Gcommit -m ""<Left>
  nnoremap <SID>[fugitive]cma    :Gcommit -a<CR>
  nnoremap <SID>[fugitive]d      :Gdiff<CR>
  nnoremap <SID>[fugitive]l      :Glog<CR>
  nnoremap <SID>[fugitive]p      :Gpush<CR>
  nnoremap <SID>[fugitive]s      :Gstatus<CR>
endif " }}}

if s:HasPlugin('hateblo') " {{{
  let g:hateblo_vim = {
        \  'user': 'assout',
        \  'api_key': g:hateblo_api_key,
        \  'api_endpoint': 'https://blog.hatena.ne.jp/assout/assout.hatenablog.com/atom',
        \  'WYSIWYG_mode': 0,
        \  'always_yes': 0,
        \  'edit_command': 'edit'
        \} " api_keyはvimrc.localから設定
  let g:hateblo_dir = expand('~/.cache/hateblo/blog')

  nnoremap <SID>[hateblo]l :<C-u>HatebloList<CR>
  nnoremap <SID>[hateblo]c :<C-u>HatebloCreate<CR>
  nnoremap <SID>[hateblo]C :<C-u>HatebloCreateDraft<CR>
  nnoremap <SID>[hateblo]d :<C-u>HatebloDelete<CR>
  nnoremap <SID>[hateblo]u :<C-u>HatebloUpdate<CR>
endif " }}}

if s:HasPlugin('HybridText') " {{{
  autocmd vimrc BufRead,BufNewFile *.{txt,mindmap} nested setfiletype hybrid
endif " }}}
if s:HasPlugin('im_control.vim') " {{{
  " TODO msys2でだめ
  let g:IM_CtrlMode = s:IsHome() ? 1 : 4 " caution: linuxのときは設定しなくても期待した挙動になるけど一応
  if s:IsHome()
    function! g:IMCtrl(cmd)
      if a:cmd ==? 'On'
        let l:res = system('xvkbd -text "\[Henkan_Mode]\" > /dev/null 2>&1')
      elseif a:cmd ==? 'Off'
        let l:res = system('xvkbd -text "\[Muhenkan]" > /dev/null 2>&1') " Caution: なぜかmozcの設定でCtrl+MuhenkanをIMEオフに割り当てないといけない。(Ctrl+Shif+Deleteだと<C-o>とかが使えなくなる)
      elseif a:cmd ==? 'Toggle'
        let l:res = system('xvkbd -text "\[Zenkaku_Hankaku]" > /dev/null 2>&1')
      endif
      return ''
    endfunction
  endif
endif " }}}

if has('kaoriya') " {{{
  let g:plugin_dicwin_disable = 1 " dicwin plugin無効
  let g:plugin_scrnmode_disable = 1 " scrnmode plugin無効
else
  command! -nargs=0 CdCurrent cd %:p:h
endif " }}}

if s:HasPlugin('memolist') " {{{
  let g:memolist_memo_suffix = 'md'
  let g:memolist_path = s:IsHome() ? '~/Dropbox/memolist' : expand('~/Documents/memolist')
  let g:memolist_template_dir_path = g:memolist_path

  function! s:MyMemoGrep(word)
    call histadd('cmd', 'MyMemoGrep '  . a:word)
    execute ':silent grep -r --exclude-dir=_book ' . a:word . ' ' . g:memolist_path
  endfunction
  command! -nargs=1 -complete=command MyMemoGrep call <SID>MyMemoGrep(<q-args>)

  nnoremap <SID>[memolist]a :<C-u>MemoNew<CR>
  if s:HasPlugin('unite') " {{{
    let g:unite_source_alias_aliases = {
          \  'memolist' : { 'source' : 'file_rec', 'args' : g:memolist_path },
          \  'memolist_reading' : { 'source' : 'file', 'args' : g:memolist_path },
          \}
    call g:unite#custom_source('memolist', 'sorters', ['sorter_ftime', 'sorter_reverse'])
    call g:unite#custom_source('memolist', 'matchers', ['converter_tail_abbr', 'matcher_default', 'matcher_hide_hidden_files'])
    call g:unite#custom#source('memolist', 'ignore_pattern', 'exercises\|reading\|_book\|\(png\|gif\|jpeg\|jpg\)$')
    call g:unite#custom_source('memolist_reading', 'sorters', ['sorter_ftime', 'sorter_reverse'])
    call g:unite#custom_source('memolist_reading', 'matchers', ['converter_tail_abbr', 'matcher_default', 'matcher_hide_hidden_files'])
    call g:unite#custom#source('memolist_reading', 'ignore_pattern', '^\%(.*exercises\|.*reading\)\@!.*\zs.*\|\(png\|gif\|jpeg\|jpg\)$')
    nnoremap <SID>[memolist]l :<C-u>Unite memolist -buffer-name=memolist<CR>
    nnoremap <SID>[memolist]L :<C-u>Unite memolist_reading -buffer-name=memolist_reading<CR>
  else " }}}
    nnoremap <SID>[memolist]l :<C-u>MemoList<CR>
  endif
  nnoremap <expr><SID>[memolist]g ':<C-u>MyMemoGrep ' . input('MyMemoGrep word: ') . '<CR>'
endif " }}}

if s:HasPlugin('neocomplete') " {{{
  let g:neocomplete#enable_at_startup = has('lua') && s:IsHome() ? 1 : 0 " 若干負荷あるので最低限有効
endif " }}}

if s:HasPlugin('open-browser') " {{{
  " Caution: vimrcリロードでデフォルト値が消えてしまわないようにする TODO やりたいこととあってる？
  let g:openbrowser_search_engines = extend(
        \  get(g:, 'openbrowser_search_engines', {}), {
        \    'translate' : 'https://translate.google.com/?hl=ja#auto/ja/{query}',
        \    'stackoverflow' : 'http://stackoverflow.com/search?q={query}',
        \  },
        \  'keep'
        \)
  let s:engines = {
        \  'a' : 'alc',
        \  'd' : 'devdocs',
        \  'g' : 'google',
        \  's' : 'stackoverflow',
        \  't' : 'translate',
        \  'w' : 'wikipedia-ja',
        \}
  if has('win32unix')
    let g:openbrowser_browser_commands = [{
          \  'name': 'rundll32',
          \  'args': 'rundll32 url.dll,FileProtocolHandler {uri}',
          \}]
  endif

  " TODO Naming
  function! s:SearchSelectedValue(engine, mode) range " Refs. <http://nanasi.jp/articles/code/screen/visual.html>
    if a:mode ==# 'n'
      let l:word = expand('<cword>')
    else
      let l:tmp = @@
      silent normal! gvy
      let l:word = @@
      let @@ = l:tmp
    endif
    let l:cmd = 'OpenBrowserSearch -' . a:engine . ' ' . l:word
    call histadd('cmd', l:cmd)
    execute l:cmd
  endfunction

  nmap <SID>[Open-browser] <Plug>(openbrowser-smart-search)
  vmap <SID>[Open-browser] <Plug>(openbrowser-smart-search)

  for s:key in keys(s:engines)
    execute 'nnoremap <SID>[open-browser]' . s:key . ' :call <SID>SearchSelectedValue("' . s:engines[s:key] . '", "n")<CR>'
    execute 'vnoremap <SID>[open-browser]' . s:key . ' :call <SID>SearchSelectedValue("' . s:engines[s:key] . '", "v")<CR>'
  endfor
endif " }}}

if s:HasPlugin('operator-camelize') " {{{
  map <SID>[camelize] <Plug>(operator-camelize-toggle)
endif " }}}

if s:HasPlugin('previm') " {{{
  nnoremap <SID>[previm] :<C-u>PrevimOpen<CR>
endif " }}}

if s:HasPlugin('qiita-vim') " {{{
  nnoremap <SID>[qiita]l    :<C-u>Unite qiita<CR>
  nnoremap <SID>[qiita]<CR> :<C-u>Qiita<CR>
  nnoremap <SID>[qiita]c    :<C-u>Qiita<CR>
  nnoremap <SID>[qiita]e    :<C-u>Qiita -e<CR>
  nnoremap <SID>[qiita]d    :<C-u>Qiita -d<CR>
endif " }}}

if s:HasPlugin('restart.vim') " {{{
  command! -bar RestartWithSession let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages' | Restart
endif " }}}

if s:HasPlugin('syntastic') " {{{
  let g:syntastic_check_on_wq = 0 " :wq時にチェックしない
  let g:syntastic_always_populate_loc_list = 1 " :Errorsを実行しなくてもlocation listに表示する
  let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [], 'passive_filetypes': [] }

  let g:syntastic_sh_checkers = ['sh', 'shellcheck', 'bashate']
  let g:syntastic_sh_bashate_args = '-i E002,E003'

  let g:syntastic_vim_checkers = ['vint']
  let g:syntastic_yaml_checkers = ['jsyaml']
  let g:syntastic_markdown_mdl_args = '--no-warning'

  nnoremap <SID>[syntastic] :<C-u>SyntasticCheck<CR>:lwindow<CR>
endif " }}}

if s:HasPlugin('tcomment_vim') " {{{
  let g:tcommentTextObjectInlineComment = 'iC'
  call g:tcomment#DefineType('java', '// %s')
endif " }}}

if s:HasPlugin('unite') " {{{
  let g:unite_enable_ignore_case = 1
  let g:unite_enable_smart_case = 1
  let g:unite_source_grep_max_candidates = 200
  if has('win32')
    let g:unite_source_rec_async_command = ['find', '-L']
  endif
  let s:MyRelativeMove = {'description' : 'move after lcd', 'is_selectable' : 1, 'is_quit' : 0 }

  function! s:MyRelativeMove.func(candidates) " move先を相対パスで指定するaction
    let l:candidate = a:candidates[0]
    let l:dir = isdirectory(l:candidate.word) ? l:candidate.word : fnamemodify(l:candidate.word, ':p:h')
    execute g:unite_kind_cdable_lcd_command fnameescape(l:dir)
    call g:unite#take_action('move', a:candidates)
    call g:unite#force_redraw() " 呼ばないと表示更新されない
  endfunction

  function! s:MyUniteKeymappings()
    " TODO sort. ↓じゃダメ。
    " nnoremap <buffer><expr>S unite#mappings#set_current_filters(empty(unite#mappings#get_current_filters()) ? ['sorter_reverse'] : [])
    nnoremap <buffer><expr>f unite#smart_map('f', unite#do_action('vimfiler'))
    nnoremap <buffer><expr>m unite#smart_map('m', unite#do_action('relative_move'))
    nnoremap <buffer><expr>p unite#smart_map('p', unite#do_action('split'))
    nnoremap <buffer><expr>v unite#smart_map('v', unite#do_action('vsplit'))
    nnoremap <buffer><expr>x unite#smart_map('x', unite#do_action('start'))
  endfunction
  autocmd vimrc FileType unite call s:MyUniteKeymappings()

  call g:unite#custom#action('file,directory', 'relative_move', s:MyRelativeMove)
  call g:unite#custom#alias('file', 'delete', 'vimfiler__delete')
  call g:unite#custom#default_action('directory', 'vimfiler')
  call g:unite#custom#source('bookmark', 'sorters', ['sorter_ftime', 'sorter_reverse'])
  call g:unite#custom#source('file_rec', 'ignore_pattern', '\(png\|gif\|jpeg\|jpg\)$')
  call g:unite#custom#source('file_rec/async', 'ignore_pattern', '\(png\|gif\|jpeg\|jpg\)$')

  nnoremap <SID>[unite]<CR> :<C-u>Unite<CR>
  nnoremap <SID>[unite]b    :<C-u>Unite buffer -buffer-name=buffer<CR>
  nnoremap <SID>[unite]B    :<C-u>Unite bookmark -buffer-name=bookmark<CR>
  nnoremap <SID>[unite]d    :<C-u>Unite directory -buffer-name=directory<CR>
  nnoremap <SID>[unite]f    :<C-u>Unite file -buffer-name=file<CR>
  nnoremap <SID>[unite]g    :<C-u>Unite grep -buffer-name=grep -no-empty<CR>
  nnoremap <SID>[unite]m    :<C-u>Unite mapping -buffer-name=mapping<CR>
  nnoremap <SID>[unite]o    :<C-u>Unite outline -buffer-name=outline -no-quit -vertical -winwidth=30 -direction=botright -no-truncate<CR>
  nnoremap <SID>[unite]O    :<C-u>Unite outline:folding -buffer-name=outline:folding -no-quit -vertical -winwidth=30 -direction=botright -no-truncate<CR>
  nnoremap <SID>[unite]r    :<C-u>Unite resume -buffer-name=resume<CR>
  nnoremap <SID>[unite]R    :<C-u>Unite register -buffer-name=register<CR>
  nnoremap <SID>[unite]s    :<C-u>Unite find -buffer-name=find<CR>
  nnoremap <SID>[unite]w    :<C-u>Unite window -buffer-name=window<CR>
  nnoremap <SID>[unite]T    :<C-u>Unite tab -buffer-name=tab<CR>
  if s:HasPlugin('vimproc') " {{{
    nnoremap <SID>[unite]D :<C-u>Unite directory_rec/async -buffer-name=directory_rec/async<CR>
    nnoremap <SID>[unite]F :<C-u>Unite file_rec/async -buffer-name=file_rec/async<CR>
  else " }}}
    nnoremap <SID>[unite]D :<C-u>Unite directory_rec -buffer-name=directory_rec<CR>
    nnoremap <SID>[unite]F :<C-u>Unite file_rec -buffer-name=file_rec<CR>
  endif
  if s:HasPlugin('unite-tag') " {{{
    nnoremap <SID>[unite]t :<C-u>Unite tag -buffer-name=tag -no-quit -vertical -winwidth=30 -direction=botright -no-truncate<CR>
  endif " }}}
  if s:HasPlugin('yankround') " {{{
    nnoremap <SID>[unite]y :<C-u>Unite yankround -buffer-name=yankround<CR>
  else " }}}
    nnoremap <SID>[unite]y :<C-u>Unite history/yank -buffer-name=histry/yank<CR>
  endif

  if s:HasPlugin('neomru') " {{{
    let g:neomru#directory_mru_limit = 500
    let g:neomru#do_validate = 0
    let g:neomru#file_mru_limit = 500
    let g:neomru#filename_format = ''

    nmap     <SID>[unite]n  <SID>[neomru]
    nnoremap <SID>[neomru]f :<C-u>Unite neomru/file -buffer-name=neomru/file<CR>
    nnoremap <SID>[neomru]d :<C-u>Unite neomru/directory -buffer-name=neomru/directory<CR>
  endif " }}}

  if s:HasPlugin('unite-codic') " {{{ TODO Ignorecase (or Smartcase)
    nnoremap <expr><SID>[unite]c ':<C-u>Unite codic -vertical -winwidth=30 -direction=botright -input=' . expand('<cword>') . '<CR>'
    nnoremap       <SID>[unite]C  :<C-u>Unite codic -vertical -winwidth=30 -direction=botright -start-insert<CR>
  endif " }}}

  if s:HasPlugin('unite-todo') " {{{
    let g:unite_todo_note_suffix = 'md'
    let g:unite_todo_data_directory = s:IsHome() ? '~/Dropbox' : expand('~/Documents')

    function! s:MyTodoGrep(word)
      call histadd('cmd', 'MyTodoGrep '  . a:word)
      execute ':silent grep ' . a:word . ' ' . g:unite_todo_data_directory . '/todo/note/*.md'
    endfunction
    command! -nargs=1 -complete=command MyTodoGrep call <SID>MyTodoGrep(<q-args>)

    noremap        <SID>[todo]a :UniteTodoAddSimple -memo<CR>
    noremap        <SID>[todo]q :UniteTodoAddSimple<CR>
    nnoremap       <SID>[todo]l :Unite todo:undone -buffer-name=todo<CR>
    nnoremap       <SID>[todo]L :Unite todo -buffer-name=todo<CR>
    nnoremap <expr><SID>[todo]g ':<C-u>MyTodoGrep ' . input('MyTodoGrep word: ') . '<CR>'
  endif " }}}
endif " }}}

if s:HasPlugin('vimfiler') " {{{
  let g:vimfiler_safe_mode_by_default = 0 " This variable controls vimfiler enter safe mode by default.
  let g:vimfiler_as_default_explorer = 1 " If this variable is true, Vim use vimfiler as file manager instead of |netrw|.
endif " }}}

if s:HasPlugin('vim-alignta') " {{{
  xnoremap <SID>[alignta]<CR> :Alignta<Space>
  " Alignta for 's'hift align.
  xnoremap <SID>[alignta]s    :Alignta<Space><-<Space>
  " Alignta for 'm'ap. 空白区切りの要素を整列(e.g. nmap hoge fuga)(最初の2要素のみ)(コメント行は除く)
  xnoremap <SID>[alignta]m    :Alignta<Space>v/^" <<0 \s\S/2<CR>
  xnoremap <SID>[alignta]\|   :Alignta<Space>\|<CR>
  xnoremap <SID>[alignta]:    :Alignta<Space>:<CR>
  xnoremap <SID>[alignta],    :Alignta<Space>,<CR>
endif " }}}

if s:HasPlugin('vim-easytags') || 1 " {{{
  let g:easytags_async = 1
  let g:easytags_dynamic_files = 2
endif " }}}

if s:HasPlugin('vim-fakeclip') " {{{
  if (! has('gui_running')) && s:IsHome() " Caution: office msys2(tmux) では不要(出来ている)
    " TODO pasteは効くがyank, deleteは効かない, TODO 矩形モードのコピペがちょっと変になる
    " map y  <Plug>(fakeclip-y)
    " map yy <Plug>(fakeclip-Y)
    " map p  <Plug>(fakeclip-p)
    " map dd <Plug>(fakeclip-dd)
    " map y  <Plug>(fakeclip-screen-y)
    " map yy <Plug>(fakeclip-screen-Y)
    " map p  <Plug>(fakeclip-screen-p)
    " map P  <Plug>(fakeclip-screen-P)
    " map dd <Plug>(fakeclip-screen-dd)
    " map D  <Plug>(fakeclip-screen-D)
  endif
endif " }}}

if s:HasPlugin('vim-gf-user') " {{{
  function! g:GfFile() " Refs. <http://d.hatena.ne.jp/thinca/20140324/1395590910>
    let l:path = expand('<cfile>')
    let l:line = 0
    if l:path =~# ':\d\+:\?$'
      let l:line = matchstr(l:path, '\d\+:\?$')
      let l:path = matchstr(l:path, '.*\ze:\d\+:\?$')
    endif
    if !filereadable(l:path)
      return 0
    endif
    return { 'path': l:path, 'line': l:line, 'col': 0, }
  endfunction
  call g:gf#user#extend('GfFile', 1000)
endif " }}}

if s:HasPlugin('vim-gista') " {{{
  let g:gista#github_user = 'assout'
  let g:gista#update_on_write = 1
  nnoremap <SID>[gista]l    :<C-u>Unite gista<CR>
  nnoremap <SID>[gista]c    :<C-u>Gista<CR>
  nnoremap <SID>[gista]<CR> :<C-u>Gista<CR>
endif " }}}

if s:HasPlugin('vim-json') " {{{
  let g:vim_json_syntax_conceal = 0
endif " }}}

if s:HasPlugin('vim-localrc') " {{{
  let g:localrc_filename = '.vimrc.development'
endif " }}}

if s:HasPlugin('vim-maximizer') " {{{
  let g:maximizer_set_default_mapping = 0
  noremap <SID>[maximizer] :<C-u>MaximizerToggle<CR>
endif " }}}

if s:HasPlugin('vim-migemo') " {{{
  if has('migemo')
    if has('vim_starting') | call g:migemo#SearchChar(0) | endif " Caution: probably slow
    nnoremap <SID>[migemo] g/
  else
    nnoremap <SID>[migemo] :<C-u>Migemo<Space>
  endif
endif " }}}

if s:HasPlugin('vim-operator-replace') " {{{
  map <SID>[replace]  <Plug>(operator-replace)

  if s:HasPlugin('vim-textobj-anyblock') " {{{
    nmap <SID>[replace]b <Plug>(operator-replace)<Plug>(textobj-anyblock-i)
  endif " }}}

  if s:HasPlugin('vim-textobj-between') " {{{
    nmap <SID>[replace]d <Plug>(operator-replace)<Plug>(textobj-between-i)
  endif " }}}

  if s:HasPlugin('vim-textobj-line') " {{{
    nmap <SID>[replace]l <Plug>(operator-replace)<Plug>(textobj-line-i)
  endif " }}}

  if s:HasPlugin('vim-textobj-url') " {{{
    nmap <SID>[replace]u <Plug>(operator-replace)<Plug>(textobj-url-i)
  endif " }}}

  " Caution: aは<Space>paeとかできなくなるのでやらない
  " if s:HasPlugin('vim-textobj-parameter') " {{{
  "   nmap <SID>[replace]a <Plug>(operator-replace)<Plug>(textobj-parameter-i)
  " endif " }}}
endif " }}}

if s:HasPlugin('vim-operator-surround') " {{{
  " Refs. <http://d.hatena.ne.jp/syngan/20140301/1393676442>
  " Refs. <http://www.todesking.com/blog/2014-10-11-surround-vim-to-operator-vim/>
  let g:operator#surround#blocks = deepcopy(g:operator#surround#default_blocks)
  call add(g:operator#surround#blocks['-'], { 'block' : ['<!-- ', ' -->'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['c']} )

  map <SID>[surround-a] <Plug>(operator-surround-append)
  map <SID>[surround-d] <Plug>(operator-surround-delete)
  map <SID>[surround-r] <Plug>(operator-surround-replace)

  if s:HasPlugin('vim-textobj-anyblock') " {{{
    nmap <SID>[surround-a]b <Plug>(operator-surround-append)<Plug>(textobj-anyblock-a)
    nmap <SID>[surround-d]b <Plug>(operator-surround-delete)<Plug>(textobj-anyblock-a)
    nmap <SID>[surround-r]b <Plug>(operator-surround-replace)<Plug>(textobj-anyblock-a)
  endif " }}}

  if s:HasPlugin('vim-textobj-between') " {{{
    nmap <SID>[surround-a]d <Plug>(operator-surround-append)<Plug>(textobj-between-a)
    nmap <SID>[surround-d]d <Plug>(operator-surround-delete)<Plug>(textobj-between-a)
    nmap <SID>[surround-r]d <Plug>(operator-surround-replace)<Plug>(textobj-between-a)
  endif " }}}

  if s:HasPlugin('vim-textobj-line') " {{{
    nmap <SID>[surround-a]l <Plug>(operator-surround-append)<Plug>(textobj-line-a)
    nmap <SID>[surround-d]l <Plug>(operator-surround-delete)<Plug>(textobj-line-a)
    nmap <SID>[surround-r]l <Plug>(operator-surround-replace)<Plug>(textobj-line-a)
  endif " }}}

  if s:HasPlugin('vim-textobj-url') " {{{
    nmap <SID>[surround-a]u <Plug>(operator-surround-append)<Plug>(textobj-url-a)
    " TODO no block matches to the region となる
    nmap <SID>[surround-d]u <Plug>(operator-surround-delete)<Plug>(textobj-url-a)
    " TODO appendの動きになってしまう
    nmap <SID>[surround-r]u <Plug>(operator-surround-replace)<Plug>(textobj-url-a)
  endif " }}}

  " Caution: aはsaawとかできなくなるのでやらない
  " if s:HasPlugin('vim-textobj-parameter') " {{{
  "   nmap <SID>[surround-a]a <Plug>(operator-surround-append)<Plug>(textobj-parameter-a)
  "   nmap <SID>[surround-d]a <Plug>(operator-surround-delete)<Plug>(textobj-parameter-a)
  "   nmap <SID>[surround-r]a <Plug>(operator-surround-replace)<Plug>(textobj-parameter-a)
  " endif " }}}
endif " }}}

if s:HasPlugin('vim-quickrun') " {{{
  " TODO プレビューウィンドウで開けないか(szで閉じやすいので)
  nnoremap <SID>[quickrun] :<C-u>QuickRun<CR>
  let g:quickrun_config = {
        \  'plantuml' :{
        \    'type' : 'my_plantuml'
        \  },
        \  'my_plantuml' : {
        \    'command': 'plantuml',
        \    'exec': ['%c %s', 'eog %s:p:r.png'],
        \    'outputter': 'null'
        \  },
        \}
endif " }}}

if s:HasPlugin('vim-ref') " {{{
  " TODO プレビューウィンドウで開けないか(szで閉じやすいので)
  let g:ref_man_lang = 'ja_JP.UTF-8'
  let g:ref_noenter = 1
  let g:ref_cache_dir = expand('~/.cache/.vim_ref_cache')
  " TODO デフォルトに一括追加の指定方法(現状は上書き)
  " TODO msys2 vimでmarkdownのgene開けない
  " TODO Windows gvimでshのman開けない
  let g:ref_detect_filetype = {
        \  'markdown' : 'gene',
        \  'sh' : 'man',
        \}

  autocmd vimrc FileType ref resize 5

  if executable('elinks') || executable('w3m') || executable('links')|| executable('lynx')
    let g:ref_source_webdict_sites = {
          \  'je'  : { 'url': 'http://dictionary.infoseek.ne.jp/jeword/%s', 'line': 15},
          \  'ej'  : { 'url': 'http://dictionary.infoseek.ne.jp/ejword/%s', 'line': 15},
          \  'wiki': { 'url': 'http://ja.wikipedia.org/wiki/%s', 'line': 23},
          \}
    let g:ref_source_webdict_sites.default = 'ej'
    let g:ref_source_webdict_use_cache = 1

    nnoremap <SID>[ref]w<CR> :<C-u>Ref webdict<Space>
    nnoremap <SID>[ref]wj    :<C-u>Ref webdict je<Space>
    nnoremap <SID>[ref]we    :<C-u>Ref webdict ej<Space>
  endif

  " TODOs for ref-gene
  " TODO 選択範囲の単語で検索
  " TODO unite-actioinでyank
  " TODO unite重い
  " TODO コマンド履歴に残したい
  " TODO 和英ができない
  " TODO キャッシュ化されている？
endif " }}}

if s:HasPlugin('vim-singleton') && has('gui_running') " {{{
  let g:singleton#group = $USERNAME " For MSYS2 (グループ名はなんでもよい？)
  let g:singleton#opener = 'vsplit'
  call g:singleton#enable()
endif " }}}

if s:HasPlugin('vim-submode') " {{{ Caution: prefix含めsubmode nameが長すぎるとInvalid argumentとなる(e.g. prefixを<submode>とするとエラー)
  call g:submode#enter_with('winsize', 'n', '', '<C-w><', '5<C-w><')
  call g:submode#enter_with('winsize', 'n', '', '<C-w>>', '5<C-w>>')
  call g:submode#enter_with('winsize', 'n', '', '<C-w>-', '5<C-w>-')
  call g:submode#enter_with('winsize', 'n', '', '<C-w>+', '5<C-w>+')
  call g:submode#map('winsize', 'n', '', '<', '5<C-w><')
  call g:submode#map('winsize', 'n', '', '>', '5<C-w>>')
  call g:submode#map('winsize', 'n', '', '-', '5<C-w>-')
  call g:submode#map('winsize', 'n', '', '+', '5<C-w>+')

  call g:submode#enter_with('scroll', 'n', '', 'zh', 'zh')
  call g:submode#enter_with('scroll', 'n', '', 'zl', 'zl')
  call g:submode#map('scroll', 'n', '', 'h', 'zh')
  call g:submode#map('scroll', 'n', '', 'l', 'zl')
  call g:submode#map('scroll', 'n', '', 'H', '10zh')
  call g:submode#map('scroll', 'n', '', 'L', '10zl')

  call g:submode#enter_with('buffer', 'n', '', '[subP]b', ':bprevious<CR>')
  call g:submode#enter_with('buffer', 'n', '', '[subN]b', ':bnext<CR>')
  call g:submode#map('buffer', 'n', '', 'k', ':bprevious<CR>')
  call g:submode#map('buffer', 'n', '', 'j', ':bnext<CR>')
  call g:submode#map('buffer', 'n', '', 'K', ':bfirst<CR>')
  call g:submode#map('buffer', 'n', '', 'J', ':blast<CR>')

  " TODO 先頭と末尾に行き過ぎたときエラーでsubmode抜けたくない(循環するとややこしい?)
  call g:submode#enter_with('args', 'n', '', '[subP]a', ':previous<CR>')
  call g:submode#enter_with('args', 'n', '', '[subN]a', ':next<CR>')
  call g:submode#map('args', 'n', '', 'k', ':previous<CR>')
  call g:submode#map('args', 'n', '', 'j', ':next<CR>')
  call g:submode#map('args', 'n', '', 'K', ':first<CR>')
  call g:submode#map('args', 'n', '', 'J', ':last<CR>')

  " TODO 先頭と末尾に行き過ぎたときエラーでsubmode抜けたくない(循環するとややこしい?)
  call g:submode#enter_with('quickfix', 'n', '', '[subP]q', ':cprevious<CR>')
  call g:submode#enter_with('quickfix', 'n', '', '[subN]q', ':cnext<CR>')
  call g:submode#map('quickfix', 'n', '', 'k', ':cprevious<CR>')
  call g:submode#map('quickfix', 'n', '', 'j', ':cnext<CR>')
  call g:submode#map('quickfix', 'n', '', 'K', ':cfirst<CR>')
  call g:submode#map('quickfix', 'n', '', 'J', ':clast<CR>')
  call g:submode#map('quickfix', 'n', '', '<C-k>', ':cpfile<CR>')
  call g:submode#map('quickfix', 'n', '', '<C-j>', ':cnfile<CR>')

  " TODO 先頭と末尾に行き過ぎたときエラーでsubmode抜けたくない(循環するとややこしい?)
  call g:submode#enter_with('loclist', 'n', '', '[subP]l', ':lprevious<CR>')
  call g:submode#enter_with('loclist', 'n', '', '[subN]l', ':lnext<CR>')
  call g:submode#map('loclist', 'n', '', 'k', ':lprevious<CR>')
  call g:submode#map('loclist', 'n', '', 'j', ':lnext<CR>')
  call g:submode#map('loclist', 'n', '', 'K', ':lfirst<CR>')
  call g:submode#map('loclist', 'n', '', 'J', ':llast<CR>')
  call g:submode#map('loclist', 'n', '', '<C-k>', ':lpfile<CR>')
  call g:submode#map('loclist', 'n', '', '<C-j>', ':lnfile<CR>')

  " TODO 先頭と末尾に行き過ぎたときエラーでsubmode抜けたくない(循環するとややこしい?)
  call g:submode#enter_with('diff', 'n', '', '[subP]c', '[c')
  call g:submode#enter_with('diff', 'n', '', '[subN]c', ']c')
  call g:submode#map('diff', 'n', '', 'k', '[c')
  call g:submode#map('diff', 'n', '', 'j', ']c')
endif " }}}

if s:HasPlugin('vim-textmanip') " {{{
  xmap <C-j> <Plug>(textmanip-move-down)
  xmap <C-k> <Plug>(textmanip-move-up)
  xmap <C-h> <Plug>(textmanip-move-left)
  xmap <C-l> <Plug>(textmanip-move-right)
endif " }}}

if s:HasPlugin('vim-textobj-between') " {{{
  " textobj-functionとかぶるので変更(textobj-functionのマッピングはVrapperと合わせたいのでこちらを変える)
  let g:textobj_between_no_default_key_mappings = 1 " 'd'istanceに変える。。
  omap id <Plug>(textobj-between-i)
  omap ad <Plug>(textobj-between-a)
  vmap id <Plug>(textobj-between-i)
  vmap ad <Plug>(textobj-between-a)
endif " }}}

if s:HasPlugin('vim-textobj-entire') " {{{
  " TODO カーソル行位置は戻るが列位置が戻らない。<:help restore-position>もうまくいかない
  nmap yae yae``
  nmap yie yie``
  nmap =ae =ae``
  nmap =ie =ie``
endif " }}}

if s:HasPlugin('vim-textobj-parameter') " {{{ Vrapper textobj-argsと合わせる('a'rguments)
  let g:textobj_parameter_no_default_key_mappings = 1
  omap ia <Plug>(textobj-parameter-i)
  omap aa <Plug>(textobj-parameter-a)
  vmap ia <Plug>(textobj-parameter-i)
  vmap aa <Plug>(textobj-parameter-a)
endif " }}}

if s:HasPlugin('vim-watchdogs') " {{{
  nnoremap <SID>[watchdogs] :<C-u>WatchdogsRun watchdogs_checker/
  nnoremap <SID>[Watchdogs] :<C-u>WatchdogsRun<CR>

  let g:watchdogs_check_BufWritePost_enable = 1
  " TODO quickfix開くとhookが動かない。暫定で開かないようにしている
  " TODO xmllint
  let g:quickrun_config = {
        \  'watchdogs_checker/_' : {
        \    'outputter/quickfix/open_cmd' : '',
        \    'runner/vimproc/updatetime' : 30,
        \    'hook/echo/enable' : 1,
        \    'hook/echo/output_success' : 'No Errors Found.',
        \    'hook/echo/output_failure' : 'Errors Found!',
        \    'hook/qfsigns_update/enable_exit': 1,
        \  },
        \}
  " TODO 画面が小さいときにエラー出ると"Press Enter ..."が表示されうざいのでWorkaroundする
  let g:quickrun_config['watchdogs_checker/_']['hook/quickfix_status_enable/enable_exit'] = has('gui_running') ? 1 : 0

  " TODO extendはパフォーマンス悪いかも
  call extend(g:quickrun_config, {
        \  'sh/watchdogs_checker' : {
        \    'type'
        \      : executable('shellcheck') ? 'watchdogs_checker/shellcheck'
        \      : executable('checkbashisms') ? 'watchdogs_checker/checkbashisms'
        \      : executable('bashate') ? 'watchdogs_checker/bashate'
        \      : executable('sh') ? 'watchdogs_checker/sh'
        \      : '',
        \    },
        \})
  if s:IsOffice()
    if &shell =~# '.*cmd.exe'
      let g:quickrun_config['watchdogs_checker/shellcheck']['exec'] = 'cmd /c "chcp.com 65001 | %c %o %s:p"'
    else
      " FIXME Windows + GVim + set shell=bashのときうまく動かない(msys2 vimは問題なし)
      let g:quickrun_config['watchdogs_checker/shellcheck']['exec'] = 'bash -c "chcp.com 65001 > /dev/null; %c %o %s:p"'
    endif
  endif

  call extend(g:quickrun_config, {
        \  'markdown/watchdogs_checker': {
        \    'type'
        \      : executable('mdl') ? 'watchdogs_checker/mdl'
        \      : executable('textlint') ? 'watchdogs_checker/textlint'
        \      : executable('redpen') ? 'watchdogs_checker/redpen'
        \      : executable('eslint-md') ? 'watchdogs_checker/eslint-md'
        \      : '',
        \   },
        \  'watchdogs_checker/redpen' : {
        \    'command' : 'redpen',
        \    'cmdopt'  : '-c ~/dotfiles/redpen-conf-en.xml',
        \    'exec'    : '%c %o %s:p 2> /dev/null',
        \  },
        \})

  call g:watchdogs#setup(g:quickrun_config)
endif " }}}

if s:HasPlugin('yankround') " {{{ TODO 未保存のバッファでpするとエラーがでる(Could not get security context security...) <http://lingr.com/room/vim/archives/2014/04/13>
  let g:yankround_dir = '~/.cache/yankround'
endif " }}}

" }}}1

" # After {{{1

filetype plugin indent on " Caution: Required for NeoBundle
syntax on

" :qで誤って終了してしまうのを防ぐためcloseに置き換える
cabbrev q <C-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'close' : 'q')<CR>
" Don't (re)highlighting the last search pattern on reloading.
nohlsearch
" Enable matchit
source $VIMRUNTIME/macros/matchit.vim

" Colorshceme settings {{{

if s:HasPlugin('vim-hybrid')
  function! s:MyDefineHighlight()
    highlight clear SpellBad
    highlight clear SpellCap
    highlight clear SpellRare
    highlight clear SpellLocal
    highlight SpellBad   cterm=underline ctermfg=Red gui=undercurl guisp=Red
    highlight SpellCap   cterm=underline ctermfg=Blue gui=undercurl guisp=Blue
    highlight SpellRare  cterm=underline ctermfg=Magenta gui=undercurl guisp=Magenta
    highlight SpellLocal cterm=underline ctermfg=Cyan gui=undercurl guisp=Cyan
  endfunction
  autocmd vimrc ColorScheme hybrid :call <SID>MyDefineHighlight()
  colorscheme hybrid
else
  colorscheme default " Caution: 明示実行しないと全角ハイライトがされない
endif

" }}}

" FileType autocmds. Caution: filetype on以降に実施しないといけないためここで定義。Refs. <http://d.hatena.ne.jp/kuhukuhun/20081108/1226156420> {{{

" 改行時の自動コメント継続をやめる(o, O コマンドでの改行時のみ)。 Caution: 当ファイルのsetでも設定しているがftpluginで上書きされてしまうためここで設定している
autocmd vimrc FileType * setlocal textwidth=0 formatoptions-=o
" Enable spell on markdown file, To hard tab. TODO suでsourceしたときには呼ばれないのでexpandtabになってしまう
autocmd vimrc FileType markdown highlight! def link markdownItalic LineNr | setlocal spell noexpandtab
" To hard tab
autocmd vimrc FileType java setlocal noexpandtab
if executable('python')
  autocmd vimrc FileType json command! -buffer -range=% MyFormatJson <line1>,<line2>!python -m json.tool
endif
if executable('xmllint')
  autocmd vimrc FileType xml command! -buffer -range=% MyFormatXml <line1>,<line2>!xmllint --format --recover - 2>/dev/null
endif

" }}}

" }}}1

" vim:nofoldenable:

