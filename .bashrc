#!/bin/bash

# [Index] {{{1
#
# - Begin
# - Functions & Aliases
# - Define, Export variables
# - User process
# - After
#
# TODOs:
#
# - Caution: which使うと遅い
# - TODO: shellcheck disable=SC1091を一括で無効にしたい
# - TODO: windows(msys2)でちょい遅い(200millisくらい)
#
# }}}1

# [Begin] {{{1

# Source global definitions
if [ -f /etc/bashrc ] ; then
  # shellcheck disable=SC1091
  source /etc/bashrc
fi

if [ -f ~/.bashrc.local ] ; then
  source ~/.bashrc.local
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# }}}1

# [Define, Export variables] {{{1

# Note: readonlyにしない(当ファイルの処理時間見るためにsoucreすることがある)
is_home=$(if [ "${USER}" =  oji ] ; then echo 0 ; fi)
is_office=$(if [ "${OSTYPE}" = msys ] && [ "${USERNAME}" = admin ] ; then echo 0 ; fi)

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

if [ "${is_home}" ] ; then
  export JAVA_HOME=/etc/alternatives/java_sdk # for RedPen
fi

if [ "${is_home}" ] || [ "${is_office}" ] ; then
  PATH="${PATH}:${HOME}/scripts"
  PATH="${PATH}:${HOME}/scripts/local/bash"
fi

if [ "${is_office}" ] ; then
  export EDITOR="vim --noplugin" # For less +v
fi

# }}}1

# [Functions & Aliases] {{{1

# General

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
  command cd "$1"; # エスケープしないと循環しちゃう
  ls --color=auto --show-control-chars;
}
alias cd='cdls'

# Vim
if [ "${is_home}" ] ; then
  # クリップボード共有するため
  alias vi='vimx --noplugin'
  alias vim='vimx'
fi

here="$(command cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
if [ -e "${here}/.vimrc" ] && ! [ "${is_home}" -o "${is_office}" ] ; then
  alias vim='vi -u ${here}/.vimrc'
  alias vimdiff='vimdiff -u ${here}/.vimrc'
fi

# Peco
if [ "${is_home}" ] ; then
  # ls & cd
  function peco_lscd {
    # TODO: Workaround
    # shellcheck disable=SC2033
    # TODO: vimでインデント崩れる(;*2がはいってるからcase文の一部扱いされてるっぽい) -> workaroundで\してみる(おかしくなるかも)
    local -r dir="$(find . -maxdepth 1 -type d | sed -e 's;\./\;\;' | sort | peco)"
    if [ ! -z "$dir" ] ; then
      cd "$dir" || exit 1
    fi
  }
  alias pcd='peco_lscd'

  # history
  function peco_hist {
    time_column="$(echo "${HISTTIMEFORMAT}" | awk '{printf("%s",NF)}')"
    column=$(( time_column + 3))
    cmd=$(history | tac | peco | sed -e 's/^ //' | sed -e 's/ +/ /g' | cut -d " " -f $column-)
    history -s "$cmd"
    eval "$cmd"
  }
  # TODO: なんかC-pとかが遅くなるので一旦無効
  # bind '"\C-p\C-r":"peco-hist\n"'
fi

# Man
function man_japanese {
  LANG_ESCAPE=$LANG
  LANG=ja_JP.UTF-8
  man "$*"
  LANG=$LANG_ESCAPE
}
alias jan='man_japanese'

# Docker
# TODO: Workaroud
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
alias grep='grep --color=auto --binary-files=without-match --exclude-dir=.git'

if [ "${is_office}" ] ; then
  alias l.='ls -d .* --color=auto --show-control-chars'
  alias ls='ls --color=auto --show-control-chars'
  alias ll='ls -l --color=auto --show-control-chars'
  alias e='explorer' # TODO: windowsでパス区切り文字が/だと開けない？(/,\のどちらでもいけるはずでは？)
elif [ "${is_home}" ] ; then
  alias eclipse='eclipse --launcher.GTK_version 2' # TODO: workaround. ref. <https://hedayatvk.wordpress.com/2015/07/16/eclipse-problems-on-fedora-22/>
fi

# }}}1

# [User process] {{{1

# Ctrl + s でコマンド実行履歴検索を有効(端末ロックを無効化)
stty stop undef 2> /dev/null

# Create Today backup directory. TODO: dirty
if [ "${is_home}" ] ; then
  todayBackupPath=${HOME}/Backup/$(date +%Y%m%d)
  if [ ! -d "${todayBackupPath}" ] ; then
    mkdir -p "${todayBackupPath}"
    ln -sfn "${todayBackupPath}" "${HOME}/Today"
  fi
elif [ "${is_office}" ] ; then
  todayBackupPath=${HOME}/Backup/$(date +%Y%m%d)
  if [ ! -d "${todayBackupPath}" ] ; then
    # cmd実行時のため、Windows形式のHOMEパスで再取得。Caution: cmdは遅いためここで再取得している
    _home=$(cmd //c echo %HOME%)
    todayBackupPath=${_home}\\Backup\\$(date +%Y%m%d)
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

if [ "${is_home}" ] ; then
  # shellcheck disable=SC1091
  source /usr/share/git-core/contrib/completion/git-prompt.sh
  # TODO: Officeだと遅い
  export GIT_PS1_SHOWDIRTYSTATE=true # addされてない変更があるとき"*",commitされていない変更があるとき"+"を表示
  export GIT_PS1_SHOWSTASHSTATE=true # stashされているとき"$"を表示
  export GIT_PS1_SHOWUNTRACKEDFILES=true # addされてない新規ファイルがあるとき%を表示
  export GIT_PS1_SHOWUPSTREAM=auto # 現在のブランチのUPSTREAMに対する進み具合を">","<","="で表示
elif [ "${is_office}" ] ; then
  # shellcheck disable=SC1091
  source /usr/share/git/completion/git-prompt.sh
fi

if [ "${is_home}" ] ; then # Caution: sourceしなくても補完効くが"g" aliasでも効かしたいため
  source /usr/share/doc/git-core-doc/contrib/completion/git-completion.bash
  __git_complete g __git_main
elif [ "${is_office}" ] ; then
  source /usr/share/git/completion/git-completion.bash
  __git_complete g __git_main
fi

if [ "${is_home}" ] || [ "${is_office}" ] ; then
  PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]$MSYSTEM\[\e[0m\] \[\e[33m\]\w"'`__git_ps1`'"\[\e[0m\]\n\$ "
  [ -n "$TMUX" ] && PS1=$PS1'$( [ ${PWD} = "/" ] && tmux rename-window "/" || tmux rename-window "${PWD##*/}")'
fi

# }}}1

# vim:nofoldenable:

