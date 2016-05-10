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

# History settings
HISTSIZE=5000
HISTFILESIZE=5000
HISTCONTROL=ignoredups # 重複を排除
HISTTIMEFORMAT='%F %T ' # コマンド実行時刻を記録する

export GOPATH=${HOME}/Development/
export LANG=en_US.UTF-8
export LESS='-R'
export EDITOR='vim' # For todo.txt note, less +v

if [ "${is_win}" ] ; then
  export GOROOT=/mingw64/lib/go # TODO: Workaround
  export NODE_PATH="/mingw64/lib/node_modules"
  export CHERE_INVOKING=1 # For mingw64. TODO: 以前はmingw64.iniで設定していれば不要だった気がするが効かなくなったので入れておく
fi

export SHELLCHECK_OPTS='--external-sources --exclude=SC1090,SC1091'

# Export tools path # Note: Gvimから実行するものはOSの環境変数に入れる(e.g. shellcheck)
if [ "${is_win}" ] ; then
  TOOLS_DIR="${HOME}/Tools"
  PATH="${PATH}:${TOOLS_DIR}"
  PATH="${PATH}:${TOOLS_DIR}/nkfwin/vc2005/win32(98,Me,NT,2000,XP,Vista,7)Windows-31J"
  PATH="${PATH}:${TOOLS_DIR}/hub/bin"
  PATH="${PATH}:${TOOLS_DIR}/xz-5.2.1-windows/bin_x86-64"
  PATH="${PATH}:${TOOLS_DIR}/tar-1.13-1-bin/bin"
  PATH="${PATH}:${TOOLS_DIR}/ghq"
  PATH="${PATH}:${TOOLS_DIR}/ansifilter-1.15"
  PATH="${PATH}:${TOOLS_DIR}/todo.txt_cli-2.10"
  PATH="${PATH}:${TOOLS_DIR}/apache-maven-3.3.9/bin"
  PATH="${PATH}:/c/Program Files (x86)/Google/Chrome/Application"
  PATH="${PATH}:/c/ProgramData/chocolatey/bin"
  PATH="${PATH}:/c/Users/admin/AppData/Local/Pandoc"

  todo_completion_path="${TOOLS_DIR}/todo.txt_cli-2.10/todo_completion"
  [ -r "${todo_completion_path}" ] && source "${todo_completion_path}"
fi

ghq_root="${HOME}/Development/src" # Note: ghq rootコマンドは使わない(performance)
PATH=${PATH}:${ghq_root}/github.com/assout/scripts
PATH=${PATH}:${ghq_root}/github.com/assout/scripts/local
PATH=${PATH}:${ghq_root}/github.com/chrismdp/p
PATH=${PATH}:${HOME}/.cabal/bin
PATH=${PATH}:${GOPATH}/bin

export PATH

# }}}1

# [Functions & Aliases] {{{1
function cd_parent {
  local to=${1:-1}
  local toStr="";
  for _ in $(seq 1 "${to}") ; do
    toStr="${toStr}"../
  done
  cdls ${toStr}
}
alias ..='cd_parent'

function cdls {
  command cd "$1"; # cdが循環しないようにcommand
  ls --color=auto --show-control-chars;
}

# Vim
alias vi=vim
[ "${is_unix}" ] && alias vim='vimx' # クリップボード共有するため

alias memo='vi -c ":Unite memolist"'
alias mru='vi -c ":Unite neomru/file"' # mru(most recent use) file

# Peco
if [ "${is_unix}" ] ; then
  function peco_select_history() { # history
    local l
    local HISTTIMEFORMAT_ESC="${HISTTIMEFORMAT}"
    HISTTIMEFORMAT=
    l=$(history | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$READLINE_LINE")
    READLINE_LINE="$l"
    READLINE_POINT=${#l}
    HISTTIMEFORMAT=${HISTTIMEFORMAT_ESC}
  }
  bind -x '"\e\C-r": peco_select_history' # Ctrl+Alt+r

  # TODO 引数で開始ディレクトリ受ける
  alias c='dir=$(find . -maxdepth 1 -type d | sed -e "s?\./??" | sort | peco); if [ -n "${dir}" ] ; then cd "${dir}"; fi'
  alias fn='eval $(declare -F | sed -r "s/declare -f.* (.*)$/\1/g" | sed -r "s/^_.*$//g" | peco)'

  alias gh='target=$(ghq list | peco); if [ -n "${target}" ] ; then cd "$(ghq root)/${target}" ; fi'
  alias hu='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

  # TODO 崩れる？
  alias tp='todo.sh note $(todo.sh list | sed "$d" | sed "$d" | peco | cut -d " " -f 1)'
else
  # TODO msys2でのpeco強引利用。2functionがめんどくさい。
  function pecowrap_exec() {
    eval $1 > /tmp/cmd.log
    script -qc "winpty peco /tmp/cmd.log" /tmp/script.log
  }

  function pecowrap_result() {
    local result="$(col -bx < /tmp/script.log | tail -2 | head -1 | sed s/0K.*$// | sed s/^0m// )" # TODO 強引。特に"0K"が含まれると削除しちゃう
    echo "${result}"
  }

  # TODO 引数で開始ディレクトリ受ける
  function c() {
    pecowrap_exec 'find . -maxdepth 1 -type d | sed -e "s?\./??" | sort'
    target=$(pecowrap_result)
    [ -d "${target}" ] && cd "${target}"
  }

  function fn() {
    pecowrap_exec 'declare -F | sed -r "s/declare -f.* (.*)$/\1/g" | sed -r "s/^_.*$//g"'
    target=$(pecowrap_result)
    eval "${target}"
  }

  function gh() {
    pecowrap_exec "ghq list -p"
    target=$(pecowrap_result)
    [ -d "${target}" ] && cd "${target}"
  }

  # TODO 崩れる。全角があるとだめかも。 @office
  function tp() {
    pecowrap_exec "todo.sh -p list | sed '\$d' | sed '\$d'"
    local target="$(pecowrap_result | cut -d 'G' -f 1)"
    expr "${target}" + 1 > /dev/null 2>&1
    [ $? -lt 2 ] && todo.sh note "${target}"
  }
fi

function man_japanese {
  LANG_ESCAPE=$LANG
  LANG=ja_JP.UTF-8
  man "$*"
  LANG=$LANG_ESCAPE
}
alias jan='man_japanese'

function exec_explorer {
  local target="${1////\\}" # /を\に置換
  command explorer "${target:-.}"
}
alias explorer='exec_explorer'

# Docker
alias drm='docker rm $(docker ps -a -q)'
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias dpl='docker ps -lq'

# GHQ
function ghq_update {
  ghq list "$@" | sed -e "s?^?https://?" | xargs -n 1 -P 10 -I%  sh -c "ghq get -u %"
}

function ghq_status {
  for t in $(ghq list -p "$@") ; do
    (cd "${t}" && echo "${t}" && git status)
  done
}

[ "${is_win}" ] && alias ghq='COMSPEC=${SHELL} ghq' # For msys2 <http://qiita.com/dojineko/items/3dd4090dee0a02aa1fb4>

# Other
alias jp='LANG=ja_JP.UTF8'
alias en='LANG=en_US.UTF8'
alias grep='grep --color=auto --binary-files=without-match --exclude-dir=.git'
alias t=todo.sh; complete -F _todo t
alias groot='cd "$(git rev-parse --show-toplevel)"'

if [ "${is_win}" ] ; then
  alias l.='ls -d .* --color=auto --show-control-chars'
  alias ls='ls --color=auto --show-control-chars'
  alias ll='ls -l --color=auto --show-control-chars'

  # TODO: セグる
  # alias es='cygpath -u $(command es)'
elif [ "${is_unix}" ] ; then
  alias eclipse='eclipse --launcher.GTK_version 2' # TODO: workaround. ref. <https://hedayatvk.wordpress.com/2015/07/16/eclipse-problems-on-fedora-22/>
fi

if [ "${is_win}" ] && [ "${is_home}" ]; then
  alias plantuml="java -jar /c/ProgramData/chocolatey/lib/plantuml/tools/plantuml.jar" # TODO
fi

# }}}1

# [User process] {{{1
stty stop undef 2> /dev/null # Ctrl + s でコマンド実行履歴検索を有効(端末ロックを無効化)

# Create Today backup directory
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
fi

PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]$MSYSTEM\[\e[0m\] \[\e[33m\]\w"'`__git_ps1`'"\[\e[0m\]\n\$ "

! [ "${TMUX}" ] && ( [ "${is_home}" ] || [ "${is_office}" ] ) && exec tmux

# End profile
if [ "${is_profile}" ] ; then
  set +x
  exec 2>&3 3>&-
fi
# }}}1

# vim:nofoldenable:


