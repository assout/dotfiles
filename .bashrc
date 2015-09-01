#!/bin/bash

# [Index] {{{1
# * Begin
# * Export variables
# * User process
# * Functions & Aliases
# * Environment settings
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

# [Export variables] {{{1
# LANG=ja_JP.UTF-8
LANG=en_US.UTF-8
export LANG
export GOPATH=$HOME/.go
# }}}1

# [User process] {{{1
# Ctrl + s でコマンド実行履歴検索を有効(端末ロックを無効化)
if [ "$(which stty 2> /dev/null)" ] ; then
	stty stop undef
fi

# Create Today backup directory
if [ "${USER}" = "oji" ] ; then
	todayBackupPath=~/Backup/$(date +%Y%m%d)
	mkdir -p "${todayBackupPath}"
	ln -sfn "${todayBackupPath}" ~/Today
fi
# }}}1

# [Functions & Aliases] {{{1
# Vim
if [ "$(which vim 2> /dev/null)" ] ; then
	alias vi='vim'
fi
here="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
if [ -e "${here}/_vimrc" ] ; then
	alias v='vi -S ${here}/_vimrc'
else
	alias v="vi"
fi

# Cdls
function cdls {
	cd "$1";
	ls --color=auto --show-control-chars;
}
alias cd=cdls

# Peco
if [ "$(which peco 2> /dev/null)" ] ; then
	# ls & cd
	function peco-lscd {
		local -r dir="$(find . -maxdepth 1 -type d | sed -e 's;\./;;' | sort | peco)"
		if [ ! -z "$dir" ] ; then
			cd "$dir"
		fi
	}
	alias pcd=peco-lscd

	# history
	function peco-hist {
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
function man-japanese {
	LANG_ESCAPE=$LANG
	LANG=ja_JP.UTF-8
	man "$*"
	LANG=$LANG_ESCAPE
}
alias jan=man-japanese

# Docker
alias drm='docker rm $(docker ps -a -q)'
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias dps="docker ps"
alias drun="docker run"
# }}}1

# [Environment settings] {{{1
# msysgit
if [ "${OSTYPE}" = "msys" ] ; then
	alias l.='ls -d .* --color=auto --show-control-chars'
	alias ll='ls -l --color=auto --show-control-chars'
	alias ls='ls --color=auto --show-control-chars'

	LANG=ja_JP.UTF-8
	export LANG
fi
# }}}1

# [After] {{{1
export PATH="$HOME/.cabal/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
#comment out as a workaround, slow.
# [[ -s "/home/oji/.gvm/bin/gvm-init.sh" ]] && source "/home/oji/.gvm/bin/gvm-init.sh"

# added by travis gem
[ -f /home/oji/.travis/travis.sh ] && source /home/oji/.travis/travis.sh

[[ $TERM != "screen-256color" ]] && [[ "$(which tmux 2> /dev/null)" ]] && tmux
# }}}1

# vim:nofoldenable:
