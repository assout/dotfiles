# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
function cdls() {
	# cdがaliasでループするので\をつける
	\cd $1;
	ls;
}
alias cd=cdls
if [ -e ~/.vimrc ] ; then
	alias v="vi"
else
	alias v="vi -S /tmp/.myvimrc"
fi

# User specific aliases and functions.
stty stop undef

if [ ${USER} = "oji" ] ; then
	todayBackupPath=~/backup/$(date +%Y%m%d)
	mkdir -p ${todayBackupPath}
	ln -sfn ${todayBackupPath} ~/today
fi

# settings for peco # FIXME 決定時に番号まで入っちゃう
if [ $(which peco) ] ; then
	# C-r,C-i
	_replace_by_history() {
		local l=$(HISTTIMEFORMAT= history | tac | sed -e 's/^\s*[0-9]*    \+\s\+//' | peco --query "$READLINE_LINE")
		READLINE_LINE="$l"
		READLINE_POINT=${#l}
	}
	alias ph=_replace_by_history

	# lscd
	function peco-lscd {
		local dir="$( find . -maxdepth 1 -type d | sed -e 's;\./;;' | peco )"
		if [ ! -z "$dir" ] ; then
			cd "$dir"
		fi
	}
	alias ld=pl
fi

# LANG=ja_JP.UTF-8
LANG=en_US.UTF-8
export LANG
