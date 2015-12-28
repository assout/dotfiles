#!/bin/bash

# [Index] {{{1
#
# * Begin
# * Functions & Aliases
# * Define, Export variables
# * User process
# * After
#
# TODOs
# * TODO shellcheck disable=SC1091を一括で無効にしたい
# * TODO Performance test on travisCI
#
# }}}1

# [Begin] {{{1

# Source global definitions
if [ -f /etc/bashrc ] ; then
  # shellcheck disable=SC1091
  . /etc/bashrc
fi

if [ -f ~/.bashrc.local ] ; then
  . ~/.bashrc.local
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# }}}1

# [Functions & Aliases] {{{1

# General
function isHome {
  if [ "${USER}" = oji ] ; then
    return 0
  else
    return 1
  fi
}

function isOffice {
  if [ "${OSTYPE}" = msys ] && [ "${USERNAME}" = admin ] ; then
    return 0
  else
    return 1
  fi
}

function cdParent {
  local to=${1:-1}
  local toStr="";
  for _ in $(seq 1 "${to}") ; do
    toStr="${toStr}"../
  done
  cdls ${toStr}
}
alias ..='cdParent'

function cdls {
  command cd "$1"; # エスケープしないと循環しちゃう
  ls --color=auto --show-control-chars;
}
alias cd='cdls'

# Vim
if [ "$(which vimx 2> /dev/null)" ] ; then
  alias vi='vimx --noplugin'
  alias vim='vimx'
fi

if [ "$(which vim 2> /dev/null)" ] ; then
  alias vi='vim --noplugin'
fi
if ! isHome && ! isOffice && [ -e "${here}/.vimrc" ] ; then
  here="$(command cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
  alias vi='vi -s ${here}/.vimrc'
fi

# Peco
if [ "$(which peco 2> /dev/null)" ] ; then
  # ls & cd
  function pecoLscd {
    # TODO Workaround
    # shellcheck disable=SC2033
    local -r dir="$(find . -maxdepth 1 -type d | sed -e 's;\./;;' | sort | peco)"
  if [ ! -z "$dir" ] ; then
    cd "$dir" || exit 1
  fi
}
alias pcd='pecoLscd'

# history
function pecoHist {
  time_column="$(echo "${HISTTIMEFORMAT}" | awk '{printf("%s",NF)}')"
  column=$(( time_column + 3))
  cmd=$(history | tac | peco | sed -e 's/^ //' | sed -e 's/ +/ /g' | cut -d " " -f $column-)
  history -s "$cmd"
  eval "$cmd"
}
# TODO なんかC-pとかが遅くなるので一旦無効
# bind '"\C-p\C-r":"peco-hist\n"'
fi

# Man
function manJapanese {
  LANG_ESCAPE=$LANG
  LANG=ja_JP.UTF-8
  man "$*"
  LANG=$LANG_ESCAPE
}
alias jan='manJapanese'

# Docker
# TODO Workaroud
# shellcheck disable=SC2032
alias d='docker'
alias drm='docker rm $(docker ps -a -q)'
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias dpl='docker ps -lq'
alias dc='docker-compose'

# Other
alias g="git"
alias jp='LANG=ja_JP.UTF8'
alias en='LANG=en_US.UTF8'
alias grep='grep --color=auto --binary-files=without-match'

if isOffice ; then
  alias l.='ls -d .* --color=auto --show-control-chars'
  alias ls='ls --color=auto --show-control-chars'
  alias ll='ls -l --color=auto --show-control-chars'
  alias e='explorer'
  alias git='winpty git'
elif isHome ; then
  alias eclipse='eclipse --launcher.GTK_version 2' # TODO workaround. ref. <https://hedayatvk.wordpress.com/2015/07/16/eclipse-problems-on-fedora-22/>
fi

# }}}1

# [Define, Export variables] {{{1

# History settings
HISTSIZE=5000
HISTFILESIZE=5000
# 重複を排除
HISTCONTROL=ignoredups
# コマンド実行時刻を記録する
HISTTIMEFORMAT='%F %T '

export GOPATH=$HOME/.go
export LANG=en_US.UTF-8
export LESS='-R'

if isHome ; then
  export JAVA_HOME=/etc/alternatives/java_sdk # for RedPen
fi

if isHome || isOffice ; then
  # TODO スマートに
  PATH="${PATH}:${HOME}/Development/scripts"
  PATH="${PATH}:${HOME}/Development/scripts/local/bash"
fi

if isOffice ; then
  export EDITOR="vim --noplugin" # For less +v
fi

# }}}1

# [User process] {{{1

# Ctrl + s でコマンド実行履歴検索を有効(端末ロックを無効化)
if [ "$(which stty 2> /dev/null)" ] ; then
  stty stop undef
fi

# Create Today backup directory. TODO dirty
if isHome ; then
  todayBackupPath=${HOME}/Backup/$(date +%Y%m%d)
  if [ ! -d "${todayBackupPath}" ] ; then
    mkdir -p "${todayBackupPath}"
    ln -sfn "${todayBackupPath}" "${HOME}/Today"
  fi
elif isOffice ; then
  # cmd実行時のため、Windows形式のHOMEパス取得
  _home=$(cmd //c echo %HOME%)
  todayBackupPath=${_home}\\Backup\\$(date +%Y%m%d)
  if [ ! -d "${todayBackupPath}" ] ; then
    mkdir -p "${todayBackupPath}"

    todayBackupLinkPathDesktop="${_home}\\Desktop\\Today"
    if [ -d "${todayBackupLinkPathDesktop}" ] ; then
      rm -r "${todayBackupLinkPathDesktop}"
    fi
    todayBackupLinkPathHome="${_home}\\Today"
    if [ -d "${todayBackupLinkPathHome}" ] ; then
      rm -r "${todayBackupLinkPathHome}"
    fi
    cmd //c "mklink /D ${todayBackupLinkPathDesktop} ${todayBackupPath}" 2>&1 | nkf32.exe -w
    cmd //c "mklink /D ${todayBackupLinkPathHome} ${todayBackupPath}" 2>&1 | nkf32.exe -w
  fi
fi

# }}}1

# [After] {{{1

export PATH="$HOME/.cabal/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
#comment out as a workaround, slow.
# [[ -s "/home/oji/.gvm/bin/gvm-init.sh" ]] && source "/home/oji/.gvm/bin/gvm-init.sh"

# added by travis gem
# shellcheck disable=SC1091
[ -f /home/oji/.travis/travis.sh ] && source /home/oji/.travis/travis.sh

if isHome ; then
  # shellcheck disable=SC1091
  source /usr/share/git-core/contrib/completion/git-prompt.sh
  # TODO Officeだと遅い
  export GIT_PS1_SHOWDIRTYSTATE=true # addされてない変更があるとき"*",commitされていない変更があるとき"+"を表示
  export GIT_PS1_SHOWSTASHSTATE=true # stashされているとき"$"を表示
  export GIT_PS1_SHOWUNTRACKEDFILES=true # addされてない新規ファイルがあるとき%を表示
  export GIT_PS1_SHOWUPSTREAM=auto # 現在のブランチのUPSTREAMに対する進み具合を">","<","="で表示
elif isOffice ; then
  # shellcheck disable=SC1091
  source /usr/share/git/completion/git-prompt.sh
fi

if isHome ; then # Caution: sourceしなくても補完効くが"g" aliasでも効かしたいため
  source /usr/share/doc/git-core-doc/contrib/completion/git-completion.bash
  __git_complete g __git_main
elif isOffice ; then
  source /usr/share/git/completion/git-completion.bash
  __git_complete g __git_main
fi

if isHome || isOffice ; then
  PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]$MSYSTEM\[\e[0m\] \[\e[33m\]\w"'`__git_ps1`'"\[\e[0m\]\n\$ "
  [ -n "$TMUX" ] && PS1=$PS1'$( [ ${PWD} = "/" ] && tmux rename-window "/" || tmux rename-window "${PWD##*/}")'
fi

# }}}1

# vim:nofoldenable:

