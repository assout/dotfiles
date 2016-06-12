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
  PATH="${PATH}:${TOOLS_DIR}/ansifilter-1.15"
  PATH="${PATH}:${TOOLS_DIR}/apache-maven-3.3.9/bin"
  PATH="${PATH}:${TOOLS_DIR}/ghq" # Note: Eclipse workspaceの.metadataがあると遅くなるので注意
  PATH="${PATH}:${TOOLS_DIR}/hub/bin"
  PATH="${PATH}:${TOOLS_DIR}/nkfwin/vc2005/win32(98,Me,NT,2000,XP,Vista,7)Windows-31J"
  PATH="${PATH}:${TOOLS_DIR}/seq2gif/seq2gif-0.10.3"
  PATH="${PATH}:${TOOLS_DIR}/tar-1.13-1-bin/bin"
  PATH="${PATH}:${TOOLS_DIR}/todo.txt_cli-2.10"
  PATH="${PATH}:${TOOLS_DIR}/xz-5.2.1-windows/bin_x86-64"
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

function _with_history {
  history -s "$1"; $1
}

# Vim
alias vi=vim
[ "${is_unix}" ] && alias vim='vimx' # クリップボード共有するため

alias memo='vi -c ":Unite memolist"'
alias mru='vi -c ":Unite neomru/file"' # mru(most recent use) file
alias mdl='mdl -c ~/.mdlrc' # TODO: 未指定だとデフォルト見てくれないので暫定的に。

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

  alias br='_with_history "hub browse $(ghq list | peco | cut -d "/" -f 2,3)"'

  function _peco_cd() {
    local dir; dir="$(find -L "${@:2}" -maxdepth "$1" -name '.git' -prune -o -type d | sort | peco)"; [ -d "${dir}" ] && _with_history "cd ${dir}"
  }
  alias c='_peco_cd 1'
  alias C='_peco_cd 10'

  alias fn='_with_history "eval $(declare -F | sed -r "s/declare -f.* (.*)$/\1/g" | sed -r "s/^_.*$//g" | peco)"'
  alias gh='target=$(ghq list | peco); if [ -n "${target}" ] ; then _with_history "cd "$(ghq root)/${target}"" ; fi'

  function s() {
    target=$(awk 'tolower($1)=="host"{$1="";print}' ~/.ssh/config | xargs -n1 | egrep -v '[*?]' | sort -u | peco) # Refs: <http://qiita.com/d6rkaiz/items/46e9c61c412c89e84c38>
    [ -n "${target}" ] && _with_history "ssh ${target}"
  }

  function S() {
    local src=/usr/share/bash-completion/completions/ssh && [ -r ${src} ] && source ${src}
    local configfile
    type _ssh_configfile > /dev/null 2>&1 && _ssh_configfile # Note:completionのバージョンによって関数名が違うっポイ
    unset COMPREPLY
    _known_hosts_real -a -F "$configfile" ""

    local target; target=$(echo "${COMPREPLY[@]}" | tr ' ' '\n' | sort -u | peco)
    [ -n "${target}" ] && _with_history "ssh ${target}"
  }

  alias tp='_with_history "todo.sh note $(todo.sh list | sed "\$d" | sed "\$d" | peco | cut -d " " -f 1)"'

  function _peco_vim() {
    local file; file="$(find -L "${@:2}" -maxdepth "$1" -name '.git' -prune -o -type f | sort | peco)"; [ -f "${file}" ] && _with_history "vim ${file}"
  }
  alias v='_peco_vim 1'
  alias V='_peco_vim 10'
else
  # TODO: 全角崩れる。 @msys2

  # Note: msys2でのpeco強引利用。
  function _pecowrap_exec() {
    eval "$@" > /tmp/cmd.log
    script -e -qc "winpty peco /tmp/cmd.log" /tmp/script.log
  }

  function _pecowrap_result() {
    local result; result="$(col -bx < /tmp/script.log | tr -d '\n' | sed 's/.*0m\(.*\)0K.*$/\1/g' | sed 's/0K//g')" # TODO 強引。特に"0K"が含まれると削除しちゃう
    echo "${result}"
  }

  function br() {
    _pecowrap_exec "ghq list" || return
    # Note: ローカルのディレクトリ名もとにしているため正しくないかも。(hub使えばできるがgitlabもあるのでこうしている)
    _with_history "start http://$(_pecowrap_result | sed 's?\.wiki$?/wikis/home?')" # Note: gitlabのwikiをgitとしてcloneしてる場合を考慮
  }

  function _peco_cd() {
    _pecowrap_exec "find -L $2 -maxdepth $1 -name '.git' -prune -o -type d | sort" || return
    _with_history "cd $(_pecowrap_result)"
  }
  alias c='_peco_cd 1'
  alias C='_peco_cd 10'

  function e() {
    local target="${HOME}/Documents/shortcuts/peco"
    _pecowrap_exec "find \"${target}\" -name *.lnk |  xargs -i cygpath.exe -w \"{}\"" || return
    _with_history "explorer $(_pecowrap_result)"
  }

  function fn() {
    _pecowrap_exec 'declare -F | sed -r "s/declare -f.* (.*)$/\1/g" | sed -r "s/^_.*$//g"' || return
    _with_history "eval $(_pecowrap_result)"
  }

  function gh() {
    _pecowrap_exec "ghq list -p" || return
    _with_history "cd $(_pecowrap_result)"
  }

  function s() {
    _pecowrap_exec "awk 'tolower(\$1)==\"host\"{\$1=\"\";print}' ~/.ssh/config | xargs -n1 | egrep -v '[*?]' | sort -u" || return # Refs: <http://qiita.com/d6rkaiz/items/46e9c61c412c89e84c38>
    _with_history "ssh $(_pecowrap_result)"
  }

  function S() {
    local src=/usr/share/bash-completion/completions/ssh && [ -r ${src} ] && source ${src}
    local configfile
    type _ssh_configfile > /dev/null 2>&1 && _ssh_configfile # Note:completionのバージョンによって関数名が違うっぽい
    unset COMPREPLY
    _known_hosts_real -a -F "$configfile" ""

    _pecowrap_exec "echo ${COMPREPLY[*]} | tr ' ' '\n' | sort -u" || return
    _with_history "ssh $(_pecowrap_result)"
  }

  function tp() {
    _pecowrap_exec "todo.sh -p list | sed '\$d' | sed '\$d'" || return
    _with_history "todo.sh note $(_pecowrap_result | cut -d 'G' -f 1)"
  }

  function _peco_vim() {
    _pecowrap_exec "find -L $2 -maxdepth $1 -name '.git' -prune -o -type f | sort" || return
    _with_history "vim $(_pecowrap_result)"
  }
  alias v='_peco_vim 1'
  alias V='_peco_vim 10'
fi

function jan {
  LANG_ESCAPE=$LANG
  LANG=ja_JP.UTF-8
  man "$*"
  LANG=$LANG_ESCAPE
}

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

# Others
alias en='LANG=en_US.UTF8'
alias jp='LANG=ja_JP.UTF8'
alias grep='grep --color=auto --binary-files=without-match --exclude-dir=.git'
alias groot='cd "$(git rev-parse --show-toplevel)"'
alias t=todo.sh; complete -F _todo t

if [ "${is_win}" ] ; then
  alias l.='ls -d .* --color=auto --show-control-chars'
  alias ls='ls --color=auto --show-control-chars'
  alias ll='ls -l --color=auto --show-control-chars'
  alias ghq='COMSPEC=${SHELL} ghq' # For msys2 <http://qiita.com/dojineko/items/3dd4090dee0a02aa1fb4>
  [ "${is_home}" ] && alias plantuml="java -jar /c/ProgramData/chocolatey/lib/plantuml/tools/plantuml.jar"

  function esu() {
    es "$1" | sed 's/\\/\\\\/g' | xargs cygpath
  }
elif [ "${is_unix}" ] ; then
  alias eclipse='eclipse --launcher.GTK_version 2' # TODO: workaround. ref. <https://hedayatvk.wordpress.com/2015/07/16/eclipse-problems-on-fedora-22/>
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

[ -z "${TMUX}" ] && ( [ "${is_home}" ] || [ "${is_office}" ] ) && exec tmux

# End profile
if [ "${is_profile}" ] ; then
  set +x
  exec 2>&3 3>&-
fi
# }}}1

# vim:nofoldenable:

