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
HISTTIMEFORMAT='%F %T ' # コマンド実行時刻を記録する

export EDITOR='vim' # For todo.txt note, less +v
export GHG_ROOT="${HOME}/.ghg" # Note: ghq rootコマンドは使わない(performance) Note: vimrcからも参照するのでexport
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

export PATH

# }}}1

# [Functions & Aliases] {{{1

function _with_history {
  history -s "$1"; $1
}

if [ "${is_unix}" ] ; then
  selector='fzy -l 50'
  opener='gnome-open'
elif [ "${is_win}" ] ; then
  selector='fzy -l 50'
  opener='start'
fi

alias a='_with_history "eval $(t=$({ alias | sed -r "s/^alias //"; declare -F | cut -d" " -f3; } | ${selector}); echo ${t} | cut -d'=' -f 1)"'

if [ "${is_unix}" ] ; then
  alias b='t=$(ghq list | cut -d "/" -f 2,3 | ${selector}); [ -n "${t}" ] && _with_history "hub browse ${t}"'
  alias B='hub browse'
elif [ "${is_win}" ] ; then
  # Note: hub使えばできるがgitlabもあるのでこうしている
  alias b='t=$(ghq list | ${selector}); [ -n "${t}" ] && (cd ${GHQ_ROOT}/${t} && B)'
  alias B='git remote -v | head -1 | cut -d"	" -f 2 | cut -d" " -f 1 | sed "s?\.git\$??" | sed "s?\.wiki\$?/wikis/home?" | xargs start'
fi

function cd_parent {
  local to=${1:-1}
  local toStr=""
  for _ in $(seq 1 "${to}") ; do
    toStr="${toStr}"../
  done
  cdls ${toStr}
}
alias ..='cd_parent'

function cdls {
  command cd "$1"; # cdが循環しないようにcommand
  ls --color=auto --show-control-chars
}

# Note: `_cd`だと通常のcd後の補完が壊れる
function __cd() { local dir; dir="$(find -L -maxdepth "$1" -name '.git' -prune -o -type d 2>/dev/null | sort | ${selector})"; [ -d "${dir}" ] && _with_history "cd ${dir}"; }
alias c='__cd 1'
alias C='__cd 10'
alias cc='cg; C || cd -' # 'c'd to in 'c'urrent project.
alias cg='cd "$(git rev-parse --show-toplevel)"' # 'c'd 'g'it root directory
alias cr='t=$(sed -n 2,\$p ~/.cache/neomru/directory | ${selector}) && cd ${t}' #  'c'd to 'r'ecent directory

alias di='docker inspect --format "{{ .NetworkSettings.IPAddress }}"'
alias dp='docker ps -lq'
alias dr='docker rm $(docker ps -a -q)'
alias drf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias drm='docker rmi $(docker images -q)'

# TODO 日本語化けてそう
[ "${is_win}" ] && function esu() { es "$1" | sed 's/\\/\\\\/g' | xargs cygpath; }
[ "${is_unix}" ] && alias eclipse='eclipse --launcher.GTK_version 2' # TODO: workaround. ref. <https://hedayatvk.wordpress.com/2015/07/16/eclipse-problems-on-fedora-22/>

function _explorer() {
  if [ -n "$2" ] ; then
    _with_history "${opener} $2";
  else
    local t; t="$(find -L -maxdepth "$1" -name '.git' -prune -o -name 'node_modules' -prune -o -type d 2>/dev/null | sort | ${selector} | if [ "${is_win}" ] ; then sed -e 's?/?\\?g' ; else cat ; fi)"; [ -n "${t}" ] && _with_history "${opener} ${t}"
  fi
}
alias e='_explorer 1'
alias E='_explorer 10'
alias er='t=$(sed -n 2,\$p ~/.cache/neomru/directory | ${selector}) && e ${t}'

function _file_with_vim() { local f; f=""$(find -L -maxdepth "$1" -name '.git' -prune -o -name 'node_modules' -prune -o -type 'f' ! -name "*jpg" ! -name "*png" 2>/dev/null | sort | ${selector})''; [ -f "${f}" ] && _with_history "vim ${f}"; }
alias f='_file_with_vim 1' # 'f'ile open with vim
alias F='_file_with_vim 10'
alias fc='(cg; F)' # open 'f'ile in 'c'urrent git project.
alias fr='t=$(cat ~/.cache/ctrlp/mru/cache.txt | ${selector}) && vi ${t}' # open 'r'ecent file with vim

[ "${is_win}" ] && alias ghq='COMSPEC=${SHELL} ghq' # For msys2 <http://qiita.com/dojineko/items/3dd4090dee0a02aa1fb4>
function gu { ghq list "$@" | sed -e "s?^?https://?" | xargs -n 1 -P 10 -I% sh -c "ghq get -u %"; } # 'g'hq 'u'pdate.
function gs { for t in $(ghq list -p "$@") ; do (cd "${t}" && echo "${t}" && git status) done; } # 'g'hq 's'tatus.
# TODO `ghq list` slow in msys2
# alias gh='t=$(ghq list | ${selector}); if [ -n "${t}" ] ; then _with_history "cd "${GHQ_ROOT}/${t}"" ; fi'
alias gh='t=$(find ${GHQ_ROOT} -maxdepth 3 -mindepth 3 | ${selector}); if [ -n "${t}" ] ; then _with_history "cd "${t}"" ; fi'

alias grep='grep --color=auto --binary-files=without-match --exclude-dir=.git'

function _history() {
  local HISTTIMEFORMAT_ESC="${HISTTIMEFORMAT}"
  HISTTIMEFORMAT=
  local l # Note: local宣言だけしないとshellcheckエラーになる
  l=$(history | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | ${selector})
  _with_history "${l}"
  HISTTIMEFORMAT=${HISTTIMEFORMAT_ESC}
}
alias h=_history

function jan {
  LANG_ESCAPE=$LANG
  LANG=ja_JP.UTF-8
  man "$*"
  LANG=$LANG_ESCAPE
}

alias jp='LANG=ja_JP.UTF8'
alias en='LANG=en_US.UTF8'

if [ "${is_win}" ] ; then
  alias l.='ls -d .* --color=auto --show-control-chars'
  alias ls='ls --color=auto --show-control-chars'
  alias ll='ls -l --color=auto --show-control-chars'
fi

alias m='t=~/memolist.wiki/$(find ~/memolist.wiki/* -type f | sed -e "s?^.*memolist.wiki/??" | ${selector}) && vi ${t}'

function _open() { local t; t="$(find -L -maxdepth "$1" -name '.git' -prune -o -name 'node_modules' -prune -o -type 'f' 2>/dev/null | sort | ${selector})"; [ -n "${t}" ] && _with_history "${opener} ${t}"; }
alias o='_open 1'
alias O='_open 10'
alias or='t=$(sed -n 2,\$p ~/.cache/ctrlp/mru/cache.txt | ${selector}) && ${opener} ${t}' # 'o'pen 'r'ecent file

[ "${is_win}" ] && [ "${is_home}" ] && alias plantuml='java -jar /c/ProgramData/chocolatey/lib/plantuml/tools/plantuml.jar'

alias r='fr'
alias R='vi $(head -1 ~/.cache/ctrlp/mru/cache.txt)'

# Refs: <http://qiita.com/d6rkaiz/items/46e9c61c412c89e84c38>
# Note msys2でxargs -n1が遅いためsed
# ~/.ssh/pass -> pass host1 host2...
function s() {
  local t; t=$(awk 'tolower($1)=="host"{$1="";print}' ~/.ssh/config | sed -e "s/ \+/\n/g" | egrep -v '[*?]' | sort -u | ${selector});
  [ -z "${t}" ] && return
  if [ -f "${HOME}/.ssh/pass" ] ; then
    local p=$(grep "${t}" ~/.ssh/pass | cut -d' ' -f1)
    if [ -n "${p}" ] ; then
      _with_history "sshpass -p ${p} ssh ${t}"; return
    fi
  fi
  _with_history "ssh ${t}"
}

function S() {
  local src=/usr/share/bash-completion/completions/ssh && [ -r ${src} ] && source ${src}
  local configfile
  type _ssh_configfile > /dev/null 2>&1 && _ssh_configfile # Note:completionのバージョンによって関数名が違うっポイ
  unset COMPREPLY
  _known_hosts_real -a -F "$configfile" ""

  local t; t=$(echo "${COMPREPLY[@]}" | tr ' ' '\n' | sort -u | ${selector}); [ -n "${t}" ] && _with_history "ssh ${t}"
}

alias t='todo.sh'; complete -F _todo t
alias td='t=$(todo.sh -p list | sed "\$d" | sed "\$d" | ${selector} | cut -d " " -f 1); [ -n "${t}" ] && _with_history "todo.sh do ${t}"'
alias tn='t=$(todo.sh -p list | sed "\$d" | sed "\$d" | ${selector} | cut -d " " -f 1); [ -n "${t}" ] && _with_history "todo.sh note ${t}"'

alias vi='vim'
[ "${is_unix}" ] && alias vim='vimx' # クリップボード共有するため

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

PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]$MSYSTEM\[\e[0m\] \[\e[33m\]\w"'`__git_ps1`'"\[\e[0m\]\n\$ "

# TODO gnome wanelandじゃないとログインできなくなる。いったんgnome terminalの設定でやる
# [ -z "${TMUX}" ] && ( [ "${is_home}" ] || [ "${is_office}" ] ) && exec tmux
[ -z "${TMUX}" ] && [ ! "${is_unix}" ] && exec tmux

# End profile
if [ "${is_profile}" ] ; then
  set +x
  exec 2>&3 3>&-
fi
# }}}1

# vim:nofoldenable:

