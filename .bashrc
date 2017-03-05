#!/bin/bash

# [Index] {{{1
# Notes:
# - 基本デフォルト厨とする(aliasとかもあんま作らない)
# - which使うと遅い
# }}}1

# [Begin] {{{1

# Start profile
is_profile=$(if [ "$1" = "-p" ] ; then echo 0; fi)
if [ "${is_profile}" ] ; then
  PS4='+ $(date "+%S.%3N")\011 '
  exec 3>&2 2>/tmp/bashstart.$$.log
  set -x
fi

# Source global definitions
[ -f /etc/bashrc ] && source /etc/bashrc
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=
# }}}1

# [Define, Export variables] {{{1

# Note: readonlyにしない(当ファイルの処理時間見るためにsoucreすることがある)
is_unix=$(if [ "${OSTYPE}" = linux-gnu ] ; then echo 0 ; fi)
is_win=$(if [ "${OSTYPE}" = msys ] ; then echo 0 ; fi)
is_home=$(if [ "${USER}" =  oji ] || [ "${USERNAME}" = porinsan ] ; then echo 0 ; fi)
is_office=$(if [ "${USERNAME}" = admin ] ; then echo 0 ; fi)
tools_dir="${HOME}/Tools"

# History settings
HISTSIZE=5000
HISTFILESIZE=5000
HISTCONTROL=ignoredups # 重複を排除
HISTTIMEFORMAT='%FT%T ' # コマンド実行時刻を記録する

# export CHEATCOLORS=true # TODO lessとかに渡せなくなる
[ "${is_unix}" ] && export EDITOR='vimx'
[ "${is_win}" ]  && export EDITOR='vim'
export GHG_ROOT="${HOME}/.ghg"
export GHQ_ROOT="${HOME}/.ghq" # Note: ghq rootコマンドは使わない(performance) Note: vimrcからも参照するのでexport
export GOPATH=${HOME}/.go/
export LANG=en_US.UTF-8
export LESS='-R'
export SHELLCHECK_OPTS='--external-sources --exclude=SC1090,SC1091'

if [ "${is_win}" ] ; then
  export CHERE_INVOKING=1 # For mingw64. TODO: 以前はmingw64.iniで設定していれば不要だった気がするが効かなくなったので入れておく
  export GOROOT=/mingw64/lib/go # TODO: Workaround
  export NODE_PATH="/mingw64/lib/node_modules"
fi

# Export tools path # Note: Gvimから実行するものはOSの環境変数に入れる(e.g. shellcheck)
if [ "${is_win}" ] ; then
  PATH="${PATH}:${tools_dir}"
  PATH="${PATH}:${tools_dir}/ansifilter-1.15"
  PATH="${PATH}:${tools_dir}/apache-maven-3.3.9/bin"
  PATH="${PATH}:${tools_dir}/ghq" # Note: Eclipse workspaceの.metadataがあると遅くなるので注意
  PATH="${PATH}:${tools_dir}/gron"
  PATH="${PATH}:${tools_dir}/hub/bin"
  PATH="${PATH}:${tools_dir}/nkfwin/vc2005/win32(98,Me,NT,2000,XP,Vista,7)Windows-31J"
  PATH="${PATH}:${tools_dir}/seq2gif/seq2gif-0.10.3"
  PATH="${PATH}:${tools_dir}/tar-1.13-1-bin/bin"
  PATH="${PATH}:${tools_dir}/todo.txt_cli-2.10"
  PATH="${PATH}:${tools_dir}/xz-5.2.1-windows/bin_x86-64"
  PATH="${PATH}:/c/Program Files (x86)/Google/Chrome/Application"
  PATH="${PATH}:/c/Program Files (x86)/Graphviz 2.28/bin"
  PATH="${PATH}:/c/Program Files/Java/jdk1.8.0_73/bin"
  PATH="${PATH}:/c/ProgramData/chocolatey/bin"
  PATH="${PATH}:/c/Users/admin/AppData/Local/Pandoc"
  PATH="${PATH}:/usr/share/git/workdir"
fi

PATH=${PATH}:${GHG_ROOT}/bin
PATH=${PATH}:${GHQ_ROOT}/github.com/assout/scripts
PATH=${PATH}:${GHQ_ROOT}/github.com/assout/scripts/local
PATH=${PATH}:${GHQ_ROOT}/github.com/chrismdp/p
PATH=${PATH}:${GOPATH}/bin
PATH=${PATH}:${HOME}/.cabal/bin
PATH=${PATH}:/usr/local/go/bin

export PATH

# }}}1

# [Functions & Aliases] {{{1

function mybash::with_history {
  history -s "$1"; $1
}

if [ "${is_unix}" ] ; then
  selector='fzy -l 50'
  opener='gnome-open'
  vim='vimx' # aliasもしてるがfunction内で使用したいため
elif [ "${is_win}" ] ; then
  selector='fzy -l 50'
  opener='start'
  vim='vim'
fi

# TODO ctrl+c
# TODO remove eval
function mybash::select_alias { mybash::with_history "eval $(t=$(alias | sed -r "s/^alias //" | sort -f | ${selector}); echo "${t}" | cut -d'=' -f 1)"; }
alias a='mybash::select_alias'

if [ "${is_unix}" ] ; then
  function mybash::browse_by_ghq { t=$(ghq list | cut -d "/" -f 2,3 | ${selector}) && mybash::with_history "hub browse ${t}"; }
  function mybash::browse_current_project { hub browse; }
elif [ "${is_win}" ] ; then
  # Note: hub使えばできるがgitlabもあるのでこうしている
  function mybash::browse_by_ghq { t=$(ghq list | ${selector}) && (cd "${GHQ_ROOT}/${t}" && mybash::browse_current_project); }
  function mybash::browse_current_project { git remote -v | head -1 | cut -d"	" -f 2 | cut -d" " -f 1 | sed "s?\.git\$??" | sed "s?\.wiki\$?/wikis/home?" | xargs start; }
fi
alias b='mybash::browse_by_ghq'
alias B='mybash::browse_current_project'

function mybash::cd_parent {
  local to=${1:-1}
  local toStr=""
  for _ in $(seq 1 "${to}") ; do
    toStr="${toStr}"../
  done
  mybash::cdls ${toStr}
}
alias ..='mybash::cd_parent'

function mybash::cdls {
  command cd "$1"; # cdが循環しないようにcommand
  ls --color=auto --show-control-chars
}

function mybash::cd_current_dir() { local dir; dir="$(find -L -maxdepth "$1" -type d ! -path '*/.git/*' 2>/dev/null | sort | ${selector})" && mybash::with_history "cd ${dir}"; }
# shellcheck disable=SC2015
function mybash::cd_in_project { mybash::cd_git_root && mybash::cd_current_dir 10 || cd -; }
function mybash::cd_git_root { cd "$(git rev-parse --show-toplevel)"; }
function mybash::cd_recent_dir { t=$(sed -n 2,\$p ~/.cache/neomru/directory | ${selector}) && cd "${t}"; }
function mybash::cd_upper_dir { t=$(p="../../"; for d in $(pwd | tr -s "/" "\n" | tac | sed "1d") ; do echo "${p}${d}"; p=${p}../; done | fzy) && cd "${t}"; }
alias c='mybash::cd_current_dir 1'
alias C='mybash::cd_current_dir 10'
alias ci='mybash::cd_in_project'
alias cg='mybash::cd_git_root'
alias cr='mybash::cd_recent_dir'
alias c.='mybash::cd_upper_dir'

function mybash::select_cheat() {
  local tmp=${CHEATCOLORS}
  unset CHEATCOLORS
  local c
  if [ $# == 0 ] ; then
    c=$(cheat -l | cut -d' ' -f1 | ${selector})
  else
    c=$1
  fi
  tmux send-keys "$(cheat "${c}" | ${selector})"
  export CHEATCOLORS=${tmp}
}
alias ch='mybash::select_cheat'

# TODO 日本語化けてそう
[ "${is_win}" ] && function esu() { es "$1" | sed 's/\\/\\\\/g' | xargs cygpath; }
[ "${is_unix}" ] && alias eclipse='eclipse --launcher.GTK_version 2' # TODO: workaround. ref. <https://hedayatvk.wordpress.com/2015/07/16/eclipse-problems-on-fedora-22/>

function mybash::explorer() {
  if [ -n "$2" ] ; then
    mybash::with_history "${opener} $2";
  else
    local t; t="$(find -L -maxdepth "$1" -type d ! -path '*/.git/*' ! -path '*/node_modules/*' 2>/dev/null | sort | ${selector} | if [ "${is_win}" ] ; then sed -e 's?/?\\?g' ; else cat ; fi)"; [ -n "${t}" ] && mybash::with_history "${opener} ${t}"
  fi
}
function mybash::explorer_recent_dir { t=$(sed -n 2,\$p ~/.cache/neomru/directory | ${selector}) && ${opener} "${t}"; }
alias e='mybash::explorer 1'
alias E='mybash::explorer 10'
alias er='mybash::explorer_recent_dir'

function mybash::select_function { mybash::with_history "eval $(declare -F | cut -d" " -f3 | grep -v "^_" | sort -f | ${selector} | cut -d'=' -f 1)"; }
alias fun='mybash::select_function'

function mybash::file { local f; f=$(find -L -maxdepth "$1" -type 'f' ! -path '*/.git/*' ! -path '*/node_modules/*' ! -name "*jpg" ! -name "*png" 2>/dev/null | sort | ${selector}) && tmux send-keys " ${f}" C-a; }
function mybash::file_current_project { (mybash::cd_git_root; mybash::file 10); }
function mybash::file_recent { t=$(${selector} < ~/.cache/ctrlp/mru/cache.txt) && tmux send-keys " ${t}" C-a; }
function mybash::file_find { local f; f=$(find "$@" ! -path '*/.git/*' | ${selector}) && tmux send-keys " ${f}" C-a; }
alias f='mybash::file 1'
alias F='mybash::file 10'
alias fc='mybash::file_current_project'
alias fr='mybash::file_recent'
alias fin='mybash::file_find'

[ "${is_win}" ] && alias ghq='COMSPEC=${SHELL} ghq' # For msys2 <http://qiita.com/dojineko/items/3dd4090dee0a02aa1fb4>
function mybash::ghq_update { ghq list "$@" | sed -e "s?^?https://?" | xargs -n 1 -P 10 -I% sh -c "ghq get -u %"; } # 'g'hq 'u'pdate.
function mybash::ghq_status { for t in $(ghq list -p "$@") ; do (cd "${t}" && echo "${t}" && git status) done; } # 'g'hq 's'tatus.
function mybash::ghq_cd { t=$(find "${GHQ_ROOT}" -maxdepth 3 -mindepth 3 | ${selector}) && mybash::with_history "cd ${t}"; } # Note deprecate `ghq list` because slow in msys2
alias ghu='mybash::ghq_update'
alias ghs='mybash::ghq_status'
alias gh='mybash::ghq_cd'

function mybash::grep {
  t=($($1 -n "${@:2}" | ${selector} | awk -F : '{print "-c " $2 " " $1}'));
  [ "${#t[@]}" != 0 ] && ${vim} "${t[@]}";
}
alias gr='mybash::grep "grep"'
alias ggr='mybash::grep "git grep"'
alias grep='grep --color=auto --binary-files=without-match --exclude-dir=.git'

function mybash::history() {
  local HISTTIMEFORMAT_ESC="${HISTTIMEFORMAT}"
  HISTTIMEFORMAT=
  local l # Note: local宣言だけしないとshellcheckエラーになる
  l=$(history | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | ${selector})
  tmux send-keys "${l}"
  HISTTIMEFORMAT=${HISTTIMEFORMAT_ESC}
}
alias h='mybash::history'

function mybash::man_japanese {
  LANG_ESCAPE=$LANG
  LANG=ja_JP.UTF-8
  man "$*"
  LANG=$LANG_ESCAPE
}
alias jan='mybash::man_japanese'

alias jp='LANG=ja_JP.UTF8'
alias en='LANG=en_US.UTF8'

if [ "${is_win}" ] ; then
  alias l.='ls -d .* --color=auto --show-control-chars'
  alias ls='ls --color=auto --show-control-chars'
  alias ll='ls -l --color=auto --show-control-chars'
fi

log_dir="${HOME}/.tmux/log"
function mybash::log_open { t=$(find "${log_dir}"/* -type 'f' -printf "%f\n" | sort -r | ${selector}) && ${vim} "${log_dir}/${t}"; }
function mybash::log_cd_dir { cd "${log_dir}"; }
function mybash::log_grep { local a; if [ $# -eq 0 ] ; then read -p "Grep word:" a ; else a=$* ; fi; [ -z "${a}" ] && return; ${vim} -c ":LogGrep ${a}"; }
alias l='mybash::log_open'
alias lc='mybash::log_cd_dir'
alias lg='mybash::log_grep'

memo_dir="${HOME}/memo"
function mybash::memo_new { ${vim} -c ":MemoNew $*"; }
function mybash::memo_list { t=$(find "${memo_dir}"/* -type 'f' -printf "%f\n" | ${selector}) && ${vim} "${memo_dir}/${t}"; }
function mybash::memo_cd_dir { cd "${memo_dir}"; }
function mybash::memo_grep { local a; if [ $# -eq 0 ] ; then read -p "Grep word:" a ; else a=$* ; fi; [ -z "${a}" ] && return; ${vim} -c ":MemoGrep ${a}"; }
alias M='mybash::memo_new'
alias m='mybash::memo_list'
alias mc='mybash::memo_cd_dir'
alias mg='mybash::memo_grep'

note_dir="${HOME}/Documents/notes"
function mybash::note_new { ${vim} -c ":NoteNew $*"; }
function mybash::note_list { t=${note_dir}/$(find "${note_dir}"/* -type 'f' | sed -e "s?${note_dir}/??" | sort -r | ${selector}) && ${vim} "${t}"; }
function mybash::note_cd_dir { cd "${note_dir}"; }
function mybash::note_grep { local a; if [ $# -eq 0 ] ; then read -p "Grep word:" a ; else a=$* ; fi; [ -z "${a}" ] && return; ${vim} -c ":NoteGrep ${a}"; }
alias N='mybash::note_new'
alias n='mybash::note_list'
alias nc='mybash::note_cd_dir'
alias ng='mybash::note_grep'

function mybash::open() { local t; t="$(find -L -maxdepth "$1" -type 'f' ! -path '*/.git/*' ! -path '*/node_modules/*' 2>/dev/null | sort | ${selector})" && mybash::with_history "${opener} ${t}"; }
function mybash::open_recent_file { t=$(sed -n 2,\$p ~/.cache/ctrlp/mru/cache.txt | ${selector}) && ${opener} "${t}"; }
alias o='mybash::open 1'
alias O='mybash::open 10'
alias or='mybash::open_recent_file'

[ "${is_win}" ] && [ "${is_home}" ] && alias plantuml='java -jar /c/ProgramData/chocolatey/lib/plantuml/tools/plantuml.jar'

alias r='mybash::vim_recent'
alias R='mybash::vim_most_recent'

# Refs: <http://qiita.com/d6rkaiz/items/46e9c61c412c89e84c38>
# dirty..
function mybash::ssh_by_config() {
  [ ! -r "${HOME}/.ssh/config" ] && echo "Faild to read ssh conifg file." >&2 && return
  local t; t=$(awk 'tolower($1)=="host"{$1="";print}' ~/.ssh/config | sed -e "s/ \+/\n/g" | egrep -v '[*?]' | sort -u | ${selector});
  [ -z "${t}" ] && return
  local p; p=$(pcregrep -M "${t}[\s\S]*?^\r?$" ~/.ssh/config | grep Pass | sed 's/.*Pass //g');
  [ -n "${p}" ] && mybash::with_history "sshpass -p ${p} ssh ${t}" && return
  mybash::with_history "ssh ${t}"
}
function mybash::ssh_by_hosts() {
  local src=/usr/share/bash-completion/completions/ssh && [ -r ${src} ] && source ${src}
  local configfile
  type _ssh_configfile > /dev/null 2>&1 && _ssh_configfile # Note:completionのバージョンによって関数名が違うっポイ
  unset COMPREPLY
  _known_hosts_real -a -F "$configfile" ""

  local t; t=$(echo "${COMPREPLY[@]}" | tr ' ' '\n' | sort -u | ${selector}) && mybash::with_history "ssh ${t}"
}
alias s='mybash::ssh_by_config'
alias S='mybash::ssh_by_hosts'

function mybash::todo_add { todo.sh add "$*"; }
function mybash::todo_open { t=$(todo.sh -p list | sed "\$d" | sed "\$d" | ${selector} | cut -d " " -f 1); [ -n "${t}" ] && mybash::with_history "todo.sh note ${t}"; }
function mybash::todo_cd_dir { cd ~/Documents/todo/; }
function mybash::todo_do { t=$(todo.sh -p list | sed "\$d" | sed "\$d" | ${selector} | cut -d " " -f 1); [ -n "${t}" ] && mybash::with_history "todo.sh do ${t}"; }
function mybash::todo_grep { local a; if [ $# -eq 0 ] ; then read -p "Grep word:" a ; else a=$* ; fi; [ -z "${a}" ] && return; ${vim} -c ":TodoGrep ${a}"; }
alias todo='todo.sh'; complete -F _todo todo
alias T='mybash::todo_add'
alias t='mybash::todo_open'
alias tc='mybash::todo_cd_dir'
alias td='mybash::todo_do'
alias tg='mybash::todo_grep'

alias vi='vim'
[ "${is_unix}" ] && alias vim='vimx' # クリップボード共有するため

function mybash::vim() { local f; f=$(find -L -maxdepth "$1" -type 'f' ! -path '.git' ! -path 'node_modules' ! -name "*jpg" ! -name "*png" 2>/dev/null | sort | ${selector}) && mybash::with_history "${vim} ${f}"; }
function mybash::vim_current_project { (mybash::cd_git_root; mybash::vim 10); }
function mybash::vim_recent { t=$(${selector} < ~/.cache/ctrlp/mru/cache.txt) && ${vim} "${t}"; }
function mybash::vim_most_recent { ${vim} "$(head -1 ~/.cache/ctrlp/mru/cache.txt)"; }
alias v='mybash::vim 1'
alias V='mybash::vim 10'
alias vc='mybash::vim_current_project'
alias vr='mybash::vim_recent'
alias vR='mybash::vim_most_recent'

# }}}1

# [User process] {{{1

stty stop undef 2> /dev/null # Ctrl + s でコマンド実行履歴検索を有効(端末ロックを無効化)

# CreateToday backup directory
todayBackupPath=${HOME}/Backup/$(date +%Y%m%d)
if [ ! -d "${todayBackupPath}" ] && ([ "${is_home}" ] || [ "${is_office}" ]) ; then
  mkdir -p "${todayBackupPath}"
  ln -sfn "${todayBackupPath}" "${HOME}/Today"
  [ "${is_win}" ] && ln -sfn "${todayBackupPath}" "${HOME}/Desktop/Today"
fi
# }}}1

# [After] {{{1

# added by travis gem
[ -f /home/oji/.travis/travis.sh ] && source /home/oji/.travis/travis.sh

if [ "${is_unix}" ] ; then
  source /usr/share/git-core/contrib/completion/git-prompt.sh

  # Caution: 以下4つmsys2だと遅い
  export GIT_PS1_SHOWDIRTYSTATE=true # addされてない変更があるとき"*",commitされていない変更があるとき"+"を表示
  export GIT_PS1_SHOWSTASHSTATE=true # stashされているとき"$"を表示
  export GIT_PS1_SHOWUNTRACKEDFILES=true # addされてない新規ファイルがあるとき%を表示
  export GIT_PS1_SHOWUPSTREAM=auto # 現在のブランチのUPSTREAMに対する進み具合を">","<","="で表示

  # Note: デフォルトで読まれるがhubの補完有効にするために必要
  source /usr/share/bash-completion/completions/git
  source /etc/bash_completion.d/hub.bash_completion.sh
elif [ "${is_win}" ] ; then
  source /usr/share/git/completion/git-prompt.sh
  source /usr/share/git/completion/git-completion.bash

  todo_completion_path="${tools_dir}/todo.txt_cli-2.10/todo_completion"
  [ -r "${todo_completion_path}" ] && source "${todo_completion_path}"
fi

source "${GHQ_ROOT}/github.com/chrisallenlane/cheat/cheat/autocompletion/cheat.bash"

PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]$MSYSTEM\[\e[0m\] \[\e[33m\]\w"'`__git_ps1`'"\[\e[0m\]\n\$ "

# TODO gnome wanelandじゃないとログインできなくなる。いったんgnome terminalの設定でやる
# [ -z "${TMUX}" ] && ( [ "${is_home}" ] || [ "${is_office}" ] ) && exec tmux
[ -z "${TMUX}" ] && [ ! "${is_unix}" ] && exec tmux

# TODO ここに書きたくないが暫定 TODO send-keysとかでいけないか
# shellcheck disable=SC2016
tmux pipe-pane -o 'bash -c "while read -r LINE; do echo \"[\$(date +\"%%Y-%%m-%%dT%%H:%%M:%%S\")] \${LINE}\" >> \${HOME}/.tmux/log/term_\$(date +%Y%m%d_%H%M%S)_#S_#D.log; done "'

# End profile
if [ "${is_profile}" ] ; then
  set +x
  exec 2>&3 3>&-
fi
# }}}1

# vim:nofoldenable:

