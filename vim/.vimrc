" # Introduction {{{1
"
" ## Principles
" - Keep it short and simple, stupid! (500step以下に留めたい)
" - To portable! (e.g. office/home/jenkins, vim/gvim/vrapper, development/server)
" - デフォルト環境(サーバなど)での操作時に混乱するカスタマイズはしない(;と:の入れ替えとか)(sだけはつぶしちゃう)
" - キーマッピングでは、スペースキー、sキーを特別なプレフィックスキーとする
"
" ## Caution
" - executeコマンドをキーマッピングするとき<C-u>をつけること(e.g. nnoremap hoge :<C-u>fuga)
"   (誤って範囲指定しないようにするためなので、範囲指定してほしい場合はつけないこと) <http://d.hatena.ne.jp/e_v_e/20150101/1420067539>
" - '|' は :normal コマンドの一部として処理されるので、このコマンドの後に他のコマンドを続けて書けません。Refs. <:help normal>
" - 'noremap <expr> {lhs} {rhs}'のようにするとVrapperが有効にならない(noremap <expr>{lhs} {rhs}とするとOK、またはnoremap <silent><expr> {lhs} {rhs}もOK)
" - vimrcの設定ファイルはLinuxでは~/.vim, ~/.vimrcにする。Windowsでは~/vimfiles,~/_vimrcにする。
" - IME offはLinuxはim_control.vimで、WindowsはAutoHotKeyを使う(kaoriya GVimはデフォルトでなる)
" - executable()は遅いらしいので使わない
"
" ## TODOs
" - TODO: GVim@officeで複数ファイルを開いたときの<C-w>h,lが遅い(プラグインなし、vimrc空でも再現)
" }}}1

" # Begin {{{1
unlet! skip_defaults_vim
" TODO:filetype plugin onがここと、vim-plugの中の2回されて遅くなるかも
source $VIMRUNTIME/defaults.vim
set t_ks=""
set t_ke=""
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
let g:is_win       = has('win32') || has('win32unix')
let g:is_win_gui   = g:is_win && has('gui_running')
let g:is_win_cui   = g:is_win && !has('gui_running')
let g:is_jenkins   = exists('$BUILD_NUMBER')

let s:dotvim_path = g:is_jenkins ? expand('$WORKSPACE/.vim') : expand('~/.vim')
let s:plugged_path = s:dotvim_path . '/plugged'

let g:is_bash = 1 " shellのハイライトをbash基準にする。Refs: <:help sh.vim>
let g:maplocalleader = ',' " For todo.txt TODO: <Space> or s にしたい
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

" カーソル形状変更
let &t_ti = "\e[1 q"
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"
let &t_te = "\e[0 q"
" }}}

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

function! s:FzyCommand(choice_command, vim_command)
  try
    let output = system(a:choice_command . " | fzy")
    " let output = system(a:choice_command . " | fzf")
  catch /Vim:Interrupt/
    " Swallow errors from ^C, allow redraw! below
  endtry
  redraw!
  if v:shell_error == 0 && !empty(output)
    exe a:vim_command . ' ' . output
  endif
endfunction

function! s:Grep(word, target)
  " Note: a:wordはオプションが入ってくるかもなので""で囲まない
  execute ':silent grep -r ' . a:word . ' ' . a:target . '/*'
endfunction

function! s:HasPlugin(plugin)
  return isdirectory(expand(s:plugged_path . '/' . a:plugin)) && &loadplugins
endfunction

function! s:InsertString(pos, str) range " Note: 引数にスペースを含めるにはバックスラッシュを前置します Refs: <:help f-args>
  execute a:firstline . ',' . a:lastline . 'substitute/' . a:pos . '/' . substitute(a:str, '/', '\\/', 'g')
endfunction

function! s:JumpToNextTagSameIndent(dir)
  call search('^' . matchstr(getline('.'), '\(^\s*\)') . '<\(/\)\@!', a:dir == 'backward' ? 'web' : 'we')
endfunction
function! s:JumpToNextTagText(dir) " Refs: [vim - Jump to next tag in pom.xml - Stack Overflow](https://stackoverflow.com/questions/42867955/jump-to-next-tag-in-pom-xml)
  call search('<[^/][^>]\{-}>.', a:dir == 'backward' ? 'web' : 'we')
endfunction
function! s:JumpToNextTag(dir)
  call search('<\(/\)\@!', a:dir == 'backward' ? 'web' : 'we')
endfunction
function! s:JumpToNextMapping() " Refs: [Move to next/previous line with same indentation | Vim Tips Wiki | FANDOM powered by Wikia](http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation)
  nnoremap <silent><buffer>) :call <SID>JumpToNextTagSameIndent('forward')<CR>
  nnoremap <silent><buffer>( :call <SID>JumpToNextTagSameIndent('backward')<CR>
endfunction

function! s:OrDefault(var, default)
  return a:var ==# '' ? a:default : a:var
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

" }}}1

" # Commands {{{1

command! -nargs=1 ChangeTabstep call <SID>ChangeTabstep(<q-args>)
command! -bang BufClear %bdelete<bang>
command! -nargs=1 ChangeTabstep call <SID>ChangeTabstep(<q-args>)
command! -range=% DeleteBlankLine <line1>,<line2>v/\S/d | nohlsearch
command! FzyMemo call <SID>FzyCommand('ls ~/memo/* ~/memo_internal', ':edit')
command! FzyNote call <SID>FzyCommand('ls ~/Documents/notes/*', ':edit')
command! FzyMru call <SID>FzyCommand('sed -n 2,\$p ~/.cache/neomru/file', ':edit')
command! FzyInProject call <SID>FzyCommand('git ls-files', ':edit')
command! -range -nargs=1 InsertPrefix <line1>,<line2>call <SID>InsertString('^', <f-args>)
command! -range -nargs=1 InsertSufix <line1>,<line2>call <SID>InsertString('$', <f-args>)
command! -nargs=1 LogGrep call <SID>Grep(<q-args>, expand('~/.tmux/log/')) | call histadd('cmd', 'LogGrep <q-args>')
command! -nargs=? -range=% Mattertee :<line1>,<line2>write !mattertee <args>
command! -nargs=? NoteNew execute 'edit ~/Documents/notes' . strftime('/%Y%m%d_%H%M%S') . '_' . <SID>OrDefault(<q-args>, 'note') . '.md'
command! -nargs=? NoteSave execute 'save ~/Documents/notes' . strftime('/%Y%m%d_%H%M%S') . '_' . <SID>OrDefault(<q-args>, 'note') . '.md'
command! -nargs=1 NoteGrep call <SID>Grep(<q-args>, expand('~/Documents/notes')) | call histadd('cmd', 'NoteGrep <q-args>')
command! -nargs=? -complete=dir ShowExplorer call <SID>ShowExplorer(<f-args>)
command! -nargs=1 TodoGrep call <SID>Grep(<q-args>, expand('~/Documents/todo/notes')) | call histadd('cmd', 'TodoGrep <q-args>')
command! ToggleExpandTab call <SID>ToggleExpandTab()
command! -range=% TrimSpace <line1>,<line2>s/[ \t]\+$// | nohlsearch | normal! ``
command! -range=% TrimCR <line1>,<line2>s/\r// | nohlsearch | normal! ``
command! -range=% TrimLF <line1>,<line2>s/\n// | nohlsearch | normal! ``
" Show highlight item name under a cursor. Refs: [Vimでハイライト表示を調べる](http://rcmdnk.github.io/blog/2013/12/01/computer-vim/)
command! VimShowHlItem echomsg synIDattr(synID(line("."), col("."), 1), "name")
" }}}1

" # Options {{{1
set ambiwidth=double
set background=dark
set cindent
set backup
set backupdir=~/.vim/backup
set clipboard&
set clipboard^=unnamedplus,unnamed
set cmdheight=2 " hit-enterプロンプトの出現を避ける
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
set modeline
set number " Note: tmuxなどでのコピペ時にないほうがやりやすいけど
" Caution: Windowsでgrep時バックスラッシュだとパスと解釈されないことがあるために設定
" Caution: GUI, CUIでのtags利用時のパスセパレータ統一のために設定
" Caution: 副作用があることに注意(Refs: <https://github.com/vim-jp/issues/issues/43>)
set shellslash
set shiftwidth=2
set showtabline=1
set shortmess& shortmess+=atTOI
set sidescrolloff=5
set smartcase
set softtabstop=0
" set spellfile = '~/spell/en.utf-8.add' : '~/Documents/spell/en.utf-8.add')
set spelllang=en,cjk " スペルチェックで日本語は除外する
set splitbelow
set splitright
set nostartofline " [vim - vimでカーソル位置を維持しつつ最終行へ移動 - スタック・オーバーフロー](https://ja.stackoverflow.com/questions/17908/vim%E3%81%A7%E3%82%AB%E3%83%BC%E3%82%BD%E3%83%AB%E4%BD%8D%E7%BD%AE%E3%82%92%E7%B6%AD%E6%8C%81%E3%81%97%E3%81%A4%E3%81%A4%E6%9C%80%E7%B5%82%E8%A1%8C%E3%81%B8%E7%A7%BB%E5%8B%95)
let &swapfile = g:is_win ? 0 : &swapfile " swapfile作成有無(offにするとvimfilerでのネットワークフォルダ閲覧が高速化するかも(効果は不明))(共有ディレクトリ等にswapファイル残さないように)
set tags^=./.tags;
set tabstop=2
set title
set ttimeoutlen=0
set undodir=~/.cache/undo
set undofile
set visualbell t_vb=
" set wildmode=list:longest " Caution: 微妙なのでやめる
set nowrap
set nowrapscan

" refs. https://github.com/microsoft/WSL/issues/1154
set <Up>=[A
set <Down>=[B
set <Right>=[C
set <Left>=[D
" }}}1

" # Key-mappings {{{1
" Plugin prefix mappings {{{
map  <Space>        <SID>[plugin]
map  <SID>[plugin]a <SID>[align]
map  <SID>[plugin]c <SID>[camelize]
nmap <SID>[plugin]e <Plug>[emmet]
nmap <SID>[plugin]f <SID>[ale-fix]
nmap <SID>[plugin]g <SID>[gitgutter]
map  <SID>[plugin]H <SID>[markdown_h]
map  <SID>[plugin]L <SID>[markdown_l]
nmap <SID>[plugin]l <SID>[ale-lint]
nmap <SID>[plugin]m <SID>[memolist]
map  <SID>[plugin]o <SID>[open-browser]
map  <SID>[plugin]O <SID>[Open-browser]
nmap <SID>[plugin]p <SID>[previm]
nmap <SID>[plugin]q <SID>[quickrun]
map  <SID>[plugin]r <SID>[replace]
map  <SID>[plugin]s <SID>[swap]
map  <SID>[plugin]S <SID>[Swap]
map  <SID>[plugin]R <SID>[Replace]
map  <SID>[plugin]t <SID>[todo]
nmap <SID>[plugin]/ <SID>[migemo]
" TODO: <SID>つけれない(つけないで[subP]とすると"[s"と入力した時にキー入力待ちが発生してしまう)
nmap <SID>[plugin][ <subP>
nmap <SID>[plugin]] <subN>

map  <SID>[plugin]<Space> <SID>[context]
" }}}

" Normal, Visual mode basic mappings {{{
noremap gs       s
map     s        <SID>[special]
noremap          <SID>[special]/  /\v
noremap          <SID>[special]?  ?\v

map              <SID>[special]a  <SID>[surround-a]
map              <SID>[special]d  <SID>[surround-d]
map              <SID>[special]r  <SID>[surround-r]

map              <SID>[special]A  <SID>[surround-A]
map              <SID>[special]D  <SID>[surround-D]
map              <SID>[special]R  <SID>[surround-R]

map              <SID>[special]i  <SID>[insert]
map              <SID>[special]m  <SID>[maximizer]
nmap             <SID>[special]o  <SID>[open]
nmap             <SID>[special]t  <SID>[tagbar]

" 削除キーでyankしない(大きいデータをclipboardに入れるとき重くなるのをこれで防ぐ)
noremap          x "_x
noremap          X "_X

if has('gui_running')
  " Note: autocmd FileTypeイベントを発効する。本来setfiletypeは不要だがプラグインが設定するファイルタイプのとき(e.g. aws.json)、FileType autocmdが呼ばれない。呼び出されない場合はsetfiletypeなどする。markdownもダメなので必須。
  " TODO ファイル開いていない状態でやるとエラーになる
  nnoremap <silent><SID>[special]u  :<C-u>source $MYVIMRC<Bar>source $MYGVIMRC<Bar>execute "setfiletype " . &l:filetype<Bar>:filetype detect<CR>
els
  nnorema <silent><SID>[special]u  :<C-u>source $MYVIMRC<Bar>execute "setfiletype " . &l:filetype<Bar>:filetype detect<CR>
endif
nnoremap   <expr><SID>[special]] ':ptag ' . expand("<cword>") . '<CR>'

if ! has('gui_running')
  nnoremap <Plug>[fzy]  <Nop>
  nnoremap <Plug>[fzy]m :<C-u>FzyMemo<CR>
  nnoremap <Plug>[fzy]n :<C-u>FzyNote<CR>
  nnoremap <Plug>[fzy]r :<C-u>FzyMru<CR>
  nnoremap <Plug>[fzy]p :<C-u>FzyInProject<CR>
endif

" TODO: To plugin or function " TODO: .(dot) repeat " TODO: Refactor
noremap       <SID>[insert]   <Nop>
noremap <expr><SID>[insert]p ':InsertPrefix ' . input('prefix:') . '<CR>'
noremap <expr><SID>[insert]s ':InsertSufix ' . input('suffix:') . '<CR>'
" TODO: ↓らへんすべて汎用化
noremap       <SID>[insert]-  :InsertPrefix - <CR>
noremap       <SID>[insert]#  :InsertPrefix # <CR>
noremap       <SID>[insert]>  :InsertPrefix > <CR>
noremap <expr><SID>[insert]n ':InsertSufix ' . strftime('%Y-%m-%d %H:%M:%S') . '<CR>'

nnoremap       <SID>[open]      <Nop>
" Note: fugitiveで対象とするためresolveしている " Caution: Windows GUIのときシンボリックリンクを解決できない
nnoremap <expr><SID>[open]v    ':<C-u>edit ' . resolve(expand($MYVIMRC)) . '<CR>'

" TODO: fzyかfzfかdeniteに寄せる (できればterminalと同じfzyに寄せたいがGVimで動かない)
" TODO: かつfzfがgolangなので全部切り替えたい
" Note: <SID>だとvim-plugのオンデマンドロードができない
nmap <SID>[open]m <Plug>[fzy]m
nmap <SID>[open]n <Plug>[fzy]n
nmap <SID>[open]r <Plug>[fzy]r
nmap <SID>[open]p <Plug>[fzy]p

" Caution: K,gf系はデフォルトなので定義不要だがプラグインの遅延ロードのため定義している
" nmap           K          <Plug>(ref-keyword)
" Open folding. Note: デフォルトでも'foldopen'に"hor"があればlで開くがカーソル移動できないとき(jsonなどでよくある)にうまくいかないのでここで指定。 Refs: <http://leafcage.hateblo.jp/entry/2013/04/24/053113>
nnoremap <expr>l          foldclosed('.') != -1 ? 'zo' : 'l'

" nmap           gf         <Plug>(gf-user-gf)
" nmap           gF         <Plug>(gf-user-gF)
" nmap           <C-w>f     <Plug>(gf-user-<C-w>f)
" nmap           <C-w><C-f> <Plug>(gf-user-<C-w><C-f>)
" nmap           <C-w>F     <Plug>(gf-user-<C-w>F)
" nmap           <C-w>gf    <Plug>(gf-user-<C-w>gf)
" nmap           <C-w>gF    <Plug>(gf-user-<C-w>gF)

" win32yank内の文字を一旦vimのレジスタに登録してからペーストする.
if !has('gui_running')
  " TODO 遅い。クリップボードからペーストしたければtmuxのpaste使えばよいが。(set pasteするのがめんどいけど)
  noremap <silent> p :call setreg('"',system('win32yank.exe -o'))<CR>""p
  noremap <silent> P :call setreg('"',system('win32yank.exe -o'))<CR>""P
endif

" nmap           p          <Plug>(yankround-p)
" nmap           P          <Plug>(yankround-P)
" nmap           <C-p>      <Plug>(yankround-prev)
" nmap           <C-n>      <Plug>(yankround-next)

if !has('gui_running')
  " Note: nmapだとyy,==が効かない
  map           y           <Plug>(operator-stay-cursor-yank)
  map     <expr>=           operator#stay_cursor#wrapper("=")
endif


nnoremap       Y          y$
" nmap           +          <SID>[switch]
" nmap           -          <SID>[Switch]
" Note: <CR>でマッピングするとVrapperで有効にならない
nnoremap       <C-m>      i<CR><Esc>
" Note: <C-;>は無理らしい
" nmap           <A-;>      <Plug>(fontzoom-larger)
" nmap           <A-->      <Plug>(fontzoom-smaller)

nnoremap <C-PageUp>   :tabprevious<CR>
nnoremap <C-PageDown> :tabnext<CR>

" }}}

" Adding to unimpaired plugin mapping {{{
nnoremap [g :tabprevious<CR>
nnoremap ]g :tabnext<CR>
nnoremap [G :tabfirst<CR>
nnoremap ]G :tablast<CR>
nnoremap [w :wincmd W<CR>
nnoremap ]w :wincmd w<CR>
nnoremap [W :wincmd t<CR>
nnoremap ]W :wincmd b<CR>
" }}}
" }}}1

" Plug-ins {{{1
if has('vim_starting')
  let &runtimepath = g:is_win_gui || g:is_jenkins ? s:dotvim_path . ',' . &runtimepath : &runtimepath
endif

" if !has('dummy') " XXX Windowsだと遅い
if !has('gui_running')
  silent! call g:plug#begin(s:plugged_path) " Windowsでgit入れてない場合silentが必要

  " Caution: `for : "*"`としたときfiletypeが設定されない拡張子のとき呼ばれない(e.g. foo.log)。(そもそも`for:"*"は遅延ロードしている意味がないためやらない)
  " General {{{
  Plug 'AndrewRadev/linediff.vim', {'on' : ['Linediff']}
  " Plug 'AndrewRadev/switch.vim', {'on' : ['Switch', 'SwitchReverse']} " Ctrl+aでやりたいが不可。できたとしてもspeeddating.vimと競合
  " Plug 'LeafCage/vimhelpgenerator', {'on' : ['VimHelpGenerator', 'VimHelpGeneratorVirtual']}
  " Plug 'LeafCage/yankround.vim' " TODO:<C-p>もなのでlazy不可
  " Plug 'Shougo/denite.nvim', g:is_win_gui ? {'on' : ['<Plug>[fzy', 'Denite']} : {'on' : []}
  " TODO Vim終了が遅くなる
  " TODO GVim用にパッチを当ててる。。` file_mru.py#L19 'fnamemodify': ':~:s?/d/?D:/?:s?/c/?C:/?',`
  Plug 'Shougo/neomru.vim', g:is_jenkins ? {'on' : []} : {} " Note: ファイル/ディレクトリ履歴のみのため
  " Plug 'Shougo/neosnippet.vim'
  "       \ | Plug 'Shougo/neosnippet-snippets'
  " Plug 'Vimjas/vim-python-pep8-indent', {'for' : ['python']}
  Plug 'airblade/vim-gitgutter'
  " Plug 'aklt/plantuml-syntax', {'for' : 'plantuml'}
  " Plug 'chaquotay/ftl-vim-syntax', {'for' : 'html.ftl'}
  " Plug 'dzeban/vim-log-syntax', {'for' : 'log'} " 逆に見づらいことが多い
  Plug 'editorconfig/editorconfig-vim'
  " Plug 'elzr/vim-json', {'for' : 'json'} " For json filetype.
  Plug 'fatih/vim-go', {'for' : 'go'}
  Plug 'ferrine/md-img-paste.vim', {'for' : 'markdown'}
  " Plug 'fuenor/im_control.vim', g:is_linux ? {} : {'on' : []}
  " Plug 'freitass/todo.txt-vim', {'for' : 'todo'}
  Plug 'glidenote/memolist.vim', {'on' : ['MemoNew']}
  Plug 'godlygeek/tabular', {'for' : 'markdown'}
        \ | Plug 'plasticboy/vim-markdown', {'for' : 'markdown'} " TODO 最近のvimではset ft=markdown不要なのにしているため、autocmdが2回呼ばれてしまう TODO いろいろ不都合有るけどcodeブロックのハイライトが捨てがたい TODO syntaxで箇条書きのネストレベル2のコードブロックの後もコードブロック解除されない
  " FIXME: windows(cui,gui)で動いてない。linuxはいけた。
  Plug 'haya14busa/vim-migemo', {'on' : ['Migemo', '<Plug>(migemo-']}
  " Plug 'haya14busa/vim-auto-programming'
  " Plug 'heavenshell/vim-jsdoc', {'for' : 'javascript'}
  " Plug 'hyiltiz/vim-plugins-profile', {'on' : []} " It's not vim plugin.
  " Plug 'https://gist.github.com/assout/524c4ae96928b3d2474a.git', {'dir' : g:plug_home . '/hz_ja.vim/plugin', 'rtp' : '..', 'on' : ['Hankaku', 'Zenkaku', 'ToggleHZ']}
  " Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install', 'for' : 'markdown' }
  " Plug 'itchyny/vim-parenmatch'
  " Plug 'junegunn/fzf'
  " Plug 'junegunn/fzf.vim', {'on' : ['FzfFiles','FzfGFiles']} " TODO 全コマンド記載
  Plug 'junegunn/vim-easy-align', {'on' : ['<Plug>(LiveEasyAlign)', '<Plug>(EasyAlign)']}
  " Plug 'kamichidu/vim-edit-properties'
  " Plug 'kana/vim-gf-user', {'on' : '<Plug>(gf-user-'}
  " Plug 'kana/vim-submode'
  " Plug 'koron/codic-vim', {'on' : ['Codic']}
  " Plug 'kurkale6ka/vim-swap'
  " Plug 'https://github.com/m-kat/aws-vim', {'for' : 'template'} " Note: `user/reponam`形式だとPlugInstall時に取得できない
  " Plug 'majutsushi/tagbar', {'on' : ['TagbarToggle']}
  " Plug 'marijnh/tern_for_vim', g:is_linux ? {'do' : 'npm install', 'for' : ['javascript']} : {'on' : []} " Note: windowsで動かない
  " Plug 'mattn/benchvimrc-vim', {'on' : 'BenchVimrc'}
  " Plug 'mattn/emmet-vim', {'on' : ['<Plug>[emmet]']}
  " Plug 'maxbrunsfeld/vim-emacs-bindings' " TODO: 'houtsnip/vim-emacscommandline' だとコマンドラインでescが待たされちゃう
  Plug 'mechatroner/rainbow_csv', {'for' : 'csv'}
  " Plug 'medihack/sh.vim', {'for' : 'sh'} " For function block indentation, caseラベルをインデントしたい場合、let g:sh_indent_case_labels = 1
  Plug 'mnishz/colorscheme-preview.vim', {'on' : 'ColorschemePreview'}
  " Plug 'moll/vim-node', g:is_win ? {'on' : []} : {} " Lazyできない TODO: たまにmarkdown開くとき2secくらいかかるっぽい(2分探索で見ていった結果)
  " Plug 'moznion/vim-ltsv', {'for' : 'ltsv'}
  Plug 'nathanaelkane/vim-indent-guides', {'on' : ['IndentGuidesEnable', 'IndentGuidesToggle']}
  " Plug 'othree/yajs.vim' " Note: vim-jaavascriptのようにシンタックスエラーをハイライトしてくれない
  " Plug 'pangloss/vim-javascript' " Note: syntax系のプラグインはlazyできない? TODO es6対応されてない？ Note: 入れないとhtml内の埋め込みscriptがindent崩れる
  " Plug 'osyo-manga/vim-over', {'on' : 'OverCommandLine'}
  " Plug 'powerman/vim-plugin-AnsiEsc', {'on' : 'AnsiEsc'} " vim-scripts/AnsiEsc.vim`でも試してみる？
  " Plug 'scrooloose/vim-slumlord', {'for' : 'plantuml'} " slumlord.vim#L87あたりをコメントアウトしたら動いたが、テキストに生成ダイアグラムが書き込まれるのも微妙なので一旦使わない
  Plug 'schickling/vim-bufonly', {'on' : ['BufOnly', 'BOnly']}
  " Plug 'skanehira/preview-markdown.vim', {'for' : 'markdown'}
  " Plug 'szw/vim-maximizer', {'on' : ['Maximize', 'MaximizerToggle']} " Windowの最大化・復元
  " Plug 't9md/vim-textmanip', {'on' : '<Plug>(textmanip-'} " TODO: 代替探す(日本語化けるのと、たまに不要な空白が入るため)
  " Plug 'thinca/vim-fontzoom', g:is_win_gui ? {} : {'on' : []}
  " Plug 'thinca/vim-localrc', g:is_win ? {'on' :[]} : {'for' : 'vim'}
  " Plug 'thinca/vim-qfreplace', {'on' : 'Qfreplace'} " grepした結果を置換
  " Plug 'thinca/vim-quickrun', {'on' : ['QuickRun']}
  " Plug 'thinca/vim-ref', {'on' : ['Ref', '<Plug>(ref-']}
  "       \ | Plug 'Jagua/vim-ref-gene', {'on' : ['Ref', '<Plug>(ref-']} " TODO: Unite sourceの遅延ロード
  " Plug 'thinca/vim-singleton' " Note: 遅延ロード不可
  Plug 'tomtom/tcomment_vim' " TODO: markdownが`<!-- hoge --->`となるが`<!--- hoge -->`では？
  " Caution: on demand不可。Refs: <https://github.com/junegunn/vim-plug/issues/164>
  Plug 'tpope/vim-fugitive'
        \ | Plug 'junegunn/gv.vim'
        \ | Plug 'skywind3000/asyncrun.vim'
        \ | Plug 'tpope/vim-rhubarb'
        \ | Plug 'shumphrey/fugitive-gitlab.vim'
  " Plug 'tpope/vim-repeat'
  " Plug 'tpope/vim-speeddating'
  Plug 'tpope/vim-unimpaired'
  Plug 'tyru/capture.vim', {'on' : 'Capture'}
  Plug 'tyru/open-browser.vim', {'for' : 'markdown', 'on' : ['<Plug>(openbrowser-', 'OpenBrowser', 'OpenBrowserSearch', 'OpenBrowserSmartSearch', 'PrevimOpen']}
        \ | Plug 'halkn/previm', {'for' : 'markdown', 'on' : 'PrevimOpen', 'branch': 'fix-img-path-in-wslmode' }
  " Plug 'tyru/restart.vim', {'on' : ['Restart', 'RestartWithSession']} " TODO: CUI上でも使いたい
  Plug 'vim-jp/vimdoc-ja'
  " Plug 'vim-scripts/DirDiff.vim', {'on' : 'DirDiff'} " TODO: 文字化けする
  Plug 'vim-scripts/HybridText', {'for' : 'hybrid'}
  " Plug 'vim-scripts/SQLUtilities', {'for' : 'sql'}
  "       \ | Plug 'vim-scripts/Align', {'for' : 'sql'}
  Plug 'w0rp/ale', g:is_win_gui ? {'on' : []} : {'on' : ['ALELint', 'ALEFix'], 'for' : ['sh', 'markdown']}
  " Plug 'wellle/tmux-complete.vim' " Note: auto-progurammingと競合するので一旦やめる
  " Note: Windows以外はvim-misc,vim-shell不要そうだが、無いとtags作られなかった
  " Note: markdownは指定しなくてもtagbarで見れるので良い
  " Plug 'xolox/vim-misc', {'for' : ['vim', 'sh', 'javascript']}
  "       \ | Plug 'xolox/vim-shell',  {'for' : ['vim', 'sh', 'javascript']}
  "       \ | Plug 'xolox/vim-easytags',  {'for' : ['vim', 'sh', 'javascript']}
  " }}}

  " User Operators {{{ Caution: 遅延ロードするといろいろ動かなくなる
  Plug 'kana/vim-operator-user'
        \ | Plug 'rhysd/vim-operator-surround'
        \ | Plug 'kana/vim-operator-replace'
        \ | Plug 'tyru/operator-camelize.vim'
        \ | Plug 'osyo-manga/vim-operator-stay-cursor'
  " }}}

  " User Textobjects {{{
  Plug 'kana/vim-textobj-user'
        \ | Plug 'kana/vim-textobj-function'
        \ | Plug 'kana/vim-textobj-indent'
        \ | Plug 'kana/vim-textobj-line'
        \ | Plug 'mattn/vim-textobj-url'
        \ | Plug 'osyo-manga/vim-textobj-multiblock'
        \ | Plug 'pocke/vim-textobj-markdown'
        \ | Plug 'sgur/vim-textobj-parameter'
        \ | Plug 'thinca/vim-textobj-between'
        \ | Plug 'thinca/vim-textobj-function-javascript'
        \ | Plug 'kana/vim-textobj-entire'
  " }}}

  " Colorschemes {{{
  Plug 'w0ng/vim-hybrid'
  " }}}

  call g:plug#end()

endif

if s:HasPlugin('ale') " {{{
  let g:ale_sign_column_always = 1
  let g:ale_lint_on_text_changed = 'never'
  let b:ale_fixers = {'python': ['autopep8']}
  let g:ale_python_autopep8_options = '--aggressive --aggressive'
  " TODO 実行後カーソル位置が変わってしまう
  nnoremap <SID>[ale-lint] :<C-u>ALELint<CR>
  nnoremap <SID>[ale-fix] :<C-u>ALEFix<CR>
  autocmd vimrc User ALELintPost :unsilent echo "Lint done!"
  " autocmd vimrc User ALELintPost :silent echo "Lint done!"
endif " }}}

if s:HasPlugin('asyncrun.vim') " {{{
  command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>
endif " }}}

if s:HasPlugin('completor.vim') " {{{
  let g:completor_markdown_omni_trigger = '..'
endif " }}}

if s:HasPlugin('denite.nvim') " {{{
  function! s:DeniteSettings()
    call denite#custom#option('_', 'highlight_matched_char', 'SpellBad')

    call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>')
    call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>')
    call denite#custom#map('insert', '<C-a>', '<Home>')
    call denite#custom#map('insert', '<C-e>', '<End>')
    call denite#custom#map('insert', '<C-f>', '<Right>')
    call denite#custom#map('insert', '<C-b>', '<Left>')

    call denite#custom#alias('source', 'file_rec/git', 'file_rec')
    call denite#custom#var('file_rec/git', 'command',['git', 'ls-files', '-co', '--exclude-standard'])

    nnoremap <Plug>[fzy]        <Nop>
    nnoremap <expr><Plug>[fzy]m ':<C-u>Denite file:' . expand('~/memo/') . ' file:' . expand('~/memo_internal/') . '<CR>'
    nnoremap <expr><Plug>[fzy]n ':<C-u>Denite file:' . expand('~/Documents/notes') . '<CR>'
    nnoremap <expr><Plug>[fzy]r ':<C-u>Denite file_mru<CR>'
    nnoremap <expr><Plug>[fzy]p ':<C-u>Denite file_rec/git<CR>'
  endfunction
  autocmd vimrc User denite.nvim call s:DeniteSettings()
endif " }}}

if s:HasPlugin('emmet-vim') " {{{
  let g:user_emmet_leader_key='<Nop>'

  let g:user_emmet_next_key = '<C-y>n'
  let g:user_emmet_prev_key = '<C-y>N'
  let g:user_emmet_anchorizeurl_key = '<Plug>[emmet]'
endif " }}}

if s:HasPlugin('fzf.vim') " {{{
  let g:fzf_command_prefix = 'Fzf'
endif " }}}

if s:HasPlugin('fugitive-gitlab.vim') " {{{
  " Note: .vimrc.localで指定する
  " let g:fugitive_gitlab_domains = ['https://my.gitlab.com']
endif " }}}

if s:HasPlugin('HybridText') " {{{
  autocmd vimrc BufRead,BufNewFile *.{txt,mindmap} nested setfiletype hybrid
endif " }}}

if has('kaoriya') " {{{
  let g:plugin_dicwin_disable = 1 " dicwin plugin無効
  let g:plugin_scrnmode_disable = 1 " scrnmode plugin無効
else
  command! -nargs=0 CdCurrent cd %:p:h
endif " }}}

if s:HasPlugin('md-img-paste.vim') " {{{
  autocmd vimrc FileType markdown command! PasteImage :call mdip#MarkdownClipboardImage()
endif " }}}

if s:HasPlugin('memolist.vim') " {{{
  let g:memolist_filename_prefix_none = 1
  let g:memolist_memo_suffix = 'md'
  let g:memolist_path = expand('~/memo')
  let g:memolist_template_dir_path = g:memolist_path

  function! s:MemoGrep(word)
    call histadd('cmd', 'MemoGrep '  . a:word)
    " Caution: a:wordはオプションが入ってくるかもなので""で囲まない
    execute ':silent grep -r --exclude-dir=_book ' . a:word . ' ' . g:memolist_path
  endfunction
  command! -nargs=1 -complete=command MemoGrep call <SID>MemoGrep(<q-args>)

  " TODO local配下も再帰的に。
  nnoremap       <SID>[memolist]n  :<C-u>MemoNew<CR>
  nnoremap <expr><SID>[memolist]g ':<C-u>MemoGrep ' . input('MemoGrep word: ') . '<CR>'
endif " }}}

if s:HasPlugin('neomru.vim') " {{{
  " Note: Windows GVimで、ネットワーク上のファイルがあるとUnite候補表示時に遅くなる？ -> '^\(\/\/\|fugitive\)'
  let g:neomru#directory_mru_ignore_pattern = '^\(\/\/\|fugitive\)' " or '^fugitive'
  let g:neomru#directory_mru_limit = 500
  let g:neomru#do_validate = 1 " Cautioin: 有効にしちゃうとvim終了時結構遅くなるかも。 TODO たまに正常なファイルも消えちゃうっポイ
  let g:neomru#file_mru_limit = 0
  let g:neomru#follow_links = 1
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
  " let g:previm_open_cmd = '/mnt/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe'
  let g:previm_open_cmd = '/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe'
  let g:previm_wsl_mode = 1
  function! s:PrevimSettings()
    nnoremap <buffer><SID>[previm] :<C-u>PrevimOpen<CR>
  endfunction
  autocmd vimrc User previm call s:PrevimSettings()
endif " }}}

if s:HasPlugin('restart.vim') " {{{
  command! -bar RestartWithSession let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages' | Restart
endif " }}}

if s:HasPlugin('switch.vim') " {{{
  " Note: 定義順は優先度を考慮する(範囲の広い定義は後ろに定義する) " TODO: Dictionary定義はSwitchReverse効かない " TODO: 入れ子のときおかしくなる(e.g. [foo[bar]] ) " TODO: undoするとカーソル位置が行頭になっちゃう
  let g:switch_custom_definitions = [
        \  ['foo',     'bar',       'baz',     'qux',       'quux',     'corge',  'grault',    'garply', 'waldo',     'fred',    'plugh',    'xyzzy',    'thud', ],
        \  ['hoge',    'piyo',      'fuga',    'hogera',    'hogehoge', 'moge',   'hage',      ],
        \  ['public',  'protected', 'private', ],
        \  ['Sun',     'Mon',       'Tue',     'Wed',       'Thu',      'Fri',    'Sut'],
        \  ['Jan',     'Feb',       'Mar',     'Apr',       'May',      'Jun',    'Jul',       'Aug',    'Sep',       'Oct',     'Nov',      'Dec'],
        \  ['日',      '月',        '火',      '水',        '木',       '金',     '土'],
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

  " Note: 以下は略称と競合してしまうので設定しない
  " \  ['Sunday',  'Monday',    'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  " \  ['Janualy', 'Februaly',  'March',   'April',     'May',      'June',   'July',      'August', 'SePtember', 'October', 'November', 'Decemer'],

  " FIXME: 空白区切りの文字列をクォート切り替え
  " \  {
  " \     '\v\$(.{-})\s' : '"$\1"',
  " \     '\v"\$(.{-})\s"' : '''$\1''',
  " \     '\v''\$(.{-})''' : '$\1',
  " \  },

  nnoremap <SID>[switch] :<C-u>Switch<CR>
  nnoremap <SID>[Switch] :<C-u>SwitchReverse<CR>
endif " }}}

if s:HasPlugin('tagbar') " {{{
  nnoremap <SID>[tagbar] :<C-u>TagbarToggle<CR>
  let g:tagbar_type_markdown = { 'ctagstype' : 'markdown', 'kinds' : [ 'h:headings' ], 'sort' : 0 }
endif " }}}

if s:HasPlugin('tcomment_vim') " {{{
  let g:tcomment_textobject_inlinecomment='iC' " cはtextobj-markdownで使用。
endif " }}}

" if s:HasPlugin('tmux-complete.vim') " {{{
"   let g:tmuxcomplete#trigger = 'completefunc' " Note: completefuncはvim-auto-programmingで使いたいので。
"   " Note. hack (ftplugin/html.vimで上書きされてしまうため)
"   autocmd vimrc FileType markdown setlocal omnifunc=tmuxcomplete#complete
" endif " }}}

if s:HasPlugin('todo.txt-vim') " {{{
  " TODO: Unite source化など
  nnoremap       <SID>[todo]l  :<C-u>edit ~/Documents/todo/todo.txt<CR>
  nnoremap       <SID>[todo]L  :<C-u>edit ~/Documents/todo/done.txt<CR>
  nnoremap       <SID>[todo]r  :<C-u>edit ~/Documents/todo/report.txt<CR>
  nnoremap <expr><SID>[todo]g ':<C-u>TodoGrep ' . input('TodoGrep word: ') . '<CR>'
endif " }}}

if s:HasPlugin('vim-auto-programming') " {{{
  set omnifunc=autoprogramming#complete " Note: tmux-complete.vimとかぶることに注意。omnifuncにしてみたら動かないケースあり
  autocmd vimrc User vim-auto-programming setlocal omnifunc=autoprogramming#complete
endif " }}}

if s:HasPlugin('vim-easy-align') " {{{
  xmap <SID>[align] <Plug>(LiveEasyAlign)*
  nmap <SID>[align] <Plug>(LiveEasyAlign)<Plug>(textobj-indent-i)*

  let g:easy_align_delimiters = {
        \ '-': { 'pattern': '-' },
        \ '>': { 'pattern': '>>\|=>\|>' },
        \ '/': {
        \     'pattern':         '//\+\|/\*\|\*/',
        \     'delimiter_align': 'l',
        \     'ignore_groups':   ['!Comment'] },
        \ ']': {
        \     'pattern':       '[[\]]',
        \   },
        \ ')': {
        \     'pattern':       '[()]',
        \     'left_margin':   0,
        \     'right_margin':  0,
        \     'stick_to_left': 0
        \   },
        \ 'd': {
        \     'pattern':      ' \(\S\+\s*[;=]\)\@=',
        \     'left_margin':  0,
        \     'right_margin': 0
        \   },
        \ 't': { 'pattern': '\t' }
        \ }

  function! s:CsvSettings()
    nmap <buffer><SID>[context] <Plug>(EasyAlign)<Plug>(textobj-indent-i)*,,
  endfunction
  autocmd vimrc FileType csv call s:CsvSettings()
endif " }}}

if s:HasPlugin('vim-easytags') " {{{
  let g:easytags_async = has('gui_running') ? 0 : 1 " TODO: GUIのときバックグラウンドプロセスがたまっていっちゃうっポイ
  let g:easytags_auto_highlight = 0
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
  autocmd vimrc User vim-gf-user call g:gf#user#extend('GfFile', 1000)
endif " }}}

if s:HasPlugin('vim-gitgutter') " {{{
  let g:gitgutter_map_keys = 0 " ic, acはvim-textobj-markdown用に取っておきたいため
  nmap ]c <Plug>(GitGutterNextHunk)
  nmap [c <Plug>(GitGutterPrevHunk)
  nmap <buffer><SID>[gitgutter] <Plug>(GitGutterPreviewHunk)
endif " }}}

if s:HasPlugin('vim-go') " {{{
  let g:go_fmt_command = "goimports"
endif " }}}

if s:HasPlugin('vim-hybrid') " {{{
  " colorscheme hybrid " 基本的にはTerminal(WSL)のカラースキーマ側で設定するので設定しない
endif " }}}

if s:HasPlugin('vim-json') " {{{
  let g:vim_json_syntax_conceal = 0
endif " }}}

if s:HasPlugin('vim-localrc') " {{{
  " TODO: ghq対応後無効
  let g:localrc_filename = '.vimrc.development'
endif " }}}

if s:HasPlugin('vim-markdown') " {{{
  let g:vim_markdown_no_default_key_mappings = 1
  let g:vim_markdown_folding_disabled = 1

  function! s:VimMarkdownSettings() " Refs: <:help restore-position>
    " Note: commentsを空にして箇条書きの継続を無効、indentexprを空にして不要な箇条書きのインデント補正を無効にする
    setlocal comments= indentexpr=

    nnoremap <buffer><SID>[markdown_l]     :.HeaderIncrease<CR>
    vnoremap <buffer><SID>[markdown_l]      :HeaderIncrease<CR>`<v`>
    nnoremap <buffer><SID>[markdown_L] msHmt:HeaderIncrease<CR>'tzt`s

    nnoremap <buffer><SID>[markdown_h]     :.HeaderDecrease<CR>
    vnoremap <buffer><SID>[markdown_h]      :HeaderDecrease<CR>`<v`>
    nnoremap <buffer><SID>[markdown_H] msHmt:HeaderDecrease<CR>'tzt`s

    nnoremap <buffer><SID>[context]    :<C-u>TableFormat<CR>

    nmap <buffer>( <Plug>Markdown_MoveToPreviousHeader
    nmap <buffer>) <Plug>Markdown_MoveToNextHeader

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
  nmap <SID>[Replace]  <Plug>(operator-replace)$
endif " }}}

if s:HasPlugin('vim-operator-surround') " {{{
  " Note: 行指定は`sasa`、1文字を`sal`と使い分ける。
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

  nmap <SID>[surround-a]u <Plug>(operator-surround-append)<Plug>(textobj-url-a)

  nmap <SID>[surround-a]4 <Plug>(operator-surround-append)$
  nmap <SID>[surround-d]4 <Plug>(operator-surround-delete)$
  nmap <SID>[surround-r]4 <Plug>(operator-surround-replace)$
  nmap <SID>[surround-A]  <Plug>(operator-surround-append)$
  nmap <SID>[surround-D]  <Plug>(operator-surround-delete)$
  nmap <SID>[surround-R]  <Plug>(operator-surround-replace)$

  let g:operator#surround#blocks = {
        \ 'markdown' : [
        \       { 'block' : ["```\n", "\n```"], 'motionwise' : ['line'], 'keys' : ['c'] },
        \ ] }
endif " }}}

if s:HasPlugin('vim-quickrun') " {{{
  " TODO: プレビューウィンドウで開けないか(szで閉じやすいので)
  " TODO: 基本システムの関連付けで開くようにする？
  nnoremap <SID>[quickrun]  :<C-u>QuickRun<CR>

  let g:quickrun_config = { '_' : { 'runner' : has('patch-7.4.2298') ? 'job' : 'system'} }
  let g:quickrun_config['javascript'] = { 'command': 'node' }
  let g:quickrun_config['html'] = { 'command': g:is_linux ? 'google-chrome' : 'chrome', 'outputter': 'null' }
  let g:quickrun_config['plantuml'] = { 'command': g:is_linux ? 'google-chrome' : 'chrome', 'outputter': 'null' }
  let g:quickrun_config['markdown'] = { 'type': 'markdown/markdown-to-slides' }
  let g:quickrun_config['markdown/markdown-to-slides'] = { 'command': 'markdown-to-slides', 'cmdopt': '-w -d -s ~/.remark.css', 'outputter': 'browser'}
  if g:is_win
    let g:quickrun_config['markdown/markdown-to-slides']['runner'] = 'job'
    let g:quickrun_config['markdown/markdown-to-slides']['exec'] = ['tmp=/tmp/%s:t.html \&\& %c %s -o \$tmp %o \&\& chrome.exe \$tmp']
  endif
endif " }}}

if s:HasPlugin('vim-ref') " {{{
  " TODO: プレビューウィンドウで開けないか(szで閉じやすいので)
  let g:ref_man_lang = 'ja_JP.UTF-8'
  let g:ref_noenter = 1
  let g:ref_cache_dir = expand('~/.cache/.vim_ref_cache')
  " TODO: デフォルトに一括追加の指定方法(現状は上書き) " TODO: Windows gvimでshのman開けない
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

  call g:submode#enter_with('buffer', 'n', '', '<subP>b', ':bprevious<CR>')
  call g:submode#enter_with('buffer', 'n', '', '<subN>b', ':bnext<CR>')
  call g:submode#map('buffer', 'n', '', 'k', ':bprevious<CR>')
  call g:submode#map('buffer', 'n', '', 'j', ':bnext<CR>')
  call g:submode#map('buffer', 'n', '', 'K', ':bfirst<CR>')
  call g:submode#map('buffer', 'n', '', 'J', ':blast<CR>')

  " TODO: args,quickfix,loclist,diff先頭と末尾に行き過ぎたときエラーでsubmode抜けたくない(循環するとややこしい?)
  call g:submode#enter_with('args', 'n', '', '<subP>a', ':previous<CR>')
  call g:submode#enter_with('args', 'n', '', '<subN>a', ':next<CR>')
  call g:submode#map('args', 'n', '', 'k', ':previous<CR>')
  call g:submode#map('args', 'n', '', 'j', ':next<CR>')
  call g:submode#map('args', 'n', '', 'K', ':first<CR>')
  call g:submode#map('args', 'n', '', 'J', ':last<CR>')

  call g:submode#enter_with('quickfix', 'n', '', '<subP>q', ':cprevious<CR>')
  call g:submode#enter_with('quickfix', 'n', '', '<subN>q', ':cnext<CR>')
  call g:submode#map('quickfix', 'n', '', 'k', ':cprevious<CR>')
  call g:submode#map('quickfix', 'n', '', 'j', ':cnext<CR>')
  call g:submode#map('quickfix', 'n', '', 'K', ':cfirst<CR>')
  call g:submode#map('quickfix', 'n', '', 'J', ':clast<CR>')
  call g:submode#map('quickfix', 'n', '', '<C-k>', ':cpfile<CR>')
  call g:submode#map('quickfix', 'n', '', '<C-j>', ':cnfile<CR>')

  call g:submode#enter_with('loclist', 'n', '', '<subP>l', ':lprevious<CR>')
  call g:submode#enter_with('loclist', 'n', '', '<subN>l', ':lnext<CR>')
  call g:submode#map('loclist', 'n', '', 'k', ':lprevious<CR>')
  call g:submode#map('loclist', 'n', '', 'j', ':lnext<CR>')
  call g:submode#map('loclist', 'n', '', 'K', ':lfirst<CR>')
  call g:submode#map('loclist', 'n', '', 'J', ':llast<CR>')
  call g:submode#map('loclist', 'n', '', '<C-k>', ':lpfile<CR>')
  call g:submode#map('loclist', 'n', '', '<C-j>', ':lnfile<CR>')

  call g:submode#enter_with('diff', 'n', '', '<subP>c', '[c')
  call g:submode#enter_with('diff', 'n', '', '<subN>c', ']c')
  call g:submode#map('diff', 'n', '', 'k', '[c')
  call g:submode#map('diff', 'n', '', 'j', ']c')
endif " }}}

if s:HasPlugin('vim-swap') " {{{
  let g:swap_custom_ops = ['<-', '->']
  vmap <SID>[swap] <plug>SwapSwapOperands
  vmap <SID>[Swap] <plug>SwapSwapPivotOperands
  nmap <SID>[swap] <plug>SwapSwapWithR_WORD
  nmap <SID>[Swap] <plug>SwapSwapWithL_WORD
endif " }}}

if s:HasPlugin('vim-textmanip') " {{{
  xmap <C-j> <Plug>(textmanip-move-down)
  xmap <C-k> <Plug>(textmanip-move-up)
  xmap <C-h> <Plug>(textmanip-move-left)
  xmap <C-l> <Plug>(textmanip-move-right)
endif " }}}

if s:HasPlugin('vim-textobj-between') " {{{
  " デフォルトのfはtextobj-functionとかぶるので変更(textobj-functionのマッピングはVrapperと合わせたいのでこちらを変える)
  let g:textobj_between_no_default_key_mappings = 1 " 'd'istanceに変える。。
  omap id <Plug>(textobj-between-i)
  omap ad <Plug>(textobj-between-a)
  xmap id <Plug>(textobj-between-i)
  xmap ad <Plug>(textobj-between-a)
endif " }}}

if s:HasPlugin('vim-textobj-multiblock') " {{{
  let g:textobj_multiblock_blocks = [
        \  [ '`', '`', 1 ],
        \  [ '*', '*', 1 ],
        \  [ '_', '_', 1 ],
        \  [ '\~', '\~', 1 ],
        \  [ '|', '|', 1 ],
        \  [ '>', '<', 1 ],
        \  [ '```', '```' ],
        \  [ '```\<.*\>', '```' ],
        \]
  omap ib <Plug>(textobj-multiblock-i)
  omap ab <Plug>(textobj-multiblock-a)
  xmap ib <Plug>(textobj-multiblock-i)
  xmap ab <Plug>(textobj-multiblock-a)
endif " }}}

if s:HasPlugin('vim-textobj-parameter') " {{{
  " Vrapper textobj-argsと合わせる('a'rguments) デフォルトは','
  let g:textobj_parameter_no_default_key_mappings = 1
  omap ia <Plug>(textobj-parameter-i)
  omap aa <Plug>(textobj-parameter-a)
  xmap ia <Plug>(textobj-parameter-i)
  xmap aa <Plug>(textobj-parameter-a)
endif " }}}

" # Auto-commands {{{1
" Caution: 当セクションはVim-Plugより後に記述する必要がある(Vim-Plugの記述でfiletype onされる。autocomd FileTypeの処理はftpluginの処理より後に実行させたいため) Refs: <http://d.hatena.ne.jp/kuhukuhun/20081108/1226156420>
augroup vimrc
  " XXX WSLでリフレッシュされないので..
  if !has('gui_running')
    autocmd VimLeave * :!clear
  endif

  " QuickFixを自動で開く " Caution: grep, makeなど以外では呼ばれない (e.g. syntastic)
  " Note: fugitive, AsyncRunの時にフォーカスが奪われるので暫定でwincmd pして戻してる
  autocmd QuickfixCmdPost [^l]* nested if len(getqflist()) != 0  | copen | wincmd p | endif
  autocmd QuickfixCmdPost l*    nested if len(getloclist(0)) != 0 | lopen | wincmd p | endif
  " QuickFix内<CR>で選択できるようにする(上記QuickfixCmdPostでも設定できるが、syntasticの結果表示時には呼ばれないため別で設定)
  autocmd BufReadPost quickfix,loclist setlocal modifiable nowrap | nnoremap <silent><buffer>q :quit<CR>
  autocmd BufWritePre * let &backupext = '.' . strftime("%Y%m%d_%H%M%S")
  " Set freemaker filetype
  autocmd BufNewFile,BufRead *.ftl nested setlocal filetype=html.ftl " Caution: setfiletypeだとuniteから開いた時に有効にならない
  autocmd BufNewFile,BufRead *.csv,*.CSV setfiletype csv " for rainbow plugin

  " Note: ftpluginで上書きされてしまうことがあるためここで設定している" Note: formatoptionsにo含むべきか難しい
  autocmd FileType * setlocal formatoptions-=c formatoptions-=t
  autocmd FileType gitconfig setlocal noexpandtab
  autocmd FileType go setlocal noexpandtab
  autocmd FileType hybrid setlocal noexpandtab
  autocmd FileType java setlocal noexpandtab
  autocmd FileType javascript command! -buffer FixEslint :call system("eslint --fix " . expand("%")) | :edit!
  " Note: aws.json を考慮して*jsonとしている
  autocmd FileType *json
        \   setlocal foldmethod=syntax foldlevel=99
        \ | command! -buffer -range=% FormatJson <line1>,<line2>!jq "."
  " \ | command! -buffer -range=% FormatJson <line1>,<line2>!python -m json.tool
  " Note: 箇条書きの2段落目のインデントがおかしくなることがあったのでcinkeysを空にする(行に:が含まれてたからかも)
  autocmd FileType markdown
        \   setlocal nospell tabstop=4 shiftwidth=4 cinkeys=''
        \ | command! -buffer FixTextlint :call system("textlint --fix " . expand("%")) <BAR> :edit!
  autocmd FileType sh setlocal noexpandtab
  " Note: Windowsでxmllintはencode指定しないとうまくいかないことがある
  autocmd FileType xml,ant
        \   setlocal foldmethod=syntax foldlevelstart=99 foldlevel=99 noexpandtab
        \ | command! -buffer -range=% FormatXml <line1>,<line2>!xmllint --encode utf-8 --format --recover - 2>/dev/null
  autocmd FileType xml,html,ant call s:JumpToNextMapping()

  function! Yank(ch, msg)
    call system('win32yank.exe -i', @")
  endfunction

  if !has('gui_running')
    autocmd TextYankPost * :call job_start(['echo'], { "callback" : "Yank"}) " XXX 非同期でも大きいと重くなる
  endif
augroup END
" }}}1

" # After {{{1
nohlsearch " Don't (re)highlighting the last search pattern on reloading.
" source $VIMRUNTIME/macros/matchit.vim " Enable matchit. Slow

if has('vim_starting') && has('reltime')
  let g:startuptime = reltime()
  autocmd vimrc VimEnter * let g:startuptime = reltime(g:startuptime) | redraw | echomsg 'startuptime: ' . reltimestr(g:startuptime)
endif

" }}}1

" vim:nofoldenable:

