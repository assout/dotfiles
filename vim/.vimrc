" # Introduction {{{1
"
" ## Principles
" - Keep it short and simple, stupid! (500step以下に留めたい)
" - To portable! (e.g. office/home/jenkins, vim/gvim/vrapper, development/server)
" - デフォルト環境(サーバなど)での操作時に混乱するカスタマイズはしない(;と:の入れ替えとか)(sだけはつぶしちゃう)
" - キーマッピングでは、スペースキーをプラグイン用、sキーをvim標準のプレフィックスとする
"
" ## Caution
" - executeコマンドをキーマッピングするとき<C-u>をつけること(e.g. nnoremap hoge :<C-u>fuga)
"   (誤って範囲指定しないようにするためなので、範囲指定してほしい場合はつけないこと) <http://d.hatena.ne.jp/e_v_e/20150101/1420067539>
" - vim-emacscommandline pluginは使わない。(commandlineでのescがキー入力待ちになるため)
" - '|' は :normal コマンドの一部として処理されるので、このコマンドの後に他のコマンドを続けて書けません。Refs. <:help normal>
" - 'noremap <expr> {lhs} {rhs}'のようにするとVrapperが有効にならない(noremap <expr>{lhs} {rhs}とするとOK、またはnoremap <silent><expr> {lhs} {rhs}もOK)
" - vimrcの設定ファイルはLinuxでは~/.vim, ~/.vimrcにする。Windowsでは~/vimfiles,~/_vimrcにする。(MSYS2も考慮するため)
" - IME offはLinuxはim_control.vimで、WindowsはAutoHotKeyを使う(kaoriya GVimはデフォルトでなる)
" - executable()は遅いらしいので使わない
"
" ## TODOs
" - TODO: たまにIMEで変換候補確定後に先頭の一文字消えることがある @win
" - TODO: neocompleteでたまに日本語入力が変になる
" - TODO: setでワンライナーでIF文書くと以降のsetがVrapperで適用されない
" - TODO: GVim@officeで複数ファイルを開いたときの<C-w>h,lが遅い(プラグインなし、vimrc空でも再現)
" }}}1

" # Begin {{{1
" vint: -ProhibitSetNoCompatible
set nocompatible " Caution: アンチパターンらしいがvim -uで起動した時エラーとならないように設定している
set encoding=utf-8 " inner encoding(before the scriptencoding)
scriptencoding utf-8 " before multi byte
if filereadable(expand('~/.vimrc.local')) | source ~/.vimrc.local | endif

augroup vimrc
  autocmd!
augroup END
" }}}1

" # Let defines {{{1
" Caution: script localだとPlugの設定に渡せない。buffer localだとうまく行かないことがある
let g:is_linux     = has('unix') && !has('win32unix')
let g:is_linux_gui = g:is_linux && has('gui_running')
let g:is_linux_cui = g:is_linux && !has('gui_running')
let g:is_win       = has('win32') || has('win32unix')
let g:is_win_gui   = g:is_win && has('gui_running')
let g:is_win_cui   = g:is_win && !has('gui_running')
let g:is_jenkins   = exists('$BUILD_NUMBER')
let g:is_home      = $USERNAME ==# 'oji' || $USERNAME ==# 'porinsan'
let g:is_office    = $USERNAME ==# 'admin'

let s:dotvim_path = g:is_jenkins ? expand('$WORKSPACE/.vim') : expand('~/.vim')
let s:plugged_path = s:dotvim_path . '/plugged'

let g:is_bash = 1 " shellのハイライトをbash基準にする。Refs: <:help sh.vim>
let g:maplocalleader = ',' " For todo.txt TODO: <Space> or s にしたい
" Note: msys2でリンク、ファイルパス開けるようにする " TODO: ファイルパスの形式によって開けない(OK:<file:\\D:\admin\Desktop>, NG:<file:\\d/admin/Desktop>)
if g:is_win_cui
  let g:netrw_browsex_viewer = 'start rundll32 url.dll,FileProtocolHandler'
endif
let g:netrw_liststyle = 3 " netrwのデフォルト表示スタイル変更
let g:xml_syntax_folding = 1

" Disable unused built-in plugins {{{ Note: netrwは非プラグイン環境で必要(VimFiler使えない環境)
" let g:loaded_2html_plugin    = 1 " Refs: <:help 2html> Caution: ちょいちょい使う
let g:loaded_getscriptPlugin = 1
" let g:loaded_gzip            = 1 " Caution: ヘルプが引けなくなることがあるのでコメントアウト
let g:loaded_matchparen      = 1 " Refs: <:help matchparen>
let g:loaded_tar             = 1
let g:loaded_tarPlugin       = 1
let g:loaded_vimball         = 1
let g:loaded_vimballPlugin   = 1
let g:loaded_zip             = 1
let g:loaded_zipPlugin       = 1
" }}}

if g:is_win_cui " For mintty. Note: Gnome terminalでは不可なので別途autocomdで実施している。
  let &t_ti .= "\e[1 q"
  let &t_SI .= "\e[5 q"
  let &t_EI .= "\e[1 q"
  let &t_te .= "\e[0 q"
endif
" }}}1

" # Functions {{{1
function! s:ChangeTabstep(size) " Caution: undoしても&tabstopの値は戻らないので注意
  if &l:expandtab
    " Refs: <:help restore-position>
    normal! msHmt
    execute '%substitute@\v^(%( {' . &l:tabstop . '})+)@\=repeat(" ", len(submatch(1)) / ' . &l:tabstop . ' * ' . a:size . ')@eg' | normal! 'tzt`s
  endif
  let &l:tabstop = a:size
  let &l:shiftwidth = a:size
endfunction

function! s:HasPlugin(plugin)
  return isdirectory(expand(s:plugged_path . '/' . a:plugin)) && &loadplugins
endfunction

function! s:InsertString(pos, str) range " Note: 引数にスペースを含めるにはバックスラッシュを前置します Refs: <:help f-args>
  execute a:firstline . ',' . a:lastline . 'substitute/' . a:pos . '/' . substitute(a:str, '/', '\\/', 'g')
endfunction

function! s:IsPluginEnabled()
  return isdirectory(expand(s:dotvim_path . '/autoload/')) && &loadplugins
endfunction

function! s:RestoreCursorPosition()
  let l:ignore_filetypes = ['gitcommit']
  if index(l:ignore_filetypes, &l:filetype) >= 0 | return | endif
  if line("'\"") > 1 && line("'\"") <= line('$')
    normal! g`"
  endif
endfunction

function! s:ShowExplorer(...)
  let l:path = expand(a:0 == 0 ? '%:h' : a:1)
  if g:is_win
    execute '!explorer.exe ''' . fnamemodify(l:path, ':p:s?^/\([cd]\)?\1:?:gs?/?\\?') . ''''
  else
    execute '!nautilus ' . l:path . '&'
  endif
endfunction

function! s:ToggleExpandTab() " Caution: undoしても&expandtabの値は戻らないので注意
  setlocal expandtab! | retab " Note: 意図しない空白も置換されてしまうため、retab!(Bang) は使わない
  if ! &expandtab " <http://vim-jp.org/vim-users-jp/2010/04/30/Hack-143.html>
    " Refs: <:help restore-position>
    normal! msHmt
    execute '%substitute@^\v(%( {' . &l:tabstop . '})+)@\=repeat("\t", len(submatch(1))/' . &l:tabstop . ')@e' | normal! 'tzt`s
  endif
endfunction

function! s:TodoGrep(word)
  let l:todo_note_directory = expand('~/Documents/todo/notes')
  call histadd('cmd', 'TodoGrep '  . a:word)
  " Note: a:wordはオプションが入ってくるかもなので""で囲まない
  execute ':silent grep -r ' . a:word . ' ' . l:todo_note_directory . '/*'
endfunction
" }}}1

" # Commands {{{1
command! -range -nargs=1 Prefix <line1>,<line2>call <SID>InsertString('^', <f-args>)
command! -range -nargs=1 Suffix <line1>,<line2>call <SID>InsertString('$', <f-args>)

command! -bang BufClear %bdelete<bang>
command! -nargs=1 ChangeTabstep call <SID>ChangeTabstep(<q-args>)
command! -range=% DeleteBlankLine <line1>,<line2>v/\S/d | nohlsearch
" Compairing the difference between the pre-edit file. Refs: `:help DiffOrig`
command! DiffOrig vertical new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis
command! -nargs=? -range=% Mattertee :<line1>,<line2>write !mattertee <args>
command! SaveScrach execute 'save ~/Today/' . strftime('/%Y%m%d_%H%M%S') . '.md'
command! -nargs=? -complete=dir ShowExplorer call <SID>ShowExplorer(<f-args>)
command! -nargs=1 TodoGrep call <SID>TodoGrep(<q-args>)
command! ToggleExpandTab call <SID>ToggleExpandTab()
command! -range=% TrimSpace <line1>,<line2>s/[ \t]\+$// | nohlsearch | normal! ``
" Show highlight item name under a cursor. Refs: [Vimでハイライト表示を調べる](http://rcmdnk.github.io/blog/2013/12/01/computer-vim/)
command! VimShowHlItem echomsg synIDattr(synID(line("."), col("."), 1), "name")
" }}}1

" # Options {{{1
set background=dark
set backspace=indent,eol,start
set cindent
set nobackup
set clipboard=unnamed,unnamedplus
set cmdheight=1
" set cryptmethod=blowfish2 " Caution: Comment out for performance
set diffopt& diffopt+=vertical
set expandtab
set fileencodings=utf-8,ucs-bom,iso-2020-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932,latin,latin1,utf-8
set foldlevelstart=0
set foldmethod=marker
" TODO: Windows Gvimで~からのパスをgrepすると結果ファイルが表示できない(D:\d\hoge\fuga のように解釈されてるっぽい)(/d/admin/hogeも同様にNG)
" Caution: Windowsで'hoge\*'という指定するとNo such file or directoryと表示される。('/'区切りの場合うまくいく)
set grepprg=grep\ -nH\ --binary-files=without-match\ --exclude-dir=.git
set helplang=ja,en " keywordprgで日本語優先にしたいため
set hidden
set history=200
set hlsearch
set ignorecase
set iminsert=1 " Note: msys2 gvim で挿入モードでIMEオンになってしまうのを防ぐため
set incsearch
" set iskeyword-=_ " TODO: やっぱやめるので_区切りのテキストオブジェクトが別途ほしい
set indentkeys-=0# " <<,>>で#をインデントできるようにする
set keywordprg=:help " vim-refとの兼ね合いでここではhelp
set list
set listchars=tab:>.,trail:_,extends:\
set laststatus=2
set lazyredraw " マクロなどを実行中は描画を中断
set nonumber " Note: tmuxなどでのコピペ時にないほうがやりやすい
set nrformats="" " インクリメンタル/デクリメンタルを常に10進数として扱う
set ruler
set scrolloff=5
" Caution: Windowsでgrep時バックスラッシュだとパスと解釈されないことがあるために設定
" Caution: GUI, CUIでのtags利用時のパスセパレータ統一のために設定
" Caution: 副作用があることに注意(Refs: <https://github.com/vim-jp/issues/issues/43>)
set shellslash
set shiftwidth=2
set showcmd
set showtabline=1
set shortmess& shortmess+=atTOI
set sidescrolloff=5
set smartcase
set softtabstop=0
let &spellfile = expand(g:is_linux ? '~/Dropbox/spell/en.utf-8.add' : '~/Documents/spell/en.utf-8.add')
set spelllang=en,cjk " スペルチェックで日本語は除外する
set splitbelow
set splitright
let &swapfile = g:is_win ? 0 : &swapfile " swapfile作成有無(offにするとvimfilerでのネットワークフォルダ閲覧が高速化するかも(効果は不明))(共有ディレクトリ等にswapファイル残さないように)
let &tags = (has('path_extra') ? './.tags;'  : './.tags') . ',' . &tags
set tabstop=2
set title
set ttimeoutlen=0
if has('persistent_undo')
  set undodir=~/.cache/undo
  set undofile
else
  set noundofile
endif
set wildmenu
" set wildmode=list:longest " Caution: 微妙なのでやめる
set nowrap
set nowrapscan
" }}}1

" # Key-mappings {{{1
" Normal, Visual mode basic mappings {{{
nnoremap Y y$
" Note: <CR>でマッピングするとVrapperで有効にならない
nnoremap <C-m> i<CR><Esc>
" Open folding. Note: デフォルトでも'foldopen'に"hor"があればlで開くがカーソル移動できないとき(jsonなどでよくある)にうまくいかないのでここで指定。 Refs: <http://leafcage.hateblo.jp/entry/2013/04/24/053113>
nnoremap <expr>l foldclosed('.') != -1 ? 'zo' : 'l'
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
noremap  <SID>[shortcut]d <Nop>
map      <SID>[shortcut]i <SID>[insert]
noremap  <SID>[shortcut]m <Nop>
nmap     <SID>[shortcut]o <SID>[open]
noremap  <SID>[shortcut]r <Nop>
" Note: autocmd FileTypeイベントを発効する。本来setfiletypeは不要だがプラグインが設定するファイルタイプのとき(e.g. aws.json)、FileType autocmdが呼ばれないため、指定している。
if has('gui_running')
  nnoremap <silent><SID>[shortcut]u :<C-u>source $MYVIMRC<Bar>:source $MYGVIMRC<Bar>execute "setfiletype " . &l:filetype<Bar>:filetype detect<CR>
else
  " TODO: DRY(map内でif文意外とうまくいかない)
  nnoremap <silent><SID>[shortcut]u :<C-u>source $MYVIMRC<Bar>execute "setfiletype " . &l:filetype<Bar>:filetype detect<CR>
endif
nnoremap <expr><SID>[shortcut]] ':ptag ' . expand("<cword>") . '<CR>'

" TODO: To plugin or function " TODO: .(dot) repeat " TODO: Refactor
noremap       <SID>[insert]  <Nop>
noremap <expr><SID>[insert]p ':Prefix ' . input('prefix:') . '<CR>'
noremap       <SID>[insert]-  :Prefix - <CR>
noremap       <SID>[insert]#  :Prefix # <CR>
noremap       <SID>[insert]>  :Prefix > <CR>
noremap       <SID>[insert]f  :Prefix file://<CR>
noremap <expr><SID>[insert]s ':Suffix ' . input('suffix:') . '<CR>'
noremap <expr><SID>[insert]a ':Suffix \ @' . input('author:') . '<CR>'
noremap       <SID>[insert]l  :Suffix \<Space>\ <CR>

nnoremap <SID>[open] <Nop>
" Note: fugitiveで対象とするためresolveしている " Caution: Windows GUIのときシンボリックリンクを解決できない
nnoremap <expr><SID>[open]v ':<C-u>edit ' . resolve(expand($MYVIMRC)) . '<CR>'
" }}}

" Like unimpaired plugin mappings {{{
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
" TODO: <C-M-h>での一単語Backspace(<C-w>はできている)
" }}}

" Command-line mode mappings {{{
" TODO: 一単語Delete
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
if s:IsPluginEnabled()
  if has('vim_starting')
    let &runtimepath = g:is_win_gui || g:is_jenkins ? s:dotvim_path . ',' . &runtimepath : &runtimepath
  endif
  call g:plug#begin(s:plugged_path)
  " Caution: `for : "*"`としたときfiletypeが設定されない拡張子のとき呼ばれない(e.g. foo.log)。(そもそも`for:"*"は遅延ロードしている意味がないためやらない)
  " General {{{
  Plug 'AndrewRadev/linediff.vim', {'on' : ['Linediff']}
  Plug 'AndrewRadev/switch.vim', {'on' : ['Switch', 'SwitchReverse']} " Ctrl+aでやりたいが不可。できたとしてもspeeddating.vimと競合
  Plug 'LeafCage/vimhelpgenerator', {'on' : ['VimHelpGenerator', 'VimHelpGeneratorVirtual']}
  " Note: なんかlazy化するのはだるいのであきらめる
  Plug 'Shougo/denite.nvim'
        \ | Plug 'Jagua/vim-denite-ghq'
        \ | Plug 'LeafCage/yankround.vim'
        \ | Plug 'Shougo/unite-outline'
        \ | Plug 'Shougo/unite.vim'
        \ | Plug 'Shougo/vimfiler.vim'
        \ | Plug 'glidenote/memolist.vim'
        \ | Plug 'koron/codic-vim'
        \ | Plug 'rhysd/unite-codic.vim'
        \ | Plug 'sgur/unite-everything', g:is_linux ? {'on' : []} : {}
        \ | Plug 'tsukkee/unite-tag'
  Plug 'Shougo/neocomplete', has('lua') ? {} : {'on' : []}
        \ | Plug 'ujihisa/neco-look'
        \ | Plug 'Konfekt/FastFold'
  Plug 'Shougo/neomru.vim', g:is_jenkins ? {'on' : []} : {}
  Plug 'Shougo/neosnippet.vim'
        \ | Plug 'Shougo/neosnippet-snippets'
  Plug 'Shougo/vimproc', g:is_jenkins ? {'on' : []} : g:is_win_gui ? {'on' : []} : g:is_linux ? {'do' : 'make -f make_unix.mak'} : {'do' : 'make -f make_cygwin.mak'} " TODO mingw64でなくmsysじゃないと失敗しそう Refs:<http://togetter.com/li/900570>
  Plug 'aklt/plantuml-syntax', {'for' : 'plantuml'}
  Plug 'chaquotay/ftl-vim-syntax', {'for' : 'html.ftl'}
  Plug 'elzr/vim-json', {'for' : 'json'} " For json filetype.
  Plug 'fuenor/im_control.vim', g:is_linux ? {} : {'on' : []}
  Plug 'freitass/todo.txt-vim', {'for' : 'todo'}
  Plug 'godlygeek/tabular', {'for' : 'markdown'}
        \ | Plug 'plasticboy/vim-markdown', {'for' : 'markdown'} " TODO 最近のvimではset ft=markdown不要なのにしているため、autocmdが2回呼ばれてしまう TODO いろいろ不都合有るけどcodeブロックのハイライトが捨てがたい TODO syntaxで箇条書きのネストレベル2のコードブロックの後もコードブロック解除されない
  " FIXME: windows(cui,gui)で動いてない。linux未確認
  Plug 'haya14busa/vim-migemo', {'on' : ['Migemo', '<Plug>(migemo-']}
  Plug 'haya14busa/vim-auto-programming'
  Plug 'heavenshell/vim-jsdoc', {'for' : 'javascript'}
  Plug 'hyiltiz/vim-plugins-profile', {'on' : []} " It's not vim plugin.
  Plug 'https://gist.github.com/assout/524c4ae96928b3d2474a.git', {'dir' : g:plug_home . '/hz_ja.vim/plugin', 'rtp' : '..', 'on' : ['Hankaku', 'Zenkaku', 'ToggleHZ']}
  Plug 'itchyny/calendar.vim', {'on' : 'Calendar'}
  Plug 'itchyny/vim-parenmatch'
  Plug 'junegunn/vim-easy-align', {'on' : ['<Plug>(LiveEasyAlign)']}
  " Plug 'kamichidu/vim-edit-properties'
  Plug 'kana/vim-gf-user', {'on' : '<Plug>(gf-user-'}
  Plug 'kana/vim-submode'
  Plug 'https://github.com/m-kat/aws-vim', {'for' : 'template'} " Note: `user/reponam`形式だとPlugInstall時に取得できない
  Plug 'marijnh/tern_for_vim', g:is_linux ? {'do' : 'npm install', 'for' : ['javascript']} : {'on' : []} " Note: windowsで動かない
  Plug 'mattn/benchvimrc-vim' , {'on' : 'BenchVimrc'}
  Plug 'mattn/emmet-vim', {'for' : ['markdown', 'html']} " markdownのurlタイトル取得:<C-y>a コメントアウトトグル : <C-y>/
  Plug 'medihack/sh.vim', {'for' : 'sh'} " For function block indentation, caseラベルをインデントしたい場合、let g:sh_indent_case_labels = 1
  Plug 'moll/vim-node', g:is_win ? {'on' : []} : {} " Lazyできない TODO: たまにmarkdown開くとき2secくらいかかるっぽい(2分探索で見ていった結果)
  Plug 'moznion/vim-ltsv', {'for' : 'ltsv'} 
  Plug 'nathanaelkane/vim-indent-guides', {'on' : ['IndentGuidesEnable', 'IndentGuidesToggle']}
  " Plug 'othree/yajs.vim' " Note: vim-jaavascriptのようにシンタックスエラーをハイライトしてくれない
  " Plug 'pangloss/vim-javascript' " Note: syntax系のプラグインはlazyできない TODO es6対応されてない？
  Plug 'schickling/vim-bufonly', {'on' : ['BufOnly', 'BOnly']}
  Plug 'szw/vim-maximizer', {'on' : ['Maximize', 'MaximizerToggle']} " Windowの最大化・復元
  Plug 't9md/vim-textmanip', {'on' : '<Plug>(textmanip-'} " TODO: 代替探す(日本語化けるのと、たまに不要な空白が入るため)
  Plug 'thinca/vim-localrc', g:is_win ? {'on' :[]} : {'for' : 'vim'}
  Plug 'thinca/vim-qfreplace', {'on' : 'Qfreplace'} " grepした結果を置換
  Plug 'thinca/vim-quickrun', {'on' : ['QuickRun', 'WatchdogsRun']}
        \ | Plug 'osyo-manga/shabadou.vim', {'on' : ['QuickRun', 'WatchdogsRun']}
        \ | Plug 'dannyob/quickfixstatus', {'on' : ['QuickRun', 'WatchdogsRun']}
        \ | Plug 'KazuakiM/vim-qfsigns', {'on' : ['QuickRun', 'WatchdogsRun']}
        \ | Plug 'osyo-manga/vim-watchdogs', {'on' : ['QuickRun', 'WatchdogsRun']}
  Plug 'thinca/vim-ref', {'on' : ['Ref', '<Plug>(ref-']}
        \ | Plug 'Jagua/vim-ref-gene', {'on' : ['Ref', '<Plug>(ref-']} " TODO: Unite sourceの遅延ロード
  Plug 'thinca/vim-singleton' " Note: 遅延ロード不可
  Plug 'tomtom/tcomment_vim' " TODO: markdownが`<!-- hoge --->`となるが`<!--- hoge -->`では？
  " Caution: on demand不可。Refs: <https://github.com/junegunn/vim-plug/issues/164>
  Plug 'tpope/vim-fugitive'
        \ | Plug 'junegunn/gv.vim'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-speeddating'
  Plug 'tpope/vim-unimpaired'
  Plug 'tyru/capture.vim', {'on' : 'Capture'}
  Plug 'tyru/open-browser.vim', {'for' : 'markdown', 'on' : ['<Plug>(openbrowser-', 'OpenBrowser', 'OpenBrowserSearch', 'OpenBrowserSmartSearch', 'PrevimOpen']}
        \ | Plug 'kannokanno/previm', {'tag' : '1.7.1', 'for' : 'markdown', 'on' : 'PrevimOpen'} " TODO: Pending: 最新(2db88f0e0577620cb9fd484f6a33602385bdd6ac)だとmsys2で開けない
  Plug 'tyru/restart.vim', {'on' : ['Restart', 'RestartWithSession']} " TODO: CUI上でも使いたい
  Plug 'vim-jp/vimdoc-ja'
  Plug 'powerman/vim-plugin-AnsiEsc', {'on' : 'AnsiEsc'} " TODO: msysだとうまく動かない
  Plug 'vim-scripts/DirDiff.vim', {'on' : 'DirDiff'} " TODO: 文字化けする
  Plug 'vim-scripts/HybridText', {'for' : 'hybrid'}
  Plug 'vim-scripts/SQLUtilities', {'for' : 'sql'}
        \ | Plug 'vim-scripts/Align', {'for' : 'sql'}
  Plug 'wellle/tmux-complete.vim'
  Plug 'xolox/vim-misc', {'for' : ['vim', 'sh', 'javascript']}
        \ | Plug 'xolox/vim-shell', {'for' : ['vim', 'sh', 'javascript']}
        \ | Plug 'xolox/vim-easytags', {'for' : ['vim', 'sh', 'javascript']}
  " }}}

  " User Operators {{{ Caution: 遅延ロードするといろいろ動かなくなる
  Plug 'kana/vim-operator-user'
        \ | Plug 'haya14busa/vim-operator-flashy'
        \ | Plug 'kana/vim-operator-replace'
        \ | Plug 'rhysd/vim-operator-surround'
        \ | Plug 'tyru/operator-camelize.vim'
  " }}}

  " User Textobjects {{{
  Plug 'kana/vim-textobj-user'
        \ | Plug 'kana/vim-textobj-entire'
        \ | Plug 'kana/vim-textobj-function'
        \ | Plug 'kana/vim-textobj-indent'
        \ | Plug 'kana/vim-textobj-line'
        \ | Plug 'mattn/vim-textobj-url'
        \ | Plug 'osyo-manga/vim-textobj-multiblock'
        \ | Plug 'sgur/vim-textobj-parameter'
        \ | Plug 'thinca/vim-textobj-between'
        \ | Plug 'thinca/vim-textobj-comment'
        \ | Plug 'thinca/vim-textobj-function-javascript'
  " }}}

  " Colorschemes {{{
  Plug 'w0ng/vim-hybrid'
  " }}}
  call g:plug#end()

  " Caution: Workaround. msys2からgvim起動したときkaoriyaのを入れないといけないため
  if g:is_win_gui | let &runtimepath = &runtimepath . ',~/Tools/vim74-kaoriya-win64/plugins/vimproc' | endif

  " Plugin prefix mappings {{{
  map  <Space>              <SID>[plugin]
  map  <SID>[plugin]a       <SID>[align]
  map  <SID>[plugin]c       <SID>[camelize]
  nmap <SID>[plugin]d       <SID>[denite]
  map  <SID>[plugin]h       <SID>[markdown_h]
  nmap <SID>[plugin]H       <SID>[markdown_H]
  map  <SID>[plugin]i       <SID>[indentguide]
  map  <SID>[plugin]l       <SID>[markdown_l]
  nmap <SID>[plugin]L       <SID>[markdown_L]
  nmap <SID>[plugin]m       <SID>[memolist]
  map  <SID>[plugin]o       <SID>[open-browser]
  map  <SID>[plugin]O       <SID>[Open-browser]
  nmap <SID>[plugin]p       <SID>[previm]
  nmap <SID>[plugin]q       <SID>[quickrun]
  map  <SID>[plugin]r       <SID>[replace]
  map  <SID>[plugin]t       <SID>[todo]
  nmap <SID>[plugin]w       <SID>[watchdogs]
  nmap <SID>[plugin]W       <SID>[Watchdogs]
  nmap <SID>[plugin]/       <SID>[migemo]
  " TODO: <SID>つけれない(つけないと"[s"と入力した時にキー入力待ちが発生してしまう)
  nmap <SID>[plugin][       [subP]
  nmap <SID>[plugin]]       [subN]

  map  <SID>[plugin]<Space> <SID>[sub_plugin]
  nmap <SID>[sub_plugin]r   <SID>[ref]

  " Caution: K,gf系は定義不要だがプラグインの遅延ロードのため定義している
  nmap K                <Plug>(ref-keyword)
  nmap gf               <Plug>(gf-user-gf)
  nmap gF               <Plug>(gf-user-gF)
  nmap <C-w>f           <Plug>(gf-user-<C-w>f)
  nmap <C-w><C-f>       <Plug>(gf-user-<C-w><C-f>)
  nmap <C-w>F           <Plug>(gf-user-<C-w>F)
  nmap <C-w>gf          <Plug>(gf-user-<C-w>gf)
  nmap <C-w>gF          <Plug>(gf-user-<C-w>gF)
  map  y                <Plug>(operator-flashy)
  nmap Y                <Plug>(operator-flashy)$
  nmap p                <Plug>(yankround-p)
  nmap P                <Plug>(yankround-P)
  nmap <C-p>            <Plug>(yankround-prev)
  nmap <C-n>            <Plug>(yankround-next)
  nmap +                <SID>[switch]
  nmap -                <SID>[Switch]
  map  <SID>[shortcut]a <SID>[surround-a]
  map  <SID>[shortcut]d <SID>[surround-d]
  map  <SID>[shortcut]r <SID>[surround-r]
  map  <SID>[shortcut]m <SID>[maximizer]
  " }}}
else " Vim-Plug有効の場合勝手にされる
  filetyp indent on
  syntax on
endif

if s:HasPlugin('calendar.vim') " {{{
  let g:calendar_google_calendar = g:is_linux ? 1 : 0
  let g:calendar_google_task = g:is_linux ? 1 : 0
endif " }}}

" TODO win,gvimでhas('python3')が0になる
if s:HasPlugin('denite.nvim') " {{{
  call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>')
  call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>')

  nnoremap       <SID>[denite]b  :<C-u>Denite buffer<CR>
  nnoremap       <SID>[denite]B  :<C-u>Denite unite:bookmark<CR>
  nnoremap <expr><SID>[denite]c ':<C-u>Denite unite:codic -direction=botright -input=' . expand('<cword>') . '<CR>'
  nnoremap       <SID>[denite]C  :<C-u>Denite unite:codic -direction=botright -start-insert<CR>
  " TODO: asyncのほう使いたいが日本語文字化けする
  nnoremap       <SID>[denite]e  :<C-u>Denite unite:everything<CR>
  nnoremap       <SID>[denite]d  :<C-u>DeniteBufferDir directory_rec<CR>
  nnoremap       <SID>[denite]f  :<C-u>DeniteBufferDir file_rec<CR>
  nnoremap       <SID>[denite]l  :<C-u>Denite unite:line -no-quit<CR>
  nnoremap       <SID>[denite]o  :<C-u>Denite unite:outline -no-quit -direction=botright<CR>
  nnoremap       <SID>[denite]O  :<C-u>Denite unite:outline:folding -no-quit -direction=botright<CR>
  nnoremap       <SID>[denite]r  :<C-u>Denite file_mru<CR>
  nnoremap       <SID>[denite]s  :<C-u>Denite unite:neosnippet<CR>
  nnoremap       <SID>[denite]y  :<C-u>Denite unite:yankround<CR>

  if s:HasPlugin('neomru.vim') " {{{
    " Note: Windows GVimで、ネットワーク上のファイルがあるとUnite候補表示時に遅くなる？(msys2は大丈夫っぽい) -> '^\(\/\/\|fugitive\)'
    " Note: Windows(msys2)で、ネットワーク上のファイルを開くと変になる
    " Note: Deprecatedだが(Uniteの関数呼ぶのが推奨)Unite未ロードの場合があるためこっちを使用
    let g:neomru#file_mru_ignore_pattern = '^\(\/\/\|fugitive\)' " or '^fugitive'
    let g:neomru#directory_mru_ignore_pattern = '^\(\/\/\|fugitive\)' " or '^fugitive'
    let g:neomru#directory_mru_limit = 500
    let g:neomru#do_validate = 0 " Cautioin: 有効にしちゃうとvim終了時結構遅くなる TODO たまに正常なファイルも消えちゃうっポイ
    let g:neomru#file_mru_limit = 500
    let g:neomru#filename_format = ''
    let g:neomru#follow_links = 1
  endif " }}}
endif " }}}

if s:HasPlugin('HybridText') " {{{
  autocmd vimrc BufRead,BufNewFile *.{txt,mindmap} nested setfiletype hybrid
endif " }}}

if s:HasPlugin('vim-indent-guides') " {{{
  nnoremap <SID>[indentguide] :<C-u>IndentGuidesToggle<CR>
endif " }}}

if has('kaoriya') " {{{
  let g:plugin_dicwin_disable = 1 " dicwin plugin無効
  let g:plugin_scrnmode_disable = 1 " scrnmode plugin無効
else
  command! -nargs=0 CdCurrent cd %:p:h
  command! DiffOrig vertical new | set buftype=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
endif " }}}

if s:HasPlugin('memolist.vim') " {{{
  let g:memolist_filename_prefix_none = 1
  let g:memolist_memo_suffix = 'md'
  let g:memolist_path = expand('~/memolist.wiki')
  let g:memolist_template_dir_path = g:memolist_path

  function! s:MemoGrep(word)
    call histadd('cmd', 'MemoGrep '  . a:word)
    " Caution: a:wordはオプションが入ってくるかもなので""で囲まない
    execute ':silent grep -r --exclude-dir=_book ' . a:word . ' ' . g:memolist_path
  endfunction
  command! -nargs=1 -complete=command MemoGrep call <SID>MemoGrep(<q-args>)

  nnoremap       <SID>[memolist]a  :<C-u>MemoNew<CR>
  nnoremap       <SID>[memolist]l  :<C-u>Denite file_rec:~/memolist.wiki<CR>
  nnoremap <expr><SID>[memolist]g ':<C-u>MemoGrep ' . input('MemoGrep word: ') . '<CR>'
endif " }}}

if s:HasPlugin('neocomplete') " {{{
  let g:neocomplete#enable_at_startup = g:is_linux ? 1 : 0 " TODO: win gvimでダイアログが一瞬出る。
  let g:neocomplete#text_mode_filetypes = { 'markdown': 1 } " TODO: どうなる？
endif " }}}

if s:HasPlugin('neosnippet.vim') " {{{
  let g:neosnippet#snippets_directory='~/.vim/snippets/'
  " Note:exampleでは<C-k>に割り当ててるが、行末まで消去にあててるので。
  imap <C-l> <Plug>(neosnippet_expand_or_jump)
  smap <C-l> <Plug>(neosnippet_expand_or_jump)
  autocmd vimrc FileType neosnippet setlocal noexpandtab
endif " }}}

if s:HasPlugin('open-browser.vim') " {{{
  let g:openbrowser_search_engines = extend(get(g:, 'openbrowser_search_engines', {}), {
        \    'translate' : 'https://translate.google.com/?hl=ja#auto/ja/{query}',
        \    'stackoverflow' : 'http://stackoverflow.com/search?q={query}',
        \  }) " Note: vimrcリロードでデフォルト値が消えてしまわないようにしている
  if g:is_win_cui
    let g:openbrowser_browser_commands = [{'name' : 'rundll32', 'args' : 'rundll32 url.dll,FileProtocolHandler {uri}'}]
  endif
  let s:engines = {
        \  'a' : 'alc',
        \  'd' : 'devdocs',
        \  'g' : 'google',
        \  's' : 'stackoverflow',
        \  't' : 'translate',
        \  'w' : 'wikipedia-ja',
        \}

  function! s:SearchSelected(engine, mode) range " Refs: <http://nanasi.jp/articles/code/screen/visual.html>
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

  for s:key in keys(s:engines)
    execute 'nnoremap <SID>[open-browser]' . s:key . ' :call <SID>SearchSelected("' . s:engines[s:key] . '", "n")<CR>'
    execute 'vnoremap <SID>[open-browser]' . s:key . ' :call <SID>SearchSelected("' . s:engines[s:key] . '", "v")<CR>'
  endfor

  nmap <SID>[Open-browser] <Plug>(openbrowser-smart-search)
  vmap <SID>[Open-browser] <Plug>(openbrowser-smart-search)
endif " }}}

if s:HasPlugin('operator-camelize.vim') " {{{
  map <SID>[camelize] <Plug>(operator-camelize-toggle)
endif " }}}

if s:HasPlugin('previm') " {{{
  nnoremap <SID>[previm] :<C-u>PrevimOpen<CR>
endif " }}}

if s:HasPlugin('restart.vim') " {{{
  command! -bar RestartWithSession let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages' | Restart
endif " }}}

if s:HasPlugin('switch.vim') " {{{
  " Note: 定義順は優先度を考慮する(範囲の広い定義は後ろに定義する) " TODO: Dictionary定義はSwitchReverse効かない " TODO: 入れ子のときおかしくなる(e.g. [foo[bar]] ) " TODO: undoするとカーソル位置が行頭になっちゃう
  let g:switch_custom_definitions = [
        \  ['foo', 'bar', 'baz', 'qux', 'quux', 'corge', 'grault', 'garply', 'waldo', 'fred', 'plugh', 'xyzzy', 'thud', ],
        \  ['hoge', 'piyo', 'fuga', 'hogera', 'hogehoge', 'moge', 'hage', ],
        \  ['public', 'protected', 'private', ],
        \  ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sut'],
        \  ['日', '月', '火', '水', '木', '金', '土'],
        \  {
        \     '\v\$\{(.{-})\}' : '"${\1}"',
        \     '\v"\$\{(.{-})\}"' : '''${\1}''',
        \     '\v''\$\{(.{-})\}''' : '${\1}',
        \  },
        \  {
        \     '\v\$\((.{-})\)' : '"$(\1)"',
        \     '\v"\$\((.{-})\)"' : '''$(\1)''',
        \     '\v''\$\((.{-})\)''' : '$(\1)',
        \  },
        \  {
        \     '\v"(.{-})"' : '''\1''',
        \     '\v''(.{-})''' : '"\1"',
        \  },
        \  {
        \     '\v「(.{-})」' : '【\1】',
        \     '\v【(.{-})】' : '「\1」',
        \  },
        \]

  " Note: 以下は""<->''より優先されてしまうので設定しない
  " \  ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'],
  " \  ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],

  " FIXME: 空白区切りの文字列をクォート切り替え
  " \  {
  " \     '\v\$(.{-})\s' : '"$\1"',
  " \     '\v"\$(.{-})\s"' : '''$\1''',
  " \     '\v''\$(.{-})''' : '$\1',
  " \  },

  nnoremap <SID>[switch] :<C-u>Switch<CR>
  nnoremap <SID>[Switch] :<C-u>SwitchReverse<CR>
endif " }}}

if s:HasPlugin('todo.txt-vim') " {{{
  " TODO: Unite source化など
  nnoremap       <SID>[todo]l  :<C-u>edit ~/Documents/todo/todo.txt<CR>
  nnoremap       <SID>[todo]L  :<C-u>edit ~/Documents/todo/done.txt<CR>
  nnoremap       <SID>[todo]r  :<C-u>edit ~/Documents/todo/report.txt<CR>
  nnoremap <expr><SID>[todo]g ':<C-u>TodoGrep ' . input('TodoGrep word: ') . '<CR>'
endif " }}}

if s:HasPlugin('vimfiler.vim') " {{{
  " TODO: msys2でxでのシステム関連付けが開かない(uniteの箇所にもコメントしているがcygstart呼ばれているのが原因)
  let g:vimfiler_safe_mode_by_default = 0 " This variable controls vimfiler enter safe mode by default.
  " Caution: Uniteをオンデマンドにしている関係上有効にするとエラーが出るケースが出てくる
  let g:vimfiler_as_default_explorer = 0 " If this variable is true, Vim use vimfiler as file manager instead of |netrw|.
endif " }}}

if s:HasPlugin('vim-auto-programming') " {{{
  set omnifunc=autoprogramming#complete " Note: tmux-complete.vimとかぶることに注意
endif " }}}

if s:HasPlugin('vim-easy-align') " {{{
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xmap <SID>[align] <Plug>(LiveEasyAlign)

  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap <SID>[align] <Plug>(LiveEasyAlign)
endif " }}}

if s:HasPlugin('vim-easytags') " {{{
  let g:easytags_async = has('gui_running') ? 0 : 1 " TODO: GUIのときバックグラウンドプロセスがたまっていっちゃうっポイ
  let g:easytags_dynamic_files = 2
endif " }}}

if s:HasPlugin('vim-gf-user') " {{{
  function! g:GfFile() " Refs: <http://d.hatena.ne.jp/thinca/20140324/1395590910>
    let l:path = expand('<cfile>')
    let l:line = 0
    if l:path =~# ':\d\+:\?$'
      let l:line = matchstr(l:path, '\d\+:\?$')
      let l:path = matchstr(l:path, '.*\ze:\d\+:\?$')
    endif
    if !filereadable(l:path)
      let l:mdpath = expand('%:p:h') . '/' . l:path . '.md'
      if filereadable(l:mdpath)
        return { 'path': l:mdpath, 'line': l:line, 'col': 0, }
      endif
      return 0
    endif
    return { 'path': l:path, 'line': l:line, 'col': 0, }
  endfunction
  autocmd vimrc User vim-gf-user call g:gf#user#extend('GfFile', 1000)
endif " }}}

if s:HasPlugin('vim-json') " {{{
  let g:vim_json_syntax_conceal = 0
endif " }}}

if s:HasPlugin('vim-localrc') " {{{
  " TODO: ghq対応後無効
  let g:localrc_filename = '.vimrc.development'
endif " }}}

if s:HasPlugin('vim-markdown') " {{{
  let g:vim_markdown_folding_disabled = 1
  let g:vim_markdown_emphasis_multiline = 0

  function! s:VimMarkdownSettings() " Refs: <:help restore-position>
    " Note: commentsを空にして箇条書きの継続を無効、indentexprを空にして不要な箇条書きのインデント補正を無効にする
    setlocal comments= indentexpr=

    nnoremap <buffer><SID>[markdown_l]     :.HeaderIncrease<CR>
    vnoremap <buffer><SID>[markdown_l]      :HeaderIncrease<CR>`<v`>
    nnoremap <buffer><SID>[markdown_L] msHmt:HeaderIncrease<CR>'tzt`s

    nnoremap <buffer><SID>[markdown_h]     :.HeaderDecrease<CR>
    vnoremap <buffer><SID>[markdown_h]      :HeaderDecrease<CR>`<v`>
    nnoremap <buffer><SID>[markdown_H] msHmt:HeaderDecrease<CR>'tzt`s

    " ファイルパスを開けなくなるので無効化
    unmap <buffer> gx
    " デフォルト変えたくないので無効化
    unmap <buffer> ge
  endfunction
  autocmd vimrc FileType markdown call s:VimMarkdownSettings()
endif " }}}

if s:HasPlugin('vim-maximizer') " {{{
  let g:maximizer_set_default_mapping = 0
  noremap <SID>[maximizer] :<C-u>MaximizerToggle<CR>
endif " }}}

if s:HasPlugin('vim-migemo') " {{{
  " Caution: probably slow
  autocmd vimrc User vim-migemo if has('migemo') | call g:migemo#SearchChar(0) | endif
  nnoremap <SID>[migemo] :<C-u>Migemo<Space>
endif " }}}

if s:HasPlugin('vim-operator-replace') " {{{
  map  <SID>[replace] <Plug>(operator-replace)
  " Caution: aは<Space>paeとかできなくなるのでやらない
  " nmap <SID>[replace]a <Plug>(operator-replace)<Plug>(textobj-parameter-i)
  nmap <SID>[replace]d <Plug>(operator-replace)<Plug>(textobj-between-i)
  nmap <SID>[replace]l <Plug>(operator-replace)<Plug>(textobj-line-i)
  nmap <SID>[replace]b <Plug>(operator-replace)<Plug>(textobj-multiblock-i)
  nmap <SID>[replace]u <Plug>(operator-replace)<Plug>(textobj-url-i)
endif " }}}

if s:HasPlugin('vim-operator-surround') " {{{
  " TODO: 空白区切りがしたい(なぜか今でも2スペースならできる)

  map <SID>[surround-a] <Plug>(operator-surround-append)
  map <SID>[surround-d] <Plug>(operator-surround-delete)
  map <SID>[surround-r] <Plug>(operator-surround-replace)

  " Caution: aはsaawとかできなくなるのでやらない
  " nmap <SID>[surround-a]a <Plug>(operator-surround-append)<Plug>(textobj-parameter-a)
  " nmap <SID>[surround-d]a <Plug>(operator-surround-delete)<Plug>(textobj-parameter-a)
  " nmap <SID>[surround-r]a <Plug>(operator-surround-replace)<Plug>(textobj-parameter-a)

  nmap <SID>[surround-a]b <Plug>(operator-surround-append)<Plug>(textobj-multiblock-a)
  nmap <SID>[surround-d]b <Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)
  nmap <SID>[surround-r]b <Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)

  nmap <SID>[surround-a]d <Plug>(operator-surround-append)<Plug>(textobj-between-a)
  nmap <SID>[surround-d]d <Plug>(operator-surround-delete)<Plug>(textobj-between-a)
  nmap <SID>[surround-r]d <Plug>(operator-surround-replace)<Plug>(textobj-between-a)

  nmap <SID>[surround-a]l <Plug>(operator-surround-append)<Plug>(textobj-line-a)
  nmap <SID>[surround-d]l <Plug>(operator-surround-delete)<Plug>(textobj-line-a)
  nmap <SID>[surround-r]l <Plug>(operator-surround-replace)<Plug>(textobj-line-a)

  nmap <SID>[surround-a]u <Plug>(operator-surround-append)<Plug>(textobj-url-a)
endif " }}}

if s:HasPlugin('vim-quickrun') " {{{
  " TODO: プレビューウィンドウで開けないか(szで閉じやすいので)
  " TODO: 基本システムの関連付けで開くようにする？
  nnoremap <SID>[quickrun]  :<C-u>QuickRun<CR>

  let g:quickrun_config = { '_' : { 'runner' : has('patch-7.4.2298') ? 'job' : 'vimproc', 'runner/vimproc/updatetime' : 60 } }
  let g:quickrun_config['javascript'] = { 'command': 'node' }
  let g:quickrun_config['html'] = { 'command': g:is_linux ? 'google-chrome' : 'chrome', 'outputter': 'null' }
  let g:quickrun_config['plantuml'] = { 'command': g:is_linux ? 'google-chrome' : 'chrome', 'outputter': 'null' }
  let g:quickrun_config['markdown'] = { 'type': 'markdown/markdown-to-slides' }
  let g:quickrun_config['markdown/markdown-to-slides'] = { 'command': 'markdown-to-slides', 'outputter': 'browser'}
  if g:is_win
    let g:quickrun_config['markdown/markdown-to-slides']['runner'] = 'shell'
    let g:quickrun_config['markdown/markdown-to-slides']['exec'] = ['tmp=/tmp/%s:t.html \&\& %c %s -o \$tmp %o \&\& chrome.exe \$tmp']
  endif
endif " }}}

if s:HasPlugin('vim-ref') " {{{
  " TODO: プレビューウィンドウで開けないか(szで閉じやすいので)
  let g:ref_man_lang = 'ja_JP.UTF-8'
  let g:ref_noenter = 1
  let g:ref_cache_dir = expand('~/.cache/.vim_ref_cache')
  " TODO: デフォルトに一括追加の指定方法(現状は上書き) " TODO: shでman呼ばれない @msys2 " TODO: Windows gvimでshのman開けない
  let g:ref_detect_filetype = {
        \  'markdown' : 'gene',
        \  'sh' : 'man',
        \}

  autocmd vimrc FileType ref resize 5

  " Webdict settings {{{
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
  " }}}

  " TODO: 選択範囲の単語で検索 " TODO: unite-actioinでyank " TODO: unite重い " TODO: コマンド履歴に残したい " TODO: 和英ができない " TODO: キャッシュ化されている？ " TODO: あいまい検索的なことがしたい(z=でスペル候補表示するみたいなのを楽に) " TODO: Uniteソースのほうに統一したほうがよい？
  if s:HasPlugin('vim-ref-gene') " {{{
    nnoremap <expr> <SID>[ref]g ':<C-u>Ref gene<Space>' . expand('<cword>') . '<CR>'
    nnoremap <expr> <SID>[ref]G ':<C-u>Ref gene<Space>'
  endif " }}}
endif " }}}

if s:HasPlugin('vim-singleton') " {{{
  let g:singleton#group = $USERNAME " For MSYS2 (グループ名はなんでもよい？)
  let g:singleton#opener = 'vsplit'
  if has('gui_running') | call g:singleton#enable() | endif
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

  " TODO: args,quickfix,loclist,diff先頭と末尾に行き過ぎたときエラーでsubmode抜けたくない(循環するとややこしい?)
  call g:submode#enter_with('args', 'n', '', '[subP]a', ':previous<CR>')
  call g:submode#enter_with('args', 'n', '', '[subN]a', ':next<CR>')
  call g:submode#map('args', 'n', '', 'k', ':previous<CR>')
  call g:submode#map('args', 'n', '', 'j', ':next<CR>')
  call g:submode#map('args', 'n', '', 'K', ':first<CR>')
  call g:submode#map('args', 'n', '', 'J', ':last<CR>')

  call g:submode#enter_with('quickfix', 'n', '', '[subP]q', ':cprevious<CR>')
  call g:submode#enter_with('quickfix', 'n', '', '[subN]q', ':cnext<CR>')
  call g:submode#map('quickfix', 'n', '', 'k', ':cprevious<CR>')
  call g:submode#map('quickfix', 'n', '', 'j', ':cnext<CR>')
  call g:submode#map('quickfix', 'n', '', 'K', ':cfirst<CR>')
  call g:submode#map('quickfix', 'n', '', 'J', ':clast<CR>')
  call g:submode#map('quickfix', 'n', '', '<C-k>', ':cpfile<CR>')
  call g:submode#map('quickfix', 'n', '', '<C-j>', ':cnfile<CR>')

  call g:submode#enter_with('loclist', 'n', '', '[subP]l', ':lprevious<CR>')
  call g:submode#enter_with('loclist', 'n', '', '[subN]l', ':lnext<CR>')
  call g:submode#map('loclist', 'n', '', 'k', ':lprevious<CR>')
  call g:submode#map('loclist', 'n', '', 'j', ':lnext<CR>')
  call g:submode#map('loclist', 'n', '', 'K', ':lfirst<CR>')
  call g:submode#map('loclist', 'n', '', 'J', ':llast<CR>')
  call g:submode#map('loclist', 'n', '', '<C-k>', ':lpfile<CR>')
  call g:submode#map('loclist', 'n', '', '<C-j>', ':lnfile<CR>')

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
  xmap id <Plug>(textobj-between-i)
  xmap ad <Plug>(textobj-between-a)
endif " }}}

if s:HasPlugin('vim-textobj-entire') " {{{
  " TODO: カーソル行位置は戻るが列位置が戻らない。<:help restore-position>もうまくいかない " TODO: カーソル行が戻ったときメッセージが消えてしまう
  nmap yae yae``
  nmap yie yie``
  nmap =ae =ae``
  nmap =ie =ie``
endif " }}}

if s:HasPlugin('vim-textobj-multiblock') " {{{
  let g:textobj_multiblock_blocks = [
        \  [ '`', '`', 1 ],
        \  [ '*', '*', 1 ],
        \  [ '_', '_', 1 ],
        \  [ '\~', '\~', 1 ],
        \  [ '|', '|', 1 ],
        \]
  omap ib <Plug>(textobj-multiblock-i)
  omap ab <Plug>(textobj-multiblock-a)
  xmap ib <Plug>(textobj-multiblock-i)
  xmap ab <Plug>(textobj-multiblock-a)
endif " }}}

if s:HasPlugin('vim-textobj-parameter') " {{{
  " Vrapper textobj-argsと合わせる('a'rguments)
  let g:textobj_parameter_no_default_key_mappings = 1
  omap ia <Plug>(textobj-parameter-i)
  omap aa <Plug>(textobj-parameter-a)
  xmap ia <Plug>(textobj-parameter-i)
  xmap aa <Plug>(textobj-parameter-a)
endif " }}}

if s:HasPlugin('vim-unimpaired') " {{{
  autocmd vimrc VimEnter * nested
        \   execute 'nunmap [u'
        \ | execute 'nunmap [uu'
        \ | execute 'nunmap ]u'
        \ | execute 'nunmap ]uu'
endif " }}}

if s:HasPlugin('vim-watchdogs') " {{{
  " TODO: msys2からgvim開くとチェック時エラーはく(新規にgvim開いたときだけっぽい)(パスの解釈が変になってるぽい)
  nnoremap <SID>[watchdogs] :<C-u>WatchdogsRun<CR>
  nnoremap <SID>[Watchdogs] :<C-u>WatchdogsRun watchdogs_checker/

  " TODO: quickfix開くとhookが動かない。暫定で開かないようにしている " TODO: xmllint
  let g:quickrun_config['watchdogs_checker/_'] = {
        \  'outputter/quickfix/open_cmd' : '',
        \  'hook/echo/enable' : 1,
        \  'hook/echo/output_success' : 'No Errors Found.',
        \  'hook/echo/output_failure' : 'Errors Found!',
        \  'hook/qfsigns_update/enable_exit': 1,
        \}
  " Note: 画面が小さいときにエラー出ると"Press Enter ..."が表示されうざいのでWorkaroundする
  let g:quickrun_config['watchdogs_checker/_']['hook/quickfix_status_enable/enable_exit'] = has('gui_running') ? 1 : 0
  let g:quickrun_config['sh/watchdogs_checker'] = { 'type' : 'watchdogs_checker/shellcheck' }
  let g:quickrun_config['markdown/watchdogs_checker'] = { 'type' : 'watchdogs_checker/mdl' }
  " let g:quickrun_config['markdown/watchdogs_checker'] = { 'type' : 'watchdogs_checker/textlint' }
  let g:quickrun_config['watchdogs_checker/eslint'] = {'command' : 'eslint_d' }

  if g:is_win_gui
    let g:quickrun_config['watchdogs_checker/shellcheck'] = {'exec' : 'cmd /c "chcp.com 65001 | %c %o %s:p"'}
    let g:quickrun_config['watchdogs_checker/mdl'] = {'exec' : 'cmd /c "chcp.com 65001 | %c %o %s:p"'}
  elseif g:is_win_cui
    let g:quickrun_config['watchdogs_checker/shellcheck'] = {'exec' : 'chcp.com 65001 | %c %o %s:p'}
    let g:quickrun_config['watchdogs_checker/mdl'] = {'exec' : 'chcp.com 65001 | %c %o %s:p'}
  endif

  autocmd vimrc User vim-watchdogs call g:watchdogs#setup(g:quickrun_config)
endif " }}}

if s:HasPlugin('yankround.vim') " {{{
  let g:yankround_dir = '~/.cache/yankround'
endif " }}}
" }}}1

" # Auto-commands {{{1
" Caution: 当セクションはVim-Plugより後に記述する必要がある(Vim-Plugの記述でfiletype onされる。autocomd FileTypeの処理はftpluginの処理より後に実行させたいため) Refs: <http://d.hatena.ne.jp/kuhukuhun/20081108/1226156420>
augroup vimrc
  " QuickFixを自動で開く " Caution: grep, makeなど以外では呼ばれない (e.g. watchdogs, syntastic)
  autocmd QuickfixCmdPost [^l]* nested if len(getqflist()) != 0  | copen | endif
  autocmd QuickfixCmdPost l*    nested if len(getloclist(0)) != 0 | lopen | endif
  " QuickFix内<CR>で選択できるようにする(上記QuickfixCmdPostでも設定できるが、watchdogs, syntasticの結果表示時には呼ばれないため別で設定)
  " TODO: quickfix表示されたままwatchdogs再実行するとnomodifiableのままとなることがある
  autocmd BufReadPost quickfix,loclist setlocal modifiable nowrap | nnoremap <silent><buffer>q :quit<CR>
  " Set freemaker filetype
  autocmd BufNewFile,BufRead *.ftl nested setlocal filetype=html.ftl " Caution: setfiletypeだとuniteから開いた時に有効にならない
  " Restore cusor position
  autocmd BufWinEnter * call s:RestoreCursorPosition()

  " Change cursor shape in different modes. Refs: <http://vim.wikia.com/wiki/Change_cursor_shape_in_different_modes>
  if g:is_linux_cui
    autocmd VimEnter,InsertLeave * silent execute '!echo -ne "\e[2 q"' | redraw!
    autocmd InsertEnter,InsertChange *
          \ if     v:insertmode == 'i' | silent execute '!echo -ne "\e[6 q"' | redraw! |
          \ elseif v:insertmode == 'r' | silent execute '!echo -ne "\e[4 q"' | redraw! | endif
    autocmd VimLeave * silent execute '!echo -ne "\e[ q"' | redraw!
  endif

  " Note: ftpluginで上書きされてしまうことがあるためここで設定している" Note: formatoptionsにo含むべきか難しい
  autocmd FileType * setlocal formatoptions-=c formatoptions-=t
  autocmd FileType go setlocal noexpandtab
  autocmd FileType hybrid setlocal noexpandtab
  autocmd FileType java setlocal noexpandtab
  autocmd FileType javascript command! -buffer FixEslint :call system("eslint --fix " . expand("%")) | :edit!
  " Note: aws.json を考慮して*jsonとしている
  autocmd FileType *json
        \   setlocal foldmethod=syntax foldlevel=99
        \ | command! -buffer -range=% FormatJson <line1>,<line2>!python -m json.tool
  " Note: 箇条書きの2段落目のインデントがおかしくなることがあったのでcinkeysを空にする(行に:が含まれてたからかも)
  autocmd FileType markdown
        \   setlocal spell tabstop=4 shiftwidth=4 cinkeys=''
        \ | command! -buffer FixTextlint :call system("textlint --fix " . expand("%")) <BAR> :edit!
  " Note: Windowsでxmllintはencode指定しないとうまくいかないことがある
  autocmd FileType xml
        \   setlocal foldmethod=syntax foldlevel=99
        \ | command! -buffer -range=% FormatXml <line1>,<line2>!xmllint --encode utf-8 --format --recover - 2>/dev/null
  " autocmd Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
  " autocmd VimEnter,WinEnter * match DoubleByteSpace /　/
augroup END
" }}}1

" # After {{{1
nohlsearch " Don't (re)highlighting the last search pattern on reloading.
source $VIMRUNTIME/macros/matchit.vim " Enable matchit

" Colorshceme settings {{{
if s:HasPlugin('vim-hybrid')
  function! s:DefineHighlight()
    " Note: for deoplete
    highlight clear CursorLine
    highlight CursorLine cterm=underline

    highlight clear SpellBad
    highlight clear SpellCap
    highlight clear SpellRare
    highlight clear SpellLocal
    highlight SpellBad   cterm=underline ctermfg=Red gui=undercurl guisp=Red
    highlight SpellCap   cterm=underline ctermfg=Blue gui=undercurl guisp=Blue
    highlight SpellRare  cterm=underline ctermfg=Magenta gui=undercurl guisp=Magenta
    highlight SpellLocal cterm=underline ctermfg=Cyan gui=undercurl guisp=Cyan
    if g:is_linux " TODO: workaround. 見づらいため.
      highlight Normal ctermbg=none
      highlight ErrorMsg term=standout cterm=standout ctermfg=black ctermbg=167 gui=standout guifg=#1d1f21 guibg=#cc6666
    endif
  endfunction
  autocmd vimrc ColorScheme hybrid :call <SID>DefineHighlight()
  colorscheme hybrid
else
  if g:is_win | colorscheme default | endif " Caution: 明示実行しないと全角ハイライトがされない
endif
" }}}
" }}}1

" vim:nofoldenable:

