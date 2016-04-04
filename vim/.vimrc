" # Index {{{1
" * Introduction
" * Begin
" * Let defines
" * Functions and Commands
" * Options
" * Key-mappings
" * Plug-ins
" * Auto-commands
" * After
" }}}1

" # Introduction {{{1
"
" ## Principles
" * Keep it short and simple, stupid! (500step以下に留めたい)
" * To portable! (e.g. office/home/jenkins, vim/gvim/vrapper, development/server)
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
" * IME offはLinuxはim_control.vimで、WindowsはAutoHotKeyを使う(kaoriya GVimはデフォルトでなる)
"
" ## Refs:
" * [Vimスクリプト基礎文法最速マスター - 永遠に未完成](http://d.hatena.ne.jp/thinca/20100201/1265009821)
" * [Big Sky :: モテる男のVim Script短期集中講座](http://mattn.kaoriya.net/software/vim/20111202085236.htm)
" * [Vimスクリプトリファレンス &mdash; 名無しのvim使い](http://nanasi.jp/code.html)
" * [Vimの極め方](http://whileimautomaton.net/2008/08/vimworkshop3-kana-presentation)
" * [Google Vimscript Style Guide](http://google-styleguide.googlecode.com/svn/trunk/vimscriptguide.xml)
" * [Google Vimscript Guide](http://google-styleguide.googlecode.com/svn/trunk/vimscriptfull.xml)
" * [Vim で使える Ctrl を使うキーバインドまとめ - 反省はしても後悔はしない](http://cohama.hateblo.jp/entry/20121023/1351003586)
"
" ## TODOs
" * TODO: たまにIMEで変換候補確定後に先頭の一文字消えることがある @win
" * TODO: neocompleteでたまに日本語入力が変になる
" * TODO: setでワンライナーでIF文書くと以降のsetがVrapperで適用されない
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
let g:is_home = $USERNAME ==# 'oji'
let g:is_office = $USERNAME ==# 'admin' " FIXME: my win machine TODO: is_win,is_unixのほうがよいかも
let g:is_office_gui = g:is_office && has('gui_running')
let g:is_office_cui = g:is_office && !has('gui_running')
let g:is_jenkins = exists('$BUILD_NUMBER')

let s:dotvim_path = g:is_jenkins ? expand('$WORKSPACE/.vim') : expand('~/.vim')
let s:plugged_path = s:dotvim_path . '/plugged'

let g:is_bash = 1 " shellのハイライトをbash基準にする。Refs: <:help sh.vim>
let g:maplocalleader = ',' " For todo.txt TODO: <Space> or s にしたい
" Note: msys2でリンク、ファイルパス開けるようにする " TODO: ファイルパスの形式によって開けない(OK:<file:\\D:\admin\Desktop>, NG:<file:\\d/admin/Desktop>)
if g:is_office_cui
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

if g:is_office_cui " For mintty. Note: Gnome terminalでは不可なので別途autocomdで実施している。
  let &t_ti .= "\e[1 q"
  let &t_SI .= "\e[5 q"
  let &t_EI .= "\e[1 q"
  let &t_te .= "\e[0 q"
endif
" }}}1

" # Functions and Commands {{{1
function! s:IsPluginEnabled()
  return isdirectory(expand(s:dotvim_path . '/autoload/')) && &loadplugins
endfunction

function! s:HasPlugin(plugin)
  return isdirectory(expand(s:plugged_path . '/' . a:plugin)) && &loadplugins
endfunction

function! s:RestoreCursorPosition()
  let l:ignore_filetypes = ['gitcommit']
  if index(l:ignore_filetypes, &l:filetype) >= 0 | return | endif
  if line("'\"") > 1 && line("'\"") <= line('$')
    normal! g`"
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
command! ToggleExpandTab call <SID>ToggleExpandTab()

function! s:ChangeTabstep(size) " Caution: undoしても&tabstopの値は戻らないので注意
  if &l:expandtab
    " Refs: <:help restore-position>
    normal! msHmt
    execute '%substitute@\v^(%( {' . &l:tabstop . '})+)@\=repeat(" ", len(submatch(1)) / ' . &l:tabstop . ' * ' . a:size . ')@eg' | normal! 'tzt`s
  endif
  let &l:tabstop = a:size
  let &l:shiftwidth = a:size
endfunction
command! -nargs=1 ChangeTabstep call <SID>ChangeTabstep(<q-args>)

function! s:InsertString(pos, str) range " Note: 引数にスペースを含めるにはバックスラッシュを前置します Refs: <:help f-args>
  execute a:firstline . ',' . a:lastline . 'substitute/' . a:pos . '/' . substitute(a:str, '/', '\\/', 'g')
endfunction
command! -range -nargs=1 Prefix <line1>,<line2>call <SID>InsertString('^', <f-args>)
command! -range -nargs=1 Suffix <line1>,<line2>call <SID>InsertString('$', <f-args>)

function! s:ShowExplorer(...)
  let l:path = expand(a:0 == 0 ? '%:h' : a:1)
  if g:is_office
    execute '!start explorer.exe ''' . fnamemodify(l:path, ':p:s?^/\([cd]\)?\1:?:gs?/?\\?') . ''''
  else
    execute '!nautilus ' . l:path . '&'
  endif
endfunction
command! -nargs=? -complete=dir ShowExplorer call <SID>ShowExplorer(<f-args>)

let g:todo_note_directory = expand('~/Documents/todo/notes')
function! s:TodoGrep(word)
  call histadd('cmd', 'TodoGrep '  . a:word)
  " Note: a:wordはオプションが入ってくるかもなので""で囲まない
  execute ':silent grep ' . a:word . ' ' . g:todo_note_directory . '/*'
endfunction
command! -nargs=1 -complete=command TodoGrep call <SID>TodoGrep(<q-args>)

command! -bang BufClear %bdelete<bang>
command! -range=% TrimSpace <line1>,<line2>s/[ \t]\+$// | nohlsearch | normal! ``
command! -range=% DeleteBlankLine <line1>,<line2>v/\S/d | nohlsearch
" Show highlight item name under a cursor. Refs: [Vimでハイライト表示を調べる](http://rcmdnk.github.io/blog/2013/12/01/computer-vim/)
command! VimShowHlItem echomsg synIDattr(synID(line("."), col("."), 1), "name")
" Compairing the difference between the pre-edit file. Refs: `:help DiffOrig`
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
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
let &spellfile = expand(g:is_home ? '~/Dropbox/spell/en.utf-8.add' : '~/Documents/spell/en.utf-8.add')
set spelllang=en,cjk " スペルチェックで日本語は除外する
set splitbelow
set splitright
let &swapfile = g:is_office ? 0 : &swapfile " swapfile作成有無(offにするとvimfilerでのネットワークフォルダ閲覧が高速化するかも(効果は不明))(共有ディレクトリ等にswapファイル残さないように)
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
noremap <expr><SID>[insert]d ':Suffix ' . strftime('\ @%Y-%m-%d') . '<CR>'
noremap <expr><SID>[insert]t ':Suffix ' . strftime('\ @%H:%M:%S') . '<CR>'
noremap <expr><SID>[insert]n ':Suffix ' . strftime('\ @%Y-%m-%d %H:%M:%S') . '<CR>'
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
" Note: uはunite用に確保
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
    let &runtimepath = g:is_office_gui || g:is_jenkins ? s:dotvim_path . ',' . &runtimepath : &runtimepath
  endif
  call g:plug#begin(s:plugged_path)
  " Caution: `for : "*"`としたときfiletypeが設定されない拡張子のとき呼ばれない(e.g. foo.log)。(そもそも`for:"*"は遅延ロードしている意味がないためやらない)
  " General {{{
  Plug 'AndrewRadev/linediff.vim'
  Plug 'AndrewRadev/switch.vim', {'on' : ['Switch', 'SwitchReverse']} " Ctrl+aでやりたいが不可。できたとしてもspeeddating.vimと競合
  Plug 'LeafCage/vimhelpgenerator', {'on' : ['VimHelpGenerator', 'VimHelpGeneratorVirtual']}
  Plug 'Shougo/neocomplete', has('lua') ? {} : {'on' : []}
  Plug 'Shougo/neomru.vim', g:is_jenkins ? {'on' : []} : {}
  " TODO: たまに"E464: Ambiguous use of user-defined command"となってしまう " TODO: unite everythingがmsys2だと有効にならないのでPR.投げる " Note: uniteに依存するpluginのロード時の処理でuniteのfunction呼ぶことがあるのでuniteのon句にすべて必要
  Plug 'Shougo/unite.vim', {'on' : ['Unite', 'VimFiler', 'MemoGrep', 'MemoList', 'MemoNew']}
        \ | Plug 'LeafCage/yankround.vim', {'on' : ['Unite', '<Plug>(yankround-']}
        \ | Plug 'Shougo/unite-outline', {'on' : ['Unite']}
        \ | Plug 'Shougo/vimfiler.vim', {'on' : ['Unite', 'VimFiler'] }
        \ | Plug 'glidenote/memolist.vim', {'on' : ['Unite', 'MemoGrep', 'MemoList', 'MemoNew']}
        \ | Plug 'lambdalisue/vim-gista', {'on' : ['Unite', 'Gista', '<Plug>(gista-']}
        \ | Plug 'rhysd/unite-codic.vim', {'on' : ['Unite']}
        \ | Plug 'sgur/unite-everything', g:is_home ? {'on' : []} : {'on' : ['Unite']}
        \ | Plug 'tsukkee/unite-tag', {'on' : ['Unite']}
        \ | Plug 'ujihisa/unite-colorscheme', {'on' : ['Unite']}
  Plug 'Shougo/vimproc', g:is_jenkins ? {'on' : []} : g:is_office_gui ? {'on' : []} : g:is_home ? {'do' : 'make -f make_unix.mak'} : {'do' : 'make -f make_cygwin.mak'}
  Plug 'TKNGUE/hateblo.vim', g:is_jenkins ? {'on' : []} : {'on' : 'Hateblo'} " entryの保存位置を指定できるためfork版を使用。本家へもPRでてるので、取り込まれたら見先を変える。本家は('moznion/hateblo.vim')
  Plug 'aklt/plantuml-syntax', {'for' : 'plantuml'}
  Plug 'assout/benchvimrc-vim' , {'on' : 'BenchVimrc'}
  Plug 'chaquotay/ftl-vim-syntax', {'for' : 'html.ftl'}
  Plug 'elzr/vim-json', {'for' : 'json'} " For json filetype.
  Plug 'fuenor/im_control.vim', g:is_home ? {} : {'on' : []}
  Plug 'freitass/todo.txt-vim', {'for' : 'todo'}
  Plug 'godlygeek/tabular', {'for' : 'markdown'}
        \ | Plug 'plasticboy/vim-markdown', {'for' : 'markdown'} " TODO 最近のvimではset ft=markdown不要なのにしているため、autocmdが2回呼ばれてしまう TODO いろいろ不都合有るけどcodeブロックのハイライトが捨てがたい TODO syntaxで箇条書きのネストレベル2のコードブロックの後もコードブロック解除されない
  Plug 'h1mesuke/vim-alignta',{'on' : ['Align', 'Alignta']}
  " FIXME: windows(cui,gui)で動いてない。linux未確認
  Plug 'haya14busa/vim-migemo', {'on' : ['Migemo', '<Plug>(migemo-']}
  Plug 'hyiltiz/vim-plugins-profile', {'on' : []} " It's not vim plugin.
  Plug 'https://gist.github.com/assout/524c4ae96928b3d2474a.git', {'dir' : g:plug_home.'/hz_ja.vim/plugin', 'rtp' : '..', 'on' : ['Hankaku', 'Zenkaku', 'ToggleHZ']}
  Plug 'itchyny/calendar.vim', {'on' : 'Calendar'}
  Plug 'itchyny/vim-parenmatch'
  Plug 'kana/vim-gf-user', {'on' : '<Plug>(gf-user-'}
  Plug 'kana/vim-submode'
  Plug 'koron/codic-vim', {'on' : 'Codic'}
  Plug 'https://github.com/m-kat/aws-vim', {'for' : 'template'} " Note: `user/reponam`形式だとPlugInstall時に取得できない
  Plug 'mattn/emmet-vim', {'for' : ['markdown', 'html']} " markdownのurlタイトル取得:<C-y>a コメントアウトトグル : <C-y>/
  Plug 'mattn/qiita-vim', {'on' : 'Qiita'}
  Plug 'medihack/sh.vim', {'for' : 'sh'} " For function block indentation, caseラベルをインデントしたい場合、let g:sh_indent_case_labels = 1
  Plug 'nathanaelkane/vim-indent-guides', {'on' : ['IndentGuidesEnable', 'IndentGuidesToggle']}
  Plug 'pangloss/vim-javascript', {'for' : 'javascript'} " For indent only
  Plug 'schickling/vim-bufonly', {'on' : ['BufOnly', 'BOnly']}
  Plug 'scrooloose/syntastic', {'on' : []} " Caution: quickfixstatusと競合するので一旦無効化
  Plug 'szw/vim-maximizer', {'on' : ['Maximize', 'MaximizerToggle']} " Windowの最大化・復元
  Plug 't9md/vim-textmanip', {'on' : '<Plug>(textmanip-'}
  Plug 'thinca/vim-localrc', g:is_office ? {'on' :[]} : {'for' : 'vim'}
  Plug 'thinca/vim-qfreplace', {'on' : 'Qfreplace'} " grepした結果を置換
  Plug 'thinca/vim-quickrun', {'on' : ['QuickRun', 'WatchdogsRun']}
        \ | Plug 'osyo-manga/shabadou.vim', {'on' : 'WatchdogsRun'}
        \ | Plug 'dannyob/quickfixstatus', {'on' : 'WatchdogsRun'}
        \ | Plug 'KazuakiM/vim-qfsigns', {'on' : 'WatchdogsRun'}
        \ | Plug 'osyo-manga/vim-watchdogs', {'on' : 'WatchdogsRun'}
  Plug 'thinca/vim-ref', {'on' : ['Ref', '<Plug>(ref-']}
        \ | Plug 'Jagua/vim-ref-gene', {'on' : ['Ref', '<Plug>(ref-']}
  Plug 'thinca/vim-singleton' " Note: 遅延ロード不可
  Plug 'tomtom/tcomment_vim' " TODO: markdownが`<!--- hoge --->`となるが`<!--- hoge -->`では？(シンタックスハイライトエラーになる)
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
  Plug 'ujihisa/neco-look'
  Plug 'vim-jp/vimdoc-ja', {}
  Plug 'powerman/vim-plugin-AnsiEsc', {'on' : 'AnsiEsc'} " TODO: msysだとうまく動かない
  Plug 'vim-scripts/DirDiff.vim', {'on' : 'DirDiff'} " TODO: 文字化けする
  Plug 'vim-scripts/HybridText', {'for' : 'hybrid'}
  Plug 'wellle/tmux-complete.vim'
  Plug 'xolox/vim-misc', {'for' : ['vim', 'sh']}
        \ | Plug 'xolox/vim-shell', {'for' : ['vim', 'sh']}
        \ | Plug 'xolox/vim-easytags', {'for' : ['vim', 'sh']}
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
        \ | Plug 'rhysd/vim-textobj-anyblock'
        \ | Plug 'sgur/vim-textobj-parameter'
        \ | Plug 'thinca/vim-textobj-between'
        \ | Plug 'thinca/vim-textobj-comment'
  " }}}

  " Colorschemes {{{
  Plug 'w0ng/vim-hybrid'
  " }}}
  call g:plug#end()

  " Caution: Workaround. msys2からgvim起動したときkaoriyaのを入れないといけないため
  if g:is_office_gui | let &runtimepath = &runtimepath . ',~/Tools/vim74-kaoriya-win64/plugins/vimproc' | endif

  " Plugin prefix mappings {{{
  map  <Space>              <SID>[plugin]
  xmap <SID>[plugin]a       <SID>[alignta]
  map  <SID>[plugin]c       <SID>[camelize]
  map  <SID>[plugin]g       <SID>[gista]
  map  <SID>[plugin]h       <SID>[markdown_h]
  nmap <SID>[plugin]H       <SID>[markdown_H]
  map  <SID>[plugin]l       <SID>[markdown_l]
  nmap <SID>[plugin]L       <SID>[markdown_L]
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
  " TODO: <SID>つけれない(つけないと"[s"と入力した時にキー入力待ちが発生してしまう)
  nmap <SID>[plugin][       [subP]
  nmap <SID>[plugin]]       [subN]

  " TODO: 押しづらい
  map  <SID>[plugin]<Space> <SID>[sub_plugin]
  map  <SID>[sub_plugin]h   <SID>[hateblo]
  nmap <SID>[sub_plugin]q   <SID>[qiita]
  nmap <SID>[sub_plugin]r   <SID>[ref]
  map  <SID>[sub_plugin]s   <SID>[syntastic]

  " Caution: Kは定義不要だがプラグインの遅延ロードのため定義している
  nmap K                <Plug>(ref-keyword)
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
  let g:calendar_google_calendar = g:is_home ? 1 : 0
  let g:calendar_google_task = g:is_home ? 1 : 0
endif " }}}

if s:HasPlugin('hateblo.vim') " {{{
  let g:hateblo_vim = {
        \  'user': 'assout',
        \  'api_key': get(g:, 'g:hateblo_api_key', ''),
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

if has('kaoriya') " {{{
  let g:plugin_dicwin_disable = 1 " dicwin plugin無効
  let g:plugin_scrnmode_disable = 1 " scrnmode plugin無効
else
  command! -nargs=0 CdCurrent cd %:p:h
  command! DiffOrig vertical new | set buftype=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
endif " }}}

if s:HasPlugin('memolist.vim') " {{{
  let g:memolist_memo_suffix = 'md'
  let g:memolist_path = expand('~/memolist')
  let g:memolist_template_dir_path = g:memolist_path

  function! s:MemoGrep(word)
    call histadd('cmd', 'MemoGrep '  . a:word)
    " Caution: a:wordはオプションが入ってくるかもなので""で囲まない
    execute ':silent grep -r --exclude-dir=_book ' . a:word . ' ' . g:memolist_path
  endfunction
  command! -nargs=1 -complete=command MemoGrep call <SID>MemoGrep(<q-args>)

  autocmd vimrc User memolist.vim
        \ let g:unite_source_alias_aliases = {
        \  'memolist' : { 'source' : 'file_rec', 'args' : g:memolist_path },
        \  'memolist_reading' : { 'source' : 'file', 'args' : g:memolist_path },
        \ }
        \ | call g:unite#custom#source('memolist', 'sorters', ['sorter_ftime', 'sorter_reverse'])
        \ | call g:unite#custom#source('memolist', 'matchers', ['converter_tail_abbr', 'matcher_default', 'matcher_hide_hidden_files'])
        \ | call g:unite#custom#source('memolist', 'ignore_pattern', 'exercises\|reading\|_book\|\(png\|gif\|jpeg\|jpg\)$')
        \ | call g:unite#custom#source('memolist_reading', 'sorters', ['sorter_ftime', 'sorter_reverse'])
        \ | call g:unite#custom#source('memolist_reading', 'matchers', ['converter_tail_abbr', 'matcher_default', 'matcher_hide_hidden_files'])
        \ | call g:unite#custom#source('memolist_reading', 'ignore_pattern', '^\%(.*exercises\|.*reading\)\@!.*\zs.*\|\(png\|gif\|jpeg\|jpg\)$')

  nnoremap       <SID>[memolist]a  :<C-u>MemoNew<CR>
  nnoremap       <SID>[memolist]l  :<C-u>Unite memolist -buffer-name=memolist<CR>
  nnoremap <expr><SID>[memolist]g ':<C-u>MemoGrep ' . input('MemoGrep word: ') . '<CR>'
  nnoremap       <SID>[memolist]L  :<C-u>Unite memolist_reading -buffer-name=memolist_reading<CR>
endif " }}}

if s:HasPlugin('neocomplete') " {{{
  let g:neocomplete#enable_at_startup = g:is_home ? 1 : 0 " TODO: win gvimでダイアログが一瞬出る。
  let g:neocomplete#text_mode_filetypes = { 'markdown': 1 } " TODO: どうなる？
endif " }}}

if s:HasPlugin('open-browser.vim') " {{{
  let g:openbrowser_search_engines = extend(get(g:, 'openbrowser_search_engines', {}), {
        \    'translate' : 'https://translate.google.com/?hl=ja#auto/ja/{query}',
        \    'stackoverflow' : 'http://stackoverflow.com/search?q={query}',
        \  }) " Note: vimrcリロードでデフォルト値が消えてしまわないようにしている
  if g:is_office_cui
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

  " FIXME: 空白区切りの文字列をクォート切り替え
        " \  {
        " \     '\v\$(.{-})\s' : '"$\1"',
        " \     '\v"\$(.{-})\s"' : '''$\1''',
        " \     '\v''\$(.{-})''' : '$\1',
        " \  },

  nnoremap <SID>[switch] :<C-u>Switch<CR>
  nnoremap <SID>[Switch] :<C-u>SwitchReverse<CR>
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

if s:HasPlugin('todo.txt-vim') " {{{
  " TODO: Unite source化など
  nnoremap       <SID>[todo]l  :<C-u>edit ~/Documents/todo/todo.txt<CR>
  nnoremap       <SID>[todo]L  :<C-u>edit ~/Documents/todo/done.txt<CR>
  nnoremap       <SID>[todo]r  :<C-u>edit ~/Documents/todo/report.txt<CR>
  nnoremap <expr><SID>[todo]g ':<C-u>TodoGrep ' . input('TodoGrep word: ') . '<CR>'
endif " }}}

if s:HasPlugin('unite.vim') " {{{
  let g:unite_enable_ignore_case = 1
  let g:unite_enable_smart_case = 1
  let g:unite_source_grep_max_candidates = 200
  if g:is_office_gui
    let g:unite_source_rec_async_command = ['find', '-L']
  endif
  let s:RelativeMove = {'description' : 'move after lcd', 'is_selectable' : 1, 'is_quit' : 0 }

  function! s:RelativeMove.func(candidates) " move先を相対パスで指定するaction
    let l:candidate = a:candidates[0]
    let l:dir = isdirectory(l:candidate.word) ? l:candidate.word : fnamemodify(l:candidate.word, ':p:h')
    execute g:unite_kind_cdable_lcd_command fnameescape(l:dir)
    call g:unite#take_action('move', a:candidates)
    call g:unite#force_redraw() " 呼ばないと表示更新されない
  endfunction

  function! s:UniteKeymappings()
    imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
    nmap <buffer> <C-w> <Plug>(unite_delete_backward_path)

    " TODO: sortしたい。↓じゃダメ。
    " nnoremap <buffer><expr>S unite#mappings#set_current_filters(empty(unite#mappings#get_current_filters()) ? ['sorter_reverse'] : [])
    nnoremap <buffer><expr>f unite#smart_map('f', unite#do_action('vimfiler'))
    nnoremap <buffer><expr>m unite#smart_map('m', unite#do_action('relative_move'))
    nnoremap <buffer><expr>p unite#smart_map('s', unite#do_action('split'))
    nnoremap <buffer><expr>v unite#smart_map('v', unite#do_action('vsplit'))
    " TODO: msys2で効かない(そもそも"start"アクションが効かない) -> uniteにモンキーパッチ当てたらうごいた(今cygstart呼ばれちゃってる)
    " (cygstartをstartに変えたら/usr/hogeとかは開くが、/d/hogeやD:/hogeは開かない。FileHandlerにしたら両方いけるが実行後vim画面がredrawされない)
    nnoremap <buffer><expr>x unite#smart_map('x', unite#do_action('start'))
  endfunction
  autocmd vimrc FileType unite call s:UniteKeymappings()

  " Note: mapはunimpairedの`]u`系を無効にしないといけない " Note: UnitePrevious,Nextはsilentつけないと`Press Enter..`が表示されてしまう
  autocmd vimrc User unite.vim
        \   call g:unite#custom#profile('default', 'context', { 'start_insert' : 1 })
        \ | call g:unite#custom#action('file,directory', 'relative_move', s:RelativeMove)
        \ | call g:unite#custom#alias('file', 'delete', 'vimfiler__delete')
        \ | call g:unite#custom#source('bookmark', 'sorters', ['sorter_ftime', 'sorter_reverse'])
        \ | call g:unite#custom#source('file_rec', 'ignore_pattern', '\(png\|gif\|jpeg\|jpg\)$')
        \ | call g:unite#custom#source('file_rec/async', 'ignore_pattern', '\(png\|gif\|jpeg\|jpg\)$')
        \ | execute 'nnoremap [u :silent UnitePrevious<CR>'
        \ | execute 'nnoremap ]u :silent UniteNext<CR>'
        \ | execute 'nnoremap [U :silent UniteFirst<CR>'
        \ | execute 'nnoremap ]U :silent UniteLast<CR>'
        " \ | call g:unite#custom#default_action('directory', 'vimfiler')

  nnoremap <SID>[unite]<CR> :<C-u>Unite<CR>
  nnoremap <SID>[unite]b    :<C-u>Unite buffer -buffer-name=buffer<CR>
  nnoremap <SID>[unite]B    :<C-u>Unite bookmark -buffer-name=bookmark<CR>
  nnoremap <SID>[unite]d    :<C-u>Unite directory -buffer-name=directory<CR>
  " TODO: asyncのほう使いたいが日本語文字化けする
  nnoremap <SID>[unite]e    :<C-u>Unite everything -buffer-name=everything<CR>
  nnoremap <SID>[unite]f    :<C-u>Unite file -buffer-name=file<CR>
  " TODO: msys2で`Target: .`が失敗する(empty)(Gvimはうまくいく)(/d/直下の場合はうまくいく)
  nnoremap <SID>[unite]g    :<C-u>Unite grep -buffer-name=grep -no-empty<CR>
  nnoremap <SID>[unite]G    :<C-u>Unite directory:~/Development -buffer-name=directory-ghq<CR>
  nnoremap <SID>[unite]l    :<C-u>Unite line -buffer-name=line -no-quit<CR>
  nnoremap <SID>[unite]m    :<C-u>Unite mapping -buffer-name=mapping<CR>
  nnoremap <SID>[unite]o    :<C-u>Unite outline -buffer-name=outline -no-quit -vertical -winwidth=30 -direction=botright -no-truncate<CR>
  nnoremap <SID>[unite]O    :<C-u>Unite outline:folding -buffer-name=outline:folding -no-quit -vertical -winwidth=30 -direction=botright -no-truncate<CR>
  nnoremap <SID>[unite]r    :<C-u>Unite resume -buffer-name=resume<CR>
  nnoremap <SID>[unite]R    :<C-u>Unite register -buffer-name=register<CR>
  nnoremap <SID>[unite]p    :<C-u>Unite runtimepath -buffer-name=runtimepath<CR>
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
  if s:HasPlugin('vim-ref-gene') " {{{
    nnoremap <SID>[unite]R :<C-u>Unite ref/gene -buffer-name=ref/gene<CR>
  endif " }}}
  if s:HasPlugin('unite-tag') " {{{
    nnoremap <SID>[unite]t :<C-u>Unite tag -buffer-name=tag -no-quit -vertical -winwidth=30 -direction=botright -no-truncate<CR>
  endif " }}}
  if s:HasPlugin('yankround.vim') " {{{
    nnoremap <SID>[unite]y :<C-u>Unite yankround -buffer-name=yankround<CR>
  else " }}}
    nnoremap <SID>[unite]y :<C-u>Unite history/yank -buffer-name=histry/yank<CR>
  endif

  if s:HasPlugin('neomru.vim') " {{{
    " Note: Windows(msys2)で、ネットワーク上のファイルがあるとUnite候補表示時に遅くなるっポイのでignore " Note: Deprecatedだが(Uniteの関数呼ぶのが推奨)Unite未ロードの場合があるためこっちを使用
    let g:neomru#file_mru_ignore_pattern = '^\(\/\/\|fugitive\)'
    let g:neomru#directory_mru_ignore_pattern = '^\(\/\/\|fugitive\)'
    let g:neomru#directory_mru_limit = 500
    let g:neomru#do_validate = 0 " Cautioin: 有効にしちゃうとvim終了時結構遅くなる
    let g:neomru#file_mru_limit = 500
    let g:neomru#filename_format = ''
    let g:neomru#follow_links = 1

    nmap     <SID>[unite]n  <SID>[neomru]
    nnoremap <SID>[neomru]f :<C-u>Unite neomru/file -buffer-name=neomru/file<CR>
    nnoremap <SID>[neomru]d :<C-u>Unite neomru/directory -buffer-name=neomru/directory<CR>
  endif " }}}

  if s:HasPlugin('unite-codic.vim') " {{{ TODO: Ignorecase (or Smartcase)
    nnoremap <expr><SID>[unite]c ':<C-u>Unite codic -vertical -winwidth=30 -direction=botright -input=' . expand('<cword>') . '<CR>'
    nnoremap       <SID>[unite]C  :<C-u>Unite codic -vertical -winwidth=30 -direction=botright -start-insert<CR>
  endif " }}}
endif " }}}

if s:HasPlugin('vimfiler.vim') " {{{
  " TODO: msys2でxでのシステム関連付けが開かない(uniteの箇所にもコメントしているがcygstart呼ばれているのが原因)
  let g:vimfiler_safe_mode_by_default = 0 " This variable controls vimfiler enter safe mode by default.
  " Caution: Uniteをオンデマンドにしている関係上有効にするとエラーが出るケースが出てくる
  let g:vimfiler_as_default_explorer = 0 " If this variable is true, Vim use vimfiler as file manager instead of |netrw|.
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
    if !filereadable(l:path) | 
      return 0
    endif
    return { 'path': l:path, 'line': l:line, 'col': 0, }
  endfunction
  autocmd vimrc User vim-gf-user call g:gf#user#extend('GfFile', 1000)
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
  map <SID>[replace] <Plug>(operator-replace)

  if s:HasPlugin('vim-textobj-anyblock') " {{{
    nmap <SID>[replace]b <Plug>(operator-replace)<Plug>(textobj-anyblock-i)
  endif " }}}

  if s:HasPlugin('vim-textobj-between') " {{{
    nmap <SID>[replace]d <Plug>(operator-replace)<Plug>(textobj-between-i)
  endif " }}}

  if s:HasPlugin('vim-textobj-line') " {{{
    nmap <SID>[replace]l <Plug>(operator-replace)<Plug>(textobj-line-i)
  endif " }}}

  " if s:HasPlugin('vim-textobj-parameter') " {{{  Caution: aは<Space>paeとかできなくなるのでやらない
  "   nmap <SID>[replace]a <Plug>(operator-replace)<Plug>(textobj-parameter-i)
  " endif " }}}

  if s:HasPlugin('vim-textobj-url') " {{{
    nmap <SID>[replace]u <Plug>(operator-replace)<Plug>(textobj-url-i)
  endif " }}}
endif " }}}

if s:HasPlugin('vim-operator-surround') " {{{
  " TODO: 空白区切りがしたい(なぜか今でも2スペースならできる)
  " Refs: <http://d.hatena.ne.jp/syngan/20140301/1393676442>
  " Refs: <http://www.todesking.com/blog/2014-10-11-surround-vim-to-operator-vim/>
  autocmd vimrc User vim-operator-surround
        \   let g:operator#surround#blocks = deepcopy(g:operator#surround#default_blocks)
        \ | call add(g:operator#surround#blocks['-'], { 'block' : ['<!-- ', ' -->'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['c']} )

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

  if s:HasPlugin('vim-textobj-line') " {{{ TODO: lを潰したくない
    nmap <SID>[surround-a]l <Plug>(operator-surround-append)<Plug>(textobj-line-a)
    nmap <SID>[surround-d]l <Plug>(operator-surround-delete)<Plug>(textobj-line-a)
    nmap <SID>[surround-r]l <Plug>(operator-surround-replace)<Plug>(textobj-line-a)
  endif " }}}

  " if s:HasPlugin('vim-textobj-parameter') " {{{ Caution: aはsaawとかできなくなるのでやらない
  "   nmap <SID>[surround-a]a <Plug>(operator-surround-append)<Plug>(textobj-parameter-a)
  "   nmap <SID>[surround-d]a <Plug>(operator-surround-delete)<Plug>(textobj-parameter-a)
  "   nmap <SID>[surround-r]a <Plug>(operator-surround-replace)<Plug>(textobj-parameter-a)
  " endif " }}}

  if s:HasPlugin('vim-textobj-url') " {{{
    nmap <SID>[surround-a]u <Plug>(operator-surround-append)<Plug>(textobj-url-a)
  endif " }}}
endif " }}}

if s:HasPlugin('vim-quickrun') " {{{
  " TODO: プレビューウィンドウで開けないか(szで閉じやすいので)
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

  let g:watchdogs_check_BufWritePost_enable = 1
  " TODO: quickfix開くとhookが動かない。暫定で開かないようにしている " TODO: xmllint
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
  " Note: 画面が小さいときにエラー出ると"Press Enter ..."が表示されうざいのでWorkaroundする
  let g:quickrun_config['watchdogs_checker/_']['hook/quickfix_status_enable/enable_exit'] = has('gui_running') ? 1 : 0

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

  call extend(g:quickrun_config, {
        \  'markdown/watchdogs_checker': {
        \    'type'
        \      : executable('mdl') ? 'watchdogs_checker/mdl'
        \      : executable('textlint') ? 'watchdogs_checker/textlint'
        \      : executable('redpen') ? 'watchdogs_checker/redpen'
        \      : executable('eslint-md') ? 'watchdogs_checker/eslint-md'
        \      : '',
        \   },
        \})

  if g:is_office_gui
    call extend(g:quickrun_config, {'watchdogs_checker/shellcheck' : {'exec' : 'cmd /c "chcp.com 65001 | %c %o %s:p"'}})
    call extend(g:quickrun_config, {'watchdogs_checker/mdl' : {'exec' : 'cmd /c "chcp.com 65001 | %c %o %s:p"'}})
  elseif g:is_office_cui
    call extend(g:quickrun_config, {'watchdogs_checker/shellcheck' : {'exec' : 'chcp.com 65001 | %c %o %s:p'}})
    call extend(g:quickrun_config, {'watchdogs_checker/mdl' : {'exec' : 'chcp.com 65001 | %c %o %s:p'}})
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
  if g:is_home
    autocmd VimEnter,InsertLeave * silent execute '!echo -ne "\e[2 q"' | redraw!
    autocmd InsertEnter,InsertChange *
          \ if     v:insertmode == 'i' | silent execute '!echo -ne "\e[6 q"' | redraw! |
          \ elseif v:insertmode == 'r' | silent execute '!echo -ne "\e[4 q"' | redraw! | endif
    autocmd VimLeave * silent execute '!echo -ne "\e[ q"' | redraw!
  endif

  " Note: ftpluginで上書きされてしまうことがあるためここで設定している" Note: formatoptionsにo含むべきか難しい
  autocmd FileType * setlocal formatoptions-=c
  " Note: 箇条書きの2段落目のインデントがおかしくなることがあったのでcinkeysを空にする(行に:が含まれてたからかも)
  autocmd FileType markdown highlight! def link markdownItalic LineNr | setlocal spell tabstop=4 shiftwidth=4 cinkeys=""
  autocmd FileType java setlocal noexpandtab
  " Note: aws.json を考慮して*jsonとしている
  autocmd FileType *json setlocal foldmethod=syntax foldlevel=99
  autocmd FileType xml setlocal foldmethod=syntax foldlevel=99
  if executable('python')
    autocmd FileType *json, command! -buffer -range=% FormatJson <line1>,<line2>!python -m json.tool
  endif
  if executable('xmllint') " Note: Windowsのときencode指定しないとうまくいかないことがある
    autocmd FileType xml command! -buffer -range=% FormatXml <line1>,<line2>!xmllint --encode utf-8 --format --recover - 2>/dev/null
  endif

  if g:is_office " homeではRicty font使うので不要
    " Double byte space highlight
    autocmd Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
    autocmd VimEnter,WinEnter * match DoubleByteSpace /　/
  endif
augroup END
" }}}1

" # After {{{1
nohlsearch " Don't (re)highlighting the last search pattern on reloading.
source $VIMRUNTIME/macros/matchit.vim " Enable matchit

" Colorshceme settings {{{
if s:HasPlugin('vim-hybrid')
  function! s:DefineHighlight()
    highlight clear SpellBad
    highlight clear SpellCap
    highlight clear SpellRare
    highlight clear SpellLocal
    highlight SpellBad   cterm=underline ctermfg=Red gui=undercurl guisp=Red
    highlight SpellCap   cterm=underline ctermfg=Blue gui=undercurl guisp=Blue
    highlight SpellRare  cterm=underline ctermfg=Magenta gui=undercurl guisp=Magenta
    highlight SpellLocal cterm=underline ctermfg=Cyan gui=undercurl guisp=Cyan
    if g:is_home " TODO: workaround. 見づらいため.
      highlight Normal ctermbg=none
      highlight ErrorMsg term=standout cterm=standout ctermfg=black ctermbg=167 gui=standout guifg=#1d1f21 guibg=#cc6666
    endif
  endfunction
  autocmd vimrc ColorScheme hybrid :call <SID>DefineHighlight()
  colorscheme hybrid
else
  if g:is_office | colorscheme default | endif " Caution: 明示実行しないと全角ハイライトがされない
endif
" }}}
" }}}1

" vim:nofoldenable:

