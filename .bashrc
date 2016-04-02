#!/bin/bash

# [Index] {{{1
# Notes:
# - 基本デフォルト厨とする(aliasとかもあんま作らない)
# - which使うと遅い
# }}}1

# [Begin] {{{1
# Start profile
is_profile=$(if [ "${1}" = "-p" ] ; then echo 0; fi)
if [ "${is_profile}" ] ; then
  PS4='+ $(date "+%S.%3N")\011 '
  exec 3>&2 2>/tmp/bashstart.$$.log
  set -x
fi

# Source global definitions
if [ -f /etc/bashrc ] ; then
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
HISTCONTROL=ignoredups # 重複を排除
HISTTIMEFORMAT='%F %T ' # コマンド実行時刻を記録する

export GOPATH=$HOME/.go
export LANG=en_US.UTF-8
export LESS='-R'
export EDITOR='vim' # For todo.txt note, less +v

if [ "${is_home}" ] ; then
  export JAVA_HOME=/etc/alternatives/java_sdk # for RedPen
fi

if [ "${is_office}" ] ; then
  export NODE_PATH="/mingw64/lib/node_modules" # TODO: npm root -gで取得
  export CHERE_INVOKING=1 # For mingw64. TODO: 以前はmingw64.iniで設定していれば不要だった気がするが効かなくなったので入れておく
else
  export NODE_PATH=$(npm root -g) # <http://qiita.com/hikaruna/items/abdadca27f12c0e4eb78>
fi

export SHELLCHECK_OPTS='--external-sources'

# Export tools path # Note: Gvimから実行するものは環境変数に入れる(e.g. shellcheck)
TOOLS_DIR="~/Tools"
if [ "${is_office}" ] ; then
  PATH="${PATH}:${TOOLS_DIR}/nkfwin/vc2005/win32(98,Me,NT,2000,XP,Vista,7)Windows-31J"
  PATH="${PATH}:${TOOLS_DIR}/hub/bin"
  PATH="${PATH}:${TOOLS_DIR}/xz-5.2.1-windows/bin_x86-64"
  PATH="${PATH}:${TOOLS_DIR}/tar-1.13-1-bin/bin"
  PATH="${PATH}:${TOOLS_DIR}/ghq"
  PATH="${PATH}:${TOOLS_DIR}/ansifilter-1.15"
  PATH="${PATH}:${TOOLS_DIR}/todo.txt_cli-2.10"
fi

if [ "${is_office}" ] ; then
  ghq_root=$(cygpath $(ghq root))
else
  ghq_root=$(ghq root)
fi
PATH=${PATH}:${ghq_root}/github.com/assout/scripts/
PATH=${PATH}:${ghq_root}/github.com/assout/scripts/local/

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
if [ "${is_home}" ] ; then
  alias vim='vimx' # クリップボード共有するため
fi

if ! [ "${is_home}" ] && ! [ "${is_office}" ] ; then
  here="$(command cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
  if [ -e "${here}/.vimrc" ] ; then
    alias vim='vim -u ${here}/.vimrc'
  fi
fi

# Peco
if [ "${is_home}" ] ; then
  function peco_select_history() { # history
    local l
    local HISTTIMEFORMAT_ESC="${HISTTIMEFORMAT}"
    HISTTIMEFORMAT=
    l=$(history | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$READLINE_LINE")
    READLINE_LINE="$l"
    READLINE_POINT=${#l}
    HISTTIMEFORMAT=${HISTTIMEFORMAT_ESC}
  }
  bind -x '"\e\C-r": peco_select_history'

  alias pcd='dir=$(find . -maxdepth 1 -type d | sed -e "s?\./??" | peco); if [ -n "${dir}" ] ; then cd "${dir}"; fi'

  alias pg='target=$(ghq list | peco); if [ -n "${target}" ] ; then cd "$(ghq root)/${target}" ; fi'
  alias pgh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
fi

function man_japanese {
  LANG_ESCAPE=$LANG
  LANG=ja_JP.UTF-8
  man "$*"
  LANG=$LANG_ESCAPE
}
alias jan='man_japanese'

function exec_explorer {
  local target="${1////\\}"
  command explorer "${target:-.}" # /を\に置換
}
alias explorer='exec_explorer'

# Docker
alias drm='docker rm $(docker ps -a -q)'
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias dpl='docker ps -lq'

# GHQ
alias ghq-update='ghq list | sed -e "s?^?https://?" | xargs -n 1 -P 10 ghq get -u'
if [ "${is_office}" ] ; then
  alias ghq='COMSPEC=${SHELL} ghq' # For msys2 <http://qiita.com/dojineko/items/3dd4090dee0a02aa1fb4>
fi

# Other
alias jp='LANG=ja_JP.UTF8'
alias en='LANG=en_US.UTF8'
alias grep='grep --color=auto --binary-files=without-match --exclude-dir=.git'
alias t=todo.sh; complete -F _todo t

if [ "${is_office}" ] ; then
  alias l.='ls -d .* --color=auto --show-control-chars'
  alias ls='ls --color=auto --show-control-chars'
  alias ll='ls -l --color=auto --show-control-chars'

  # TODO: セグる
  # alias es='cygpath -u $(command es)'
elif [ "${is_home}" ] ; then
  alias eclipse='eclipse --launcher.GTK_version 2' # TODO: workaround. ref. <https://hedayatvk.wordpress.com/2015/07/16/eclipse-problems-on-fedora-22/>
fi


# }}}1

# [User process] {{{1
stty stop undef 2> /dev/null # Ctrl + s でコマンド実行履歴検索を有効(端末ロックを無効化)

# Create Today backup directory
todayBackupPath=${HOME}/Backup/$(date +%Y%m%d)
if [ "${is_home}" ] ; then
  if [ ! -d "${todayBackupPath}" ] ; then
    mkdir -p "${todayBackupPath}"
    ln -sfn "${todayBackupPath}" "${HOME}/Today"
  fi
elif [ "${is_office}" ] ; then
  if [ ! -d "${todayBackupPath}" ] ; then
    # cmd実行時のため、Windows形式のHOMEパスで再取得。Caution: cmdは遅く必要最小限の実行とするためここで再取得している
    _home=$(cmd //c echo %HOME%)
    todayBackupPath=${_home}\\Backup\\$(date +%Y%m%d)
    mkdir -p "${todayBackupPath}"

    todayBackupLinkPathHome="${_home}\\Today"
    if [ -d "${todayBackupLinkPathHome}" ] ; then
      rm -r "${todayBackupLinkPathHome}"
    fi
    cmd //c "mklink /D ${todayBackupLinkPathHome} ${todayBackupPath}" 2>&1 | nkf32.exe -w
    todayBackupLinkPathDesktop="${_home}\\Desktop\\Today"
    cmd //c "xcopy /IB ${todayBackupLinkPathHome} ${todayBackupLinkPathDesktop}" 2>&1 | nkf32.exe -w
  fi
fi
# }}}1

# [After] {{{1
export PATH="$HOME/.cabal/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
#comment out as a workaround, slow.
# [[ -s "/home/oji/.gvm/bin/gvm-init.sh" ]] && source "/home/oji/.gvm/bin/gvm-init.sh"

# added by travis gem
[ -f /home/oji/.travis/travis.sh ] && source /home/oji/.travis/travis.sh

if [ "${is_home}" ] ; then
  source /usr/share/git-core/contrib/completion/git-prompt.sh
  # Caution: 以下4つmsys2だと遅い
  export GIT_PS1_SHOWDIRTYSTATE=true # addされてない変更があるとき"*",commitされていない変更があるとき"+"を表示
  export GIT_PS1_SHOWSTASHSTATE=true # stashされているとき"$"を表示
  export GIT_PS1_SHOWUNTRACKEDFILES=true # addされてない新規ファイルがあるとき%を表示
  export GIT_PS1_SHOWUPSTREAM=auto # 現在のブランチのUPSTREAMに対する進み具合を">","<","="で表示
elif [ "${is_office}" ] ; then
  source /usr/share/git/completion/git-prompt.sh
fi

if [ "${is_home}" ] || [ "${is_office}" ] ; then
  PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]$MSYSTEM\[\e[0m\] \[\e[33m\]\w"'`__git_ps1`'"\[\e[0m\]\n\$ "
fi

if (! [ "${TMUX}" ]) && ( [ "${is_office}" ] || [ "${is_home}" ] ); then
  exec tmux
fi

# End profile
if [ "${is_profile}" ] ; then
  set +x
  exec 2>&3 3>&-
fi
# }}}1

# vim:nofoldenable:


export NVM_DIR="/home/oji/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
