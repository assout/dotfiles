#!/bin/bash
# [Index] {{{1
# * Begin
# * Functions & Aliases
# * Define, Export variables
# * User process
# * After
# }}}1

# [Begin] {{{1
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
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
	if [ "${OSTYPE}" = msys -a "${USERNAME}" = admin ] ; then
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
if [ "$(which vim 2> /dev/null)" ] ; then
	alias vi='vim'
fi
here="$(command cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
if [ -e "${here}/_vimrc" ] ; then
	alias v='vi -S ${here}/_vimrc'
else
	alias v='vi'
fi

# Peco
if [ "$(which peco 2> /dev/null)" ] ; then
	# ls & cd
	function pecoLscd {
		local -r dir="$(find . -maxdepth 1 -type d | sed -e 's;\./;;' | sort | peco)"
	if [ ! -z "$dir" ] ; then
		cd "$dir"
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
alias drm='docker rm $(docker ps -a -q)'
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias dps="docker ps"
alias drun="docker run"

# Git
alias g="git"

# Other
if isOffice ; then
	alias grepsjis='/d/admin/Tools/grep-2.5.4-bin/bin/grep.exe'
	alias egrepsjis='/d/admin/Tools/grep-2.5.4-bin/bin/egrep.exe'
	alias fgrepsjis='/d/admin/Tools/grep-2.5.4-bin/bin/fgrep.exe'

	alias l.='ls -d .* --color=auto --show-control-chars'
	alias ll='ls -l --color=auto --show-control-chars'
	alias ls='ls --color=auto --show-control-chars'

	alias e='explorer'
	alias git='winpty git'
elif isHome ; then
	alias eclipse='eclipse --launcher.GTK_version 2' # TODO workaround. ref. <https://hedayatvk.wordpress.com/2015/07/16/eclipse-problems-on-fedora-22/>
fi
# }}}1

# [Define, Export variables] {{{1
HISTSIZE=5000
HISTFILESIZE=5000
HISTCONTROL=ignoredups

export GOPATH=$HOME/.go
export LANG=en_US.UTF-8

if isHome ; then
	export JAVA_HOME=/etc/alternatives/java_sdk # for RedPen
elif isOffice ; then
	export _JAVA_OPTIONS="-Dfile.encoding=UTF-8"
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
	todayBackupPath="D:\\admin\\Backup\\$(date +%Y%m%d)"
	if [ ! -d "${todayBackupPath}" ] ; then
		mkdir -p "${todayBackupPath}"

		todayBackupLinkPathDesktop="D:\\admin\\Desktop\\Today"
		todayBackupLinkPathHome="D:\\admin\\Today"
		if [ -d "${todayBackupLinkPathDesktop}" ] ; then
			rm -r "${todayBackupLinkPathDesktop}"
		fi
		if [ -d "${todayBackupLinkPathHome}" ] ; then
			rm -r "${todayBackupLinkPathHome}"
		fi
		cmd //c "mklink /D ${todayBackupLinkPathDesktop} ${todayBackupPath}"
		cmd //c "mklink /D ${todayBackupLinkPathHome} ${todayBackupPath}"
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
# }}}1

if isHome ; then
	source /usr/share/git-core/contrib/completion/git-prompt.sh
	# TODO Officeだと遅い
	export GIT_PS1_SHOWDIRTYSTATE=true # addされてない変更があるとき"*",commitされていない変更があるとき"+"を表示
	export GIT_PS1_SHOWSTASHSTATE=true # stashされているとき"$"を表示
	export GIT_PS1_SHOWUNTRACKEDFILES=true # addされてない新規ファイルがあるとき%を表示
	export GIT_PS1_SHOWUPSTREAM=auto # 現在のブランチのUPSTREAMに対する進み具合を">","<","="で表示
elif isOffice ; then
	source /usr/share/git/completion/git-prompt.sh
fi
if isHome || isOffice ; then
	PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[35m\]$MSYSTEM\[\e[0m\] \[\e[33m\]\w"'`__git_ps1`'"\[\e[0m\]\n\$ "
	PS1=$PS1'$( [ -n $TMUX ] && _=${PWD##*/} && tmux rename-window "${_:-/}")'
fi

# vim:nofoldenable:

