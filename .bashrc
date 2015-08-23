#!/bin/bash
# .bashrc
# TODO Refactor

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific process

# Ctrl + s でコマンド実行履歴検索を有効(端末ロックを無効化)
if [ "$SSH_TTY" != "" ]; then
	stty stop undef
fi

if [ "${USER}" = "oji" ] ; then
	todayBackupPath=~/Backup/$(date +%Y%m%d)
	mkdir -p "${todayBackupPath}"
	ln -sfn "${todayBackupPath}" ~/Today
fi

# LANG=ja_JP.UTF-8
LANG=en_US.UTF-8
export LANG
export GOPATH=$HOME/.go

# for msysgit
if [ "${OSTYPE}" = "msys" ] ; then
	alias l.='ls -d .* --color=auto --show-control-chars'
	alias ll='ls -l --color=auto --show-control-chars'
	alias ls='ls --color=auto --show-control-chars'

	LANG=ja_JP.UTF-8
	export LANG
fi

# User specific aliases and functions

if [ -e ~/.vimrc -o -e ~/_vimrc ] ; then
	alias v="vi"
else
	here="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
	if [ -e "${here}/_vimrc" ] ; then
		alias v='vi -S ${here}/_vimrc'
	else
		alias v="vi"
	fi
fi

function cdls {
	cd "$1";
	ls;
}
alias cd=cdls

# settings for peco
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

function man-japanese {
	LANG_ESCAPE=$LANG
	LANG=ja_JP.UTF-8
	man "$*"
	LANG=$LANG_ESCAPE
}
alias jan=man-japanese

# Docker
function drm {
	docker rm $(docker ps -a -q);
}
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias dps="docker ps"
alias drun="docker run"

export PATH="$HOME/.cabal/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/home/oji/.gvm/bin/gvm-init.sh" ]] && source "/home/oji/.gvm/bin/gvm-init.sh"

# added by travis gem
[ -f /home/oji/.travis/travis.sh ] && source /home/oji/.travis/travis.sh
