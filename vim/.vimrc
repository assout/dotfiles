" Index {{{1
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
" * TODO neocompleteでたまに日本語入力が変になる
" * TODO setなどの末尾にコメント入れるとvrapperで適用されない
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
  " TODO オプションなどでbufferに出力もしたい
  if has('clipboard')
    redir @+>
  else
    redir @">
  endif
  execute a:command
  redir END
endfunction
command! -nargs=1 -complete=command MyCapture call <SID>Capture(<q-args>)

function! s:ToggleTab()
  setlocal expandtab! | retab " caution: retab! は使わない(意図しない空白も置換されてしまうため)
  if ! &expandtab " <http://vim-jp.org/vim-users-jp/2010/04/30/Hack-143.html>
    execute '%substitute@^\v(%( {' . &l:tabstop . '})+)@\=repeat("\t", len(submatch(1))/' . &l:tabstop . ')@e' | normal! ``
  endif
endfunction
command! MyToggleTab call <SID>ToggleTab()

function! s:ChangeTabstep(size)
  if &l:expandtab
    execute '%substitute@\v^(%( {' . &l:tabstop . '})+)@\=repeat(" ", len(submatch(1)) / ' . &l:tabstop . ' * ' . a:size . ')@eg' | normal! ``
  endif
  let &l:tabstop = a:size
  let &l:shiftwidth = a:size
endfunction
command! -nargs=1 MyChangeTabstep call <SID>ChangeTabstep(<q-args>)

function! s:InsertString(pos, str) range
  execute a:firstline . ',' . a:lastline . 'substitute/' . a:pos . '/' . substitute(a:str, '/', '\\/', 'g')
endfunction
command! -range -nargs=1 MyInsertPrefix <line1>,<line2>call <SID>InsertString('^', <f-args>)
command! -range -nargs=1 MyInsertSuffix <line1>,<line2>call <SID>InsertString('$', <f-args>)

" TODO 消す。(RefソースorUniteソースにする)
" TODO 超汚い。あとたまにバグる(カレントバッファがPreviewになってしまう)
function! s:DictionaryTranslate(...) " required gene.txt, kaoriya/dicwin.vimで良いが和英したいため
  let l:word = a:0 == 0 ? expand('<cword>') : a:1
  call histadd('cmd', 'MyTranslate '  . l:word)
  if l:word ==# '' " caution if-endifをパイプで一行で書くと特定環境(office)でvimrcが無効になる
    return
  endif
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
  if @z !=# '' " caution 特定環境(office)でput zのエラーが出るため
    silent 0put z
  endif
  let @z = l:esc
  silent call append(line('.'), '==')
  silent 1delete
  silent wincmd p
endfunction
command! -nargs=? MyTranslate call <SID>DictionaryTranslate(<f-args>)

function! s:IsHome()
  return $USERNAME ==# 'oji'
endfunction

function! s:IsOffice()
  return $USERNAME ==# 'admin'
endfunction

function! s:IsPluginEnabled() " pluginが有効か返す
  " return isdirectory(s:bundlePath)
  return isdirectory(s:bundlePath) && ! has('win32unix')
  " return isdirectory(s:bundlePath) && !(!has('gui_running') && $TERM ==# 'cygwin') " TODO workaround, winのconsoleだと読み込まれないので.
endfunction

function! s:HasPlugin(plugin) " pluginが存在するか返す
  return !empty(matchstr(&runtimepath, a:plugin))
endfunction

function! s:RestoreCursorPosition()
  let l:ignore_filetypes = ['gitcommit']
  if index(l:ignore_filetypes, &l:filetype) >= 0
    return
  endif
  if line("'\"") > 1 && line("'\"") <= line('$')
    execute 'normal! g`"'
  endif
endfunction

command! -bang MyBufClear %bdelete<bang>
command! -bang MyBClear   MyBufClear<bang>
command! -range=% MyTrimSpace <line1>,<line2>s/[ \t]\+$// | nohlsearch | normal ``

" }}}1

" Section; Let defines {{{1
" windowsでも~/.vimにしてもよいが何かとvimfilesのほうが都合よい(migemo pluginがデフォルトでruntimepathとしてに行ってくれたり？)
let s:bundlePath = has('win32') || has('win32unix') ? $HOME . '/vimfiles/bundle/' : $HOME . '/.vim/bundle/'
let g:is_bash = 1 " shellのハイライトをbash基準にする
let g:loaded_matchparen = 1
let g:netrw_liststyle = 3 " netrwのデフォルト表示スタイル変更

if has('win32unix') && ! s:IsHome() " for mintty.
  let &t_ti .= "\e[1 q"
  let &t_SI .= "\e[5 q"
  let &t_EI .= "\e[1 q"
  let &t_te .= "\e[0 q"
endif
" }}}1

" Section; Auto-commands {{{1
augroup vimrc
  autocmd!
  " double byte space highlight
  autocmd VimEnter,Colorscheme * highlight DoubleByteSpace term=underline ctermbg=LightMagenta guibg=LightMagenta
  autocmd VimEnter,WinEnter * match DoubleByteSpace /　/
  " set markdown filetype
  autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} setfiletype markdown
  autocmd BufNewFile,BufRead *.ftl setfiletype html.ftl
  " enable spell on markdown file
  autocmd FileType markdown highlight! def link markdownItalic LineNr | setlocal spell
  autocmd FileType vim setlocal expandtab
  " 改行時の自動コメント継続をやめる(o,Oコマンドでの改行時のみ)
  autocmd FileType * set textwidth=0 formatoptions-=o
  " QuickFixを自動で開く、QuickFix内<CR>で選択できるようにする
  autocmd QuickfixCmdPost [^l]* if len(getqflist()) != 0  | copen | endif | setlocal modifiable nowrap
  autocmd QuickfixCmdPost l*    if len(getloclist(0)) != 0 | lopen | endif | setlocal modifiable nowrap
  if executable('python')
    autocmd BufNewFile,BufRead *.json setlocal equalprg=python\ -m\ json.tool
  endif
  if executable('xmllint') " TODO pretty format(xml,html,xhtml)
    " autocmd FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
  endif
  " restore cursor position
  autocmd BufReadPost * call s:RestoreCursorPosition()
augroup END
" }}}1

" Section; Options {{{1
set autoindent
set background=dark
set backspace=indent,eol,start
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
set grepprg=grep\ -nH
" If true Vim master, use English help file. NeoBundle 'vim-jp/vimdoc-ja'. :h index or :h index@ja .
set helplang=en,ja
set hidden
set history=200
set hlsearch
set ignorecase
set incsearch
" TODO やっぱ↓をやめるので_区切りのテキストオブジェクトが別途ほしい
" set iskeyword-=_
" Open Vim internal help by K command
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
set shiftwidth=2
set showcmd
set showtabline=1
set shortmess+=atTO
set sidescrolloff=5
set smartcase
set smartindent
if has('unix')
  set spellfile=~/Dropbox/spell/en.utf-8.add
else
  set spellfile=D:/admin/Documents/spell/en.utf-8.add
endif
set softtabstop=0
set splitbelow
set splitright
" スペルチェックで日本語は除外する
set spelllang& spelllang+=cjk
if has('path_extra')
  set tags& tags+=tags;
else
  set tags& tags+=.git/tags
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
vnoremap y    y`>
" }}}

" Shortcut key prefix mappings {{{

" <SID>[shortcut]a,d,rはsurround-pluginで使用
" <SID>[shortcut]mはmaximizer-pluginで使用
" <SID>[shortcut]H,J,K,Lはsubmode-pluginで使用
map      s                <SID>[shortcut]
noremap  <SID>[shortcut]  <Nop>
noremap  <SID>[shortcut]? ?
noremap  <SID>[shortcut]/ /
map      <SID>[shortcut]a <Nop>
nnoremap <SID>[shortcut]c <C-w>c
map      <SID>[shortcut]d <Nop>
nnoremap <SID>[shortcut]h <C-w>h
map      <SID>[shortcut]i <SID>[insert]
nnoremap <SID>[shortcut]j <C-w>j
nnoremap <SID>[shortcut]k <C-w>k
nnoremap <SID>[shortcut]l <C-w>l
map      <SID>[shortcut]m <Nop>
nnoremap <SID>[shortcut]n :<C-u>nohlsearch<CR>
nmap     <SID>[shortcut]o <SID>[open]
noremap  <SID>[shortcut]p :<C-u>split<CR>
map      <SID>[shortcut]r <Nop>
nnoremap <SID>[shortcut]t :<C-u>MyTranslate<CR>
nnoremap <SID>[shortcut]u :<C-u>update $MYVIMRC<Bar>:update $MYGVIMRC<Bar>:source $MYVIMRC<Bar>:source $MYGVIMRC<CR>
noremap  <SID>[shortcut]v :<C-u>vsplit<CR>
nnoremap <SID>[shortcut]x :<C-u>bdelete<CR>
nnoremap <SID>[shortcut]z :<C-u>pclose<CR>

" TODO to plugin
noremap <SID>[insert]  <Nop>
noremap <silent><expr> <SID>[insert]p ':MyInsertPrefix ' . input('prefix:') . '<CR>'
noremap <silent>       <SID>[insert]*  :MyInsertPrefix * <CR>
noremap <silent>       <SID>[insert]1  :MyInsertPrefix # <CR>A
noremap <silent>       <SID>[insert]2  :MyInsertPrefix ## <CR>A
noremap <silent>       <SID>[insert]3  :MyInsertPrefix ### <CR>A
noremap <silent>       <SID>[insert]4  :MyInsertPrefix #### <CR>A
noremap <silent>       <SID>[insert]>  :MyInsertPrefix > <CR>
noremap <silent>       <SID>[insert]T  :MyInsertPrefix TODO <CR>
noremap <silent>       <SID>[insert]f  :MyInsertPrefix file://<CR>
noremap <silent><expr> <SID>[insert]s ':MyInsertSuffix ' . input('suffix:') . '<CR>'
noremap <silent><expr> <SID>[insert]d ':MyInsertSuffix ' . strftime('\ @%Y-%m-%d') . '<CR>'
noremap <silent><expr> <SID>[insert]t ':MyInsertSuffix ' . strftime('\ @%H:%M:%S') . '<CR>'
noremap <silent><expr> <SID>[insert]n ':MyInsertSuffix ' . strftime('\ @%Y-%m-%d %H:%M:%S') . '<CR>'
noremap <silent><expr> <SID>[insert]a ':MyInsertSuffix \ @' . input('author:') . '<CR>'
noremap <silent>       <SID>[insert]l  :MyInsertSuffix \<Space>\ <CR>

nnoremap <SID>[open] <Nop>
" resolveしなくても開けるがfugitiveで対象とするため
" caution: <silent>つけないで<expr>だけだとvrapperが有効にならない
" TODO windowsのとき$MYVIMRCの展開だと対象にならない
let g:myvimrcPath = has('unix') ? resolve(expand($MYVIMRC)) : 'D:/admin/Development/dotfiles/vim/.vimrc'
nnoremap <silent><expr> <SID>[open]v ':<C-u>edit ' . g:myvimrcPath . '<CR>'
if s:IsOffice()
  nnoremap <SID>[open]i :<C-u>edit D:/admin/Tools/ChatAndMessenger/logs/どなどな.log<CR>
endif
" }}}

" Ctrl,Alt key prefix mappings {{{
nnoremap <M-h> gT
nnoremap <M-l> gt
nnoremap <M-t> :<C-u>tabedit<CR>
nnoremap <M-c> :<C-u>tabclose<CR>

" Use ':tjump' instead of ':tag'.
nnoremap <C-]> g<C-]>
" }}}

" []key prefix mappings(based on unimpaired plugin) {{{
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
" adding to unimpaired plugin mapping
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
" TODO 一単語Delete
" cnoremap <M-d>
" }}}1

" Section; Plug-ins {{{1
if s:IsPluginEnabled() && isdirectory(expand(s:bundlePath . 'neobundle.vim'))
  if has('vim_starting')
    execute 'set runtimepath+=' . s:bundlePath . 'neobundle.vim/'
  endif
  call g:neobundle#begin(expand(s:bundlePath))

  NeoBundle 'AndrewRadev/switch.vim'
  NeoBundle 'Arkham/vim-quickfixdo' " like argdo, bufdo. TODO 本体に入ったらしい
  NeoBundle 'Jagua/vim-ref-gene', {'depends' : ['thinca/vim-ref', 'Shougo/unite.vim']}
  NeoBundle 'KazuakiM/vim-qfsigns'
  NeoBundle 'LeafCage/vimhelpgenerator'
  NeoBundle 'LeafCage/yankround.vim', {'depends' : ['Shougo/unite.vim']}
  NeoBundle 'Shougo/neobundle.vim', {'depends' : ['Shougo/unite.vim'], 'disabled' : !executable('git')}
  NeoBundle 'Shougo/neocomplete', {'disabled' : !has('lua')}
  NeoBundle 'Shougo/neomru.vim', {'depends' : ['Shougo/unite.vim']}
  NeoBundle 'Shougo/unite-outline', {'depends' : ['Shougo/unite.vim']}
  NeoBundle 'Shougo/unite.vim'
  NeoBundle 'Shougo/vimfiler.vim', {'depends' : ['Shougo/unite.vim']}
  if s:IsHome()
    NeoBundle 'Shougo/vimproc', {'disabled' : has('kaoriya'), 'build' : { 'windows' : 'make -f make_mingw32.mak', 'cygwin' : 'make -f make_cygwin.mak', 'mac' : 'make -f make_mac.mak', 'unix' : 'make -f make_unix.mak', }, }
  endif
  NeoBundle 'TKNGUE/hateblo.vim', {'depends' : ['mattn/webapi-vim', 'Shougo/unite.vim'], 'disabled' : has('win32')} " entryの保存位置を指定できるためfork版を使用。本家へもPRでてるので、取り込まれたら見先を変える。本家は('moznion/hateblo.vim')
  NeoBundle 'aklt/plantuml-syntax'
  NeoBundle 'assout/unite-todo', {'depends' : ['Shougo/unite.vim']}
  NeoBundle 'chaquotay/ftl-vim-syntax'
  NeoBundle 'chase/vim-ansible-yaml'
  NeoBundle 'dannyob/quickfixstatus' " TODO 原因不明のエラー -> syntastic 入れてる時っぽい
  NeoBundle 'elzr/vim-json'
  NeoBundle 'fuenor/im_control.vim'
  NeoBundle 'glidenote/memolist.vim', {'depends' : ['Shougo/unite.vim']}
  NeoBundle 'gregsexton/VimCalc', {'disabled' : !has('python2')} " TODO msys2のpythonだと有効にならない
  NeoBundle 'h1mesuke/vim-alignta', {'depends' : ['Shougo/unite.vim']}
  NeoBundle 'haya14busa/vim-migemo', {'disabled' : !executable('cmigemo')}
  NeoBundle 'itchyny/calendar.vim'
  NeoBundle 'kana/vim-fakeclip'
  NeoBundle 'kana/vim-gf-user'
  NeoBundle 'kana/vim-submode'
  NeoBundle 'kannokanno/previm', {'disabled' : has('win32') || has('win32unix'), 'depends' : ['tyru/open-browser.vim']} " for home
  NeoBundle 'kannokanno/previm', {'disabled' : ! (has('win32') || has('win32unix')), 'depends' : ['tyru/open-browser.vim'], 'rev' : '1.3' } " for office TODO 最新版だとIE Tabで表示されない(印刷プレビュー使いたい)
  NeoBundle 'koron/codic-vim' " TODO vimprocなどで非同期化されてる？
  NeoBundle 'lambdalisue/vim-gista', {'depends' : ['Shougo/unite.vim', 'tyru/open-browser.vim'], 'disabled' : !executable('curl') && !executable('wget')}
  NeoBundle 'mattn/emmet-vim' " markdownのurlタイトル取得:<C-y>a コメントアウトトグル : <C-y>/
  NeoBundle 'mattn/excitetranslate-vim', {'depends' : ['mattn/webapi-vim']}
  NeoBundle 'mattn/qiita-vim', {'depends' : ['Shougo/unite.vim']}
  NeoBundle 'mattn/webapi-vim', {'disabled' : !executable('curl') && !executable('wget')}
  NeoBundle 'medihack/sh.vim' " for function block indentation, caseラベルをインデントしたい場合、let g:sh_indent_case_labels = 1 TODO functionのインデントがだめ(fork版なら行けそうだったがだめっぽい)
  NeoBundle 'osyo-manga/shabadou.vim'
  NeoBundle 'osyo-manga/vim-watchdogs', {'depends' : ['osyo-manga/shabadou.vim']}
  NeoBundle 'pangloss/vim-javascript' " for indent only
  NeoBundle 'rhysd/unite-codic.vim', {'depends' : ['Shougo/unite.vim', 'koron/codic-vim']}
  NeoBundle 'schickling/vim-bufonly'
  " NeoBundle 'scrooloose/syntastic' " TODO quickfixstatusと競合する
  NeoBundle 'szw/vim-maximizer' " windowの最大化・復元
  NeoBundle 'szw/vim-tags', {'disabled' : !executable('ctags'), 'depends': ['tpope/vim-dispatch'] }
  NeoBundle 't9md/vim-textmanip'
  NeoBundle 'thinca/vim-localrc'
  NeoBundle 'thinca/vim-qfreplace' " grepした結果を置換
  NeoBundle 'thinca/vim-quickrun'
  NeoBundle 'thinca/vim-ref'
  NeoBundle 'thinca/vim-singleton', {'disabled' : !has('clientserver')}
  NeoBundle 'tomtom/tcomment_vim'
  NeoBundle 'tpope/vim-abolish'
  NeoBundle 'tpope/vim-dispatch'
  NeoBundle 'tpope/vim-fugitive', {'disabled' : !executable('git')}
  NeoBundle 'tpope/vim-repeat'
  NeoBundle 'tpope/vim-unimpaired', {'depends': ['tpope/vim-repeat']}
  NeoBundle 'tsukkee/unite-tag', {'depends' : ['Shougo/unite.vim']}
  NeoBundle 'tyru/open-browser.vim'
  NeoBundle 'tyru/restart.vim', {'disabled' : has('win32') || has('win32unix')} " for home
  NeoBundle 'tyru/restart.vim', {'disabled' : ! (has('win32') || has('win32unix')), 'rev' : 'v0.0.8' } " for home TODO 最新版はwindowsで異常終了する
  NeoBundle 'ujihisa/unite-colorscheme', {'depends' : ['Shougo/unite.vim']}
  NeoBundle 'vim-jp/vimdoc-ja'
  NeoBundle 'vim-scripts/DirDiff.vim' " TODO 文字化けする
  NeoBundle 'vim-scripts/HybridText'

  " Operators {{{
  NeoBundle 'kana/vim-operator-user'
  NeoBundle 'kana/vim-operator-replace', {'depends': ['kana/vim-operator-user']}
  NeoBundle 'rhysd/vim-operator-surround', {'depends': ['kana/vim-operator-user']} " life changing. sdb,sab.
  NeoBundle 'syngan/vim-operator-inserttext', {'depends': ['kana/vim-operator-user']}
  NeoBundle 'tyru/operator-camelize.vim', {'depends': ['kana/vim-operator-user']}
  " }}}

  " Textobjects {{{
  NeoBundle 'kana/vim-textobj-user'
  NeoBundle 'kana/vim-textobj-entire', {'depends': ['kana/vim-textobj-user']}
  NeoBundle 'kana/vim-textobj-function', {'depends': ['kana/vim-textobj-user']}
  NeoBundle 'kana/vim-textobj-indent', {'depends': ['kana/vim-textobj-user']}
  NeoBundle 'kana/vim-textobj-line', {'depends': ['kana/vim-textobj-user']}
  NeoBundle 'mattn/vim-textobj-url', {'depends': ['kana/vim-textobj-user']}
  NeoBundle 'rhysd/vim-textobj-anyblock', {'depends': ['kana/vim-textobj-user']} " life changing. dib, dab.
  NeoBundle 'sgur/vim-textobj-parameter', {'depends': ['kana/vim-textobj-user']}
  NeoBundle 'thinca/vim-textobj-between', {'depends': ['kana/vim-textobj-user']}
  NeoBundle 'thinca/vim-textobj-comment', {'depends': ['kana/vim-textobj-user']}

  " colorschemes {{{
  NeoBundle 'altercation/vim-colors-solarized'
  NeoBundle 'chriskempson/vim-tomorrow-theme'
  NeoBundle 'sickill/vim-monokai'
  NeoBundle 'tomasr/molokai'
  NeoBundle 'w0ng/vim-hybrid'
  " }}}

  call g:neobundle#end()
  filetype plugin indent on " Required!
  NeoBundleCheck " Installation check.
endif

" plugin prefix mappings {{{
if s:IsPluginEnabled()
  map  <Space>              <SID>[plugin]
  map  <SID>[plugin]<Space> <SID>[sub_plugin]

  xmap <SID>[plugin]a       <SID>[alignta]
  map  <SID>[plugin]c       <SID>[camelize]
  nmap <SID>[plugin]e       <SID>[excite]
  nmap <SID>[plugin]f       <SID>[fugitive]
  map  <SID>[plugin]g       <SID>[gista]
  nmap <SID>[plugin]h       <SID>[hateblo]
  nmap <SID>[plugin]m       <SID>[memolist]
  map  <SID>[plugin]o       <SID>[open-browser]
  nmap <SID>[plugin]p       <SID>[previm]
  nmap <SID>[plugin]q       <SID>[qiita]
  nmap <SID>[plugin]r       <SID>[ref]
  nmap <SID>[plugin]s       <SID>[syntastic]
  map  <SID>[plugin]t       <SID>[todo]
  nmap <SID>[plugin]u       <SID>[unite]
  nmap <SID>[plugin]w       <SID>[watchdogs]
  nmap <SID>[plugin]/       <SID>[migemo]
  " TODO <SID>つけれない
  nmap <SID>[plugin][       [subP]
  " TODO <SID>つけれない
  nmap <SID>[plugin]]       [subN]

  nmap <SID>[sub_plugin]q   <SID>[quickrun]
  " TODO <SID>つけれない
  map  <SID>[sub_plugin]s   <SID>[switch]

  map  R                <SID>[replace]
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

if s:HasPlugin('alignta') " {{{
  xnoremap <SID>[alignta]<CR> :Alignta<Space>
  xnoremap <SID>[alignta]s    :Alignta<Space><-<Space>
  " alignta for 'm'ap. 空白区切りの要素を整列(e.g. nmap hoge fuga)(最初の2要素のみ)(コメント行は除く)
  xnoremap <SID>[alignta]m    :Alignta<Space>v/^" <<0 \s\S/2
endif " }}}

if s:HasPlugin('calendar.vim') " {{{
  let g:calendar_google_calendar = has('unix') ? 1 : 0
  let g:calendar_google_task = has('unix') ? 1 : 0
endif " }}}

if s:HasPlugin('excitetranslate-vim') " {{{
  noremap  <SID>[excite] :<C-u>ExciteTranslate<CR>
  xnoremap <SID>[excite] :ExciteTranslate<CR>
endif " }}}

if s:HasPlugin('fugitive') " {{{ TODO fugitiveが有効なときのみマッピングしたい
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
        \ 'user': 'assout',
        \ 'api_key': g:hateblo_api_key,
        \ 'api_endpoint': 'https://blog.hatena.ne.jp/assout/assout.hatenablog.com/atom',
        \ 'WYSIWYG_mode': 0,
        \ 'always_yes': 0,
        \ 'edit_command': 'edit'
        \ } " api_keyはvimrc.localから設定
  let g:hateblo_dir = '$HOME/.cache/hateblo/blog'

  nnoremap <SID>[hateblo]l :<C-u>HatebloList<CR>
  nnoremap <SID>[hateblo]c :<C-u>HatebloCreate<CR>
  nnoremap <SID>[hateblo]C :<C-u>HatebloCreateDraft<CR>
  nnoremap <SID>[hateblo]d :<C-u>HatebloDelete<CR>
  nnoremap <SID>[hateblo]u :<C-u>HatebloUpdate<CR>
endif " }}}

if s:HasPlugin('HybridText') " {{{
  augroup vimrc
    autocmd BufRead,BufNewFile *.{txt,mindmap} setlocal filetype=hybrid
  augroup END
endif " }}}

if s:HasPlugin('im_control') " {{{
  let g:IM_CtrlMode = s:IsHome() ? 1 : 4 " caution: linuxのときは設定しなくても期待した挙動になるけど一応
  if s:IsHome()
    function! g:IMCtrl(cmd)
      if a:cmd ==? 'On'
        let l:res = system('xvkbd -text "\[Henkan_Mode]\" > /dev/null 2>&1')
      elseif a:cmd ==? 'Off'
        let l:res = system('xvkbd -text "\[Muhenkan]" > /dev/null 2>&1') " caution: なぜかmozcの設定でCtrl+MuhenkanをIMEオフに割り当てないといけない。(Ctrl+Shif+Deleteだと<C-o>とかが使えなくなる)
      elseif a:cmd ==? 'Toggle'
        let l:res = system('xvkbd -text "\[Zenkaku_Hankaku]" > /dev/null 2>&1')
      endif
      return ''
    endfunction
  endif
endif " }}}

if has('kaoriya') " {{{
  let g:plugin_hz_ja_disable = 1 " hz_ja plugin無効
  let g:plugin_dicwin_disable = 1 " dicwin plugin無効
  let g:plugin_scrnmode_disable = 1 " scrnmode plugin無効
else
  command! -nargs=0 CdCurrent cd %:p:h
endif " }}}

if s:HasPlugin('memolist') " {{{
  let g:memolist_memo_suffix = 'md'
  let g:memolist_path = s:IsHome() ? '~/Dropbox/memolist' : 'D:/admin/Documents/memolist'
  let g:memolist_template_dir_path = g:memolist_path

  function! s:MyMemoGrep(word)
    call histadd('cmd', 'MyMemoGrep '  . a:word)
    execute ':grep -r --exclude-dir=.git ' . a:word . ' ' . g:memolist_path
  endfunction
  command! -nargs=1 -complete=command MyMemoGrep call <SID>MyMemoGrep(<q-args>)

  nnoremap <SID>[memolist]a :<C-u>MemoNew<CR>
  if s:HasPlugin('unite')
    let g:unite_source_alias_aliases = {
          \'memolist' : { 'source' : 'file_rec', 'args' : g:memolist_path },
          \'memolist_reading' : { 'source' : 'file', 'args' : g:memolist_path },
          \}
    call g:unite#custom_source('memolist', 'sorters', ['sorter_ftime', 'sorter_reverse'])
    call g:unite#custom_source('memolist', 'matchers', ['converter_tail_abbr', 'matcher_default', 'matcher_hide_hidden_files'])
    call g:unite#custom#source('memolist', 'ignore_pattern', 'exercises\|reading\|\(png\|gif\|jpeg\|jpg\)$')
    call g:unite#custom_source('memolist_reading', 'sorters', ['sorter_ftime', 'sorter_reverse'])
    call g:unite#custom_source('memolist_reading', 'matchers', ['converter_tail_abbr', 'matcher_default', 'matcher_hide_hidden_files'])
    call g:unite#custom#source('memolist_reading', 'ignore_pattern', '^\%(.*exercises\|.*reading\)\@!.*\zs.*\|\(png\|gif\|jpeg\|jpg\)$')
    nnoremap <SID>[memolist]l :<C-u>Unite memolist -buffer-name=memolist<CR>
    nnoremap <SID>[memolist]L :<C-u>Unite memolist_reading -buffer-name=memolist_reading<CR>
  else
    nnoremap <SID>[memolist]l :<C-u>MemoList<CR>
  endif
  nnoremap <expr><SID>[memolist]g ':<C-u>MyMemoGrep ' . input('MyMemoGrep word: ') . '<CR>'
endif " }}}

if s:HasPlugin('neocomplete') " {{{
  let g:neocomplete#enable_at_startup = has('lua') && has('unix') ? 1 : 0 " 基本は開発時のみ必要なので
endif " }}}

if s:HasPlugin('open-browser') " {{{
  nmap <SID>[open-browser] <Plug>(openbrowser-smart-search)
  vmap <SID>[open-browser] <Plug>(openbrowser-smart-search)
endif " }}}

if s:HasPlugin('operator-camelize') " {{{
  map <SID>[camelize] <Plug>(operator-camelize-toggle)
endif " }}}

if s:HasPlugin('operator-replace') " {{{
  map <SID>[replace] <Plug>(operator-replace)
endif " }}}

if s:HasPlugin('previm') " {{{
  let g:previm_custom_css_path = s:IsHome() ? '/home/oji/Development/dotfiles/vim/previm.css' : 'D:/admin/Development/dotfiles/vim/previm.css'
  nnoremap <SID>[previm] :<C-u>PrevimOpen<CR>
endif " }}}

if s:HasPlugin('qiita-vim') " {{{
  nnoremap <SID>[qiita]l    :<C-u>Unite qiita<CR>
  nnoremap <SID>[qiita]<CR> :<C-u>Qiita<CR>
  nnoremap <SID>[qiita]c    :<C-u>Qiita<CR>
  nnoremap <SID>[qiita]e    :<C-u>Qiita -e<CR>
  nnoremap <SID>[qiita]d    :<C-u>Qiita -d<CR>
endif " }}}

if s:HasPlugin('quickrun') " {{{
  nnoremap <SID>[quickrun] :<C-u>QuickRun<CR>
  let g:quickrun_config = {
        \   'plantuml' :{
        \       'type' : 'my_plantuml'
        \   },
        \   'my_plantuml' : {
        \  'command': 'plantuml'
        \, 'exec': ['%c %s', 'eog %s:p:r.png']
        \, 'outputter': 'null'
        \   },
        \}
endif " }}}

" TODO Restart時にカーソル位置復元したい
if s:HasPlugin('restart.vim') " {{{
  command! -bar RestartWithSession let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages' | Restart
endif " }}}

if s:HasPlugin('singleton') && has('gui_running') " {{{
  let g:singleton#opener = 'vsplit'
  call g:singleton#enable()
endif " }}}

if s:HasPlugin('switch.vim') " {{{
  " TODO <SID>[switch]としたい
  let g:switch_mapping = '<Space><Space>s'
  let g:switch_custom_definitions =
        \ [
        \   ['foo', 'bar', 'baz'],
        \   ['hoge', 'fuga', 'piyo']
        \ ]
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

  " TODO lwindow表示などをautocmdで設定したい(autocmd QuickfixCmdPostを拾わないっぽい)
  nnoremap <SID>[syntastic] :<C-u>SyntasticCheck<CR>:lwindow<Bar>setlocal modifiable nowrap<CR>
endif " }}}

if s:HasPlugin('tcomment_vim') " {{{
  let g:tcommentTextObjectInlineComment = 'iC'
  call g:tcomment#DefineType('java', '// %s')
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
    call g:unite#take_action('move', a:candidates)
    call g:unite#force_redraw() " 呼ばないと表示更新されない
  endfunction

  function! s:unite_my_keymappings()
    " TODO sort
    " nnoremap <buffer><expr>         S unite#mappings#set_current_filters(empty(unite#mappings#get_current_filters()) ? ['sorter_reverse'] : [])
    nnoremap <buffer><expr>         f unite#smart_map('f', unite#do_action('vimfiler'))
    nnoremap <buffer><expr>         m unite#smart_map('m', unite#do_action('relative_move'))
    nnoremap <buffer><expr>         v unite#smart_map('v', unite#do_action('vsplit'))
    nnoremap <buffer><expr>         x unite#smart_map('x', unite#do_action('start'))
    nnoremap <buffer><expr><nowait> p unite#smart_map('p', unite#do_action('split'))
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

  call g:unite#custom#action('file,directory', 'relative_move', s:my_relative_move)
  call g:unite#custom#alias('file', 'delete', 'vimfiler__delete')
  call g:unite#custom#default_action('directory', 'vimfiler')
  call g:unite#custom#source('bookmark', 'sorters', ['sorter_ftime', 'sorter_reverse'])
  call g:unite#custom#source('file_rec', 'ignore_pattern', '\(png\|gif\|jpeg\|jpg\)$')
  call g:unite#custom#source('file_rec/async', 'ignore_pattern', '\(png\|gif\|jpeg\|jpg\)$')
  if has('win32') " windowsではよく日本語使うので
    call g:unite#filters#matcher_default#use(['matcher_migemo'])
  endif

  nnoremap <SID>[unite]<CR> :<C-u>Unite<CR>
  nnoremap <SID>[unite]b    :<C-u>Unite buffer -buffer-name=buffer<CR>
  nnoremap <SID>[unite]B    :<C-u>Unite bookmark -buffer-name=bookmark<CR>
  nnoremap <SID>[unite]d    :<C-u>Unite directory -buffer-name=directory<CR>
  nnoremap <SID>[unite]f    :<C-u>Unite file -buffer-name=file<CR>
  nnoremap <SID>[unite]g    :<C-u>Unite grep -buffer-name=grep -no-empty<CR>
  nnoremap <SID>[unite]m    :<C-u>Unite mapping -buffer-name=mapping<CR>
  nnoremap <SID>[unite]o    :<C-u>Unite outline -buffer-name=outline -no-quit -vertical -winwidth=30 -direction=botright<CR>
  nnoremap <SID>[unite]r    :<C-u>Unite resume -buffer-name=resume<CR>
  nnoremap <SID>[unite]R    :<C-u>Unite register -buffer-name=register<CR>
  nnoremap <SID>[unite]s    :<C-u>Unite find -buffer-name=find<CR>
  nnoremap <SID>[unite]t    :<C-u>Unite tag -buffer-name=tag -no-quit -vertical -winwidth=30 -direction=botright<CR>
  nnoremap <SID>[unite]T    :<C-u>Unite tab -buffer-name=tab<CR>
  nnoremap <SID>[unite]w    :<C-u>Unite window -buffer-name=window<CR>
  if has('unix')
    nnoremap <SID>[unite]D :<C-u>Unite directory_rec/async -buffer-name=directory_rec/async<CR>
    nnoremap <SID>[unite]F :<C-u>Unite file_rec/async -buffer-name=file_rec/async<CR>
  else
    nnoremap <SID>[unite]D :<C-u>Unite directory_rec -buffer-name=directory_rec<CR>
    nnoremap <SID>[unite]F :<C-u>Unite file_rec -buffer-name=file_rec<CR>
  endif
  if s:HasPlugin('yankround')
    nnoremap <SID>[unite]y :<C-u>Unite yankround -buffer-name=yankround<CR>
  else
    nnoremap <SID>[unite]y :<C-u>Unite history/yank -buffer-name=histry/yank<CR>
  endif

  if s:HasPlugin('neomru') " {{{
    let g:neomru#directory_mru_limit = 500
    let g:neomru#do_validate = 0
    let g:neomru#file_mru_limit = 500
    let g:neomru#filename_format = ''

    nmap     <SID>[unite]n  <neomru>
    nnoremap <neomru>f :<C-u>Unite neomru/file -buffer-name=neomru/file<CR>
    nnoremap <neomru>d :<C-u>Unite neomru/directory -buffer-name=neomru/directory<CR>
  endif " }}}

  if s:HasPlugin('unite-codic') " {{{
    nnoremap <expr> <SID>[unite]c ':<C-u>Unite codic -vertical -winwidth=30 -direction=botright -input=' . expand('<cword>') . '<CR>'
    nnoremap        <SID>[unite]C  :<C-u>Unite codic -vertical -winwidth=30 -direction=botright -start-insert<CR>
  endif " }}}

  if s:HasPlugin('unite-todo') " {{{
    let g:unite_todo_note_suffix = 'md'
    let g:unite_todo_data_directory = has('unix') ? '~/Dropbox' : 'D:/admin/Documents'

    function! s:TodoGrep(word)
      call histadd('cmd', 'MyTodoGrep '  . a:word)
      execute ':grep ' . a:word . ' ' . g:unite_todo_data_directory . '/todo/note/*.md '
    endfunction
    command! -nargs=1 -complete=command MyTodoGrep call <SID>TodoGrep(<q-args>)

    noremap  <SID>[todo]a       :UniteTodoAddSimple -memo<CR>
    noremap  <SID>[todo]q       :UniteTodoAddSimple<CR>
    nnoremap <SID>[todo]l       :Unite todo:undone -buffer-name=todo<CR>
    nnoremap <SID>[todo]L       :Unite todo -buffer-name=todo<CR>
    nnoremap <expr><SID>[todo]g ':<C-u>MyTodoGrep ' . input('MyTodoGrep word: ') . '<CR>'
  endif " }}}
endif " }}}

if s:HasPlugin('vimfiler') " {{{
  let g:vimfiler_safe_mode_by_default = 0 " This variable controls vimfiler enter safe mode by default.
  let g:vimfiler_as_default_explorer = 1 " If this variable is true, Vim use vimfiler as file manager instead of |netrw|.
endif " }}}

if s:HasPlugin('vim-ansible-yaml') " {{{
  let g:ansible_options = {'ignore_blank_lines': 1}
endif " }}}

if s:HasPlugin('vim-fakeclip') " {{{
  if (! has('gui_running')) && s:IsHome()
    " TODO pasteは効くがyank,deleteは効かない, TODO 矩形モードのコピペがちょっと変になる
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
  function! g:GfFile() " refs <http://d.hatena.ne.jp/thinca/20140324/1395590910>
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

if s:HasPlugin('vim-localrc') " {{{
  let g:localrc_filename = '.vimrc.development'
endif " }}}

if s:HasPlugin('vim-maximizer') " {{{
  let g:maximizer_set_default_mapping = 0
  noremap <SID>[maximizer] :<C-u>MaximizerToggle<CR>
endif " }}}

if s:HasPlugin('vim-migemo') " {{{
  if has('migemo')
    if has('vim_starting') | call g:migemo#SearchChar(0) | endif " caution: probably slow
    nnoremap <SID>[migemo] g/
  else
    nnoremap <SID>[migemo] :<C-u>Migemo<Space>
  endif
endif " }}}

if s:HasPlugin('vim-operator-surround') " {{{
  " refs <http://d.hatena.ne.jp/syngan/20140301/1393676442>
  " refs <http://www.todesking.com/blog/2014-10-11-surround-vim-to-operator-vim/>
  let g:operator#surround#blocks = deepcopy(g:operator#surround#default_blocks)
  call add(g:operator#surround#blocks['-'], { 'block' : ['<!-- ', ' -->'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['c']} )

  map <silent> <SID>[surround-a] <Plug>(operator-surround-append)
  map <silent> <SID>[surround-d] <Plug>(operator-surround-delete)
  map <silent> <SID>[surround-r] <Plug>(operator-surround-replace)

  if s:HasPlugin('vim-textobj-anyblock')
    nmap <silent><SID>[surround-a]b <Plug>(operator-surround-append)<Plug>(textobj-anyblock-a)
    nmap <silent><SID>[surround-d]b <Plug>(operator-surround-delete)<Plug>(textobj-anyblock-a)
    nmap <silent><SID>[surround-r]b <Plug>(operator-surround-replace)<Plug>(textobj-anyblock-a)
  endif

  if s:HasPlugin('vim-textobj-between')
    nmap <silent><SID>[surround-a]d <Plug>(operator-surround-append)<Plug>(textobj-between-a)
    nmap <silent><SID>[surround-d]d <Plug>(operator-surround-delete)<Plug>(textobj-between-a)
    nmap <silent><SID>[surround-r]d <Plug>(operator-surround-replace)<Plug>(textobj-between-a)
  endif

  if s:HasPlugin('vim-textobj-line')
    nmap <silent><SID>[surround-a]l <Plug>(operator-surround-append)<Plug>(textobj-line-a)
    nmap <silent><SID>[surround-d]l <Plug>(operator-surround-delete)<Plug>(textobj-line-a)
    nmap <silent><SID>[surround-r]l <Plug>(operator-surround-replace)<Plug>(textobj-line-a)
  endif

  if s:HasPlugin('vim-textobj-url')
    nmap <silent><SID>[surround-a]u <Plug>(operator-surround-append)<Plug>(textobj-url-a)
    " TODO no block matches to the region となる
    nmap <silent><SID>[surround-d]u <Plug>(operator-surround-delete)<Plug>(textobj-url-a)
    " TODO appendの動きになってしまう
    nmap <silent><SID>[surround-r]u <Plug>(operator-surround-replace)<Plug>(textobj-url-a)
  endif
endif " }}}

if s:HasPlugin('vim-ref') " {{{
  let g:ref_man_lang = 'ja_JP.UTF-8'
  let g:ref_cache_dir = '~/.cache/.vim_ref_cache'
  augroup vimrc
    autocmd FileType ref call s:initialize_ref_viewer()
  augroup END
  function! s:initialize_ref_viewer()
    resize 5
  endfunction

  if has('unix')
    nnoremap <expr> <SID>[ref]m ':<C-u>Ref man<Space>' . expand('<cword>') . '<CR>'
  endif
  if executable('elinks') || executable('w3m') || executable('links')|| executable('lynx')
    let g:ref_source_webdict_sites = {
          \ 'je'  : { 'url': 'http://dictionary.infoseek.ne.jp/jeword/%s', 'line': 15},
          \ 'ej'  : { 'url': 'http://dictionary.infoseek.ne.jp/ejword/%s', 'line': 15},
          \ 'wiki': { 'url': 'http://ja.wikipedia.org/wiki/%s', 'line': 23}, }
    let g:ref_source_webdict_sites.default = 'ej'
    let g:ref_source_webdict_use_cache = 1

    nnoremap <SID>[ref]w<CR> :<C-u>Ref webdict<Space>
    nnoremap <SID>[ref]wj    :<C-u>Ref webdict je<Space>
    nnoremap <SID>[ref]we    :<C-u>Ref webdict ej<Space>
  endif
  " TODO 選択範囲の単語で検索
  " TODO unite-actioinでyank
  " TODO unite重い
  " TODO コマンド履歴に残したい
  " TODO 和英ができない
  " TODO キャッシュ化されている？
  if s:HasPlugin('vim-ref-gene')
    nnoremap <expr> <SID>[ref]g ':<C-u>Ref gene<Space>' . expand('<cword>') . '<CR>'
    nnoremap <expr> <SID>[ref]G ':<C-u>Ref gene<Space>'
  endif
endif " }}}

if s:HasPlugin('vim-submode') " {{{ caution: prefix含めsubmode nameが長すぎるとInvalid argumentとなる(e.g. prefixを<submode>とするとエラー)
  call g:submode#enter_with('winsize', 'n', '', 'sH', '<C-w><')
  call g:submode#enter_with('winsize', 'n', '', 'sL', '<C-w>>')
  call g:submode#enter_with('winsize', 'n', '', 'sK', '<C-w>-')
  call g:submode#enter_with('winsize', 'n', '', 'sJ', '<C-w>+')
  call g:submode#map('winsize', 'n', '', 'h', '<C-w><')
  call g:submode#map('winsize', 'n', '', 'l', '<C-w>>')
  call g:submode#map('winsize', 'n', '', 'H', '5<C-w><')
  call g:submode#map('winsize', 'n', '', 'L', '5<C-w>>')
  call g:submode#map('winsize', 'n', '', 'k', '<C-w>-')
  call g:submode#map('winsize', 'n', '', 'j', '<C-w>+')
  call g:submode#map('winsize', 'n', '', 'K', '5<C-w>-')
  call g:submode#map('winsize', 'n', '', 'J', '5<C-w>+')

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

if s:HasPlugin('vim-tags') " {{{
  let g:vim_tags_auto_generate = has('unix') ? 1 : 0
  let g:vim_tags_cache_dir = expand('$HOME/.cache')
  let g:vim_tags_use_vim_dispatch = s:HasPlugin('vim-dispatch') ? 1 : 0
  if s:IsOffice()
    " let g:vim_tags_project_tags_command = "ctags.exe"
    let g:vim_tags_project_tags_command = "{CTAGS} -R"
    " let g:vim_tags_project_tags_command = "{CTAGS} -R {OPTIONS} {DIRECTORY}"
    " let g:vim_tags_project_tags_command = "{CTAGS} -R --disable-external-sort {DIRECTORY}"
  endif
endif " }}}

if s:HasPlugin('vim-textmanip') " {{{
  xmap <C-j> <Plug>(textmanip-move-down)
  xmap <C-k> <Plug>(textmanip-move-up)
  xmap <C-h> <Plug>(textmanip-move-left)
  xmap <C-l> <Plug>(textmanip-move-right)
endif " }}}

if s:HasPlugin('vim-textobj-between') " {{{
  " textobj-functionとかぶるので変更(textobj-functionのマッピングはvrapperと合わせたいのでこちらを変える)
  let g:textobj_between_no_default_key_mappings = 1 " 'd'istanceに変える。。
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

if s:HasPlugin('vim-watchdogs') " {{{
  nnoremap <SID>[watchdogs] :<C-u>WatchdogsRun<CR>
  let g:watchdogs_check_BufWritePost_enable = 1

  " Caution: quickfix開くとhookが動かない
  " TODO quickfix modifiable
  " \   'outputter/quickfix/open_cmd' : 'cwindow | setlocal modifiable',
  " TODO shellcheck,mdl のみ動作確認済み
  let g:quickrun_config = {
        \ 'watchdogs_checker/_' : {
        \   'outputter/quickfix/open_cmd' : '',
        \   'runner/vimproc/updatetime' : 30,
        \   'hook/echo/enable' : 1,
        \   'hook/echo/output_success' : 'No Errors Found.',
        \   'hook/echo/output_failure' : 'Errors Found!',
        \   'hook/qfsigns_update/enable_exit': 1,
        \   'hook/quickfix_status_enable/enable_exit' : 1,
        \ },
        \
        \ 'sh/watchdogs_checker' : {
        \   'type'
        \     : executable('shellcheck') ? 'watchdogs_checker/shellcheck'
        \     : executable('checkbashisms') ? 'watchdogs_checker/checkbashisms'
        \     : executable('bashate') ? 'watchdogs_checker/bashate'
        \     : '',
        \ },
        \ 'watchdogs_checker/shellcheck' : {
        \   'command' : 'shellcheck',
        \   'cmdopt'  : '-f gcc',
        \ },
        \ 'watchdogs_checker/bashate' : {
        \   'command' : 'bashate',
        \ },
        \ 'watchdogs_checker/checkbashisms' : {
        \   'command' : 'checkbashisms',
        \   'cmdopt'  : '-f',
        \ },
        \
        \ 'markdown/watchdogs_checker': {
        \  'type'
        \    : executable('redpen') ? 'watchdogs_checker/redpen'
        \    : executable('mdl') ? 'watchdogs_checker/mdl'
        \    : '',
        \ },
        \ 'watchdogs_checker/mdl' : {
        \   'command' : 'mdl',
        \ },
        \ 'watchdogs_checker/redpen' : {
        \   'command' : 'redpen',
        \   'cmdopt'  : '-c ~/dotfiles/redpen-conf-en.xml',
        \   'exec'    : '%c %o %s:p 2> /dev/null',
        \ },
        \
        \ 'yaml/watchdogs_checker': {
        \   'type': executable('js-yaml') ? 'watchdogs_checker/js-yaml' : '',
        \ },
        \ 'watchdogs_checker/js-yaml' : {
        \   'command' : 'js-yaml',
        \ },
        \}
  call g:watchdogs#setup(g:quickrun_config)
endif " }}}

if s:HasPlugin('yankround') " {{{ TODO 未保存のバッファでpするとエラーがでる(Could not get security context security...) <http://lingr.com/room/vim/archives/2014/04/13>
  let g:yankround_dir = '~/.cache/yankround'
endif " }}}
" }}}1

" Section; After {{{1
filetype on
syntax on

" :qで誤って終了してしまうのを防ぐためcloseに置き換える。caution: Vrapperでエラーになる
cabbrev q <C-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'close' : 'q')<CR>

nohlsearch " Don't (re)highlighting the last search pattern on reloading.

if s:HasPlugin('vim-hybrid')
  function! s:DefineMyHighlight()
    highlight clear SpellBad
    highlight clear SpellCap
    highlight clear SpellRare
    highlight clear SpellLocal
    highlight SpellBad   cterm=underline ctermfg=Red gui=undercurl guisp=Red
    highlight SpellCap   cterm=underline ctermfg=Blue gui=undercurl guisp=Blue
    highlight SpellRare  cterm=underline ctermfg=Magenta gui=undercurl guisp=Magenta
    highlight SpellLocal cterm=underline ctermfg=Cyan gui=undercurl guisp=Cyan
  endfunction
  augroup vimrc
    autocmd ColorScheme * :call <SID>DefineMyHighlight()
  augroup END
  colorscheme hybrid
endif
" }}}1

" vim:nofoldenable:

