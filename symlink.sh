#!/bin/bash

readonly CMD_NAME=$(basename "${0}")
readonly HERE=$(cd "$(dirname "$0")" || exit 1; pwd)

is_win=$(if [ "${OSTYPE}" = msys ] ; then echo 0 ; fi)
is_unix=$(if [ "${OSTYPE}" = linux-gnu ] ; then echo 0 ; fi)
is_home=$(if [ "${USERNAME}" = oji ] || [ "${USERNAME}" = porinsan ] ; then echo 0 ; fi)
is_office=$(if [ "${USERNAME}" = admin ] ; then echo 0 ; fi)

if [ "${is_win}" ] ; then
	# Note: Eclipse Marsは%USERPROFILE%の".vrapperrc"を見る。
	ln -sf "${HERE}/eclipse/.vrapperrc" "$(cygpath "${USERPROFILE}")/.vrapperrc"
	ln -sf "${HERE}/eclipse/.vrapperrc.win" "$(cygpath "${USERPROFILE}")/.vrapperrc.env"
	ln -sb "${HERE}/eclipse/eclipse.ini.win" ~/Tools/eclipse-java-mars-2-win32-x86_64/eclipse/eclipse.ini
	ln -sf "${HERE}/.cheatrc" "${USERPROFILE}"/
	ln -sf "${HERE}/.cheatsheets" "${USERPROFILE}"/
else
	ln -sf "${HERE}/eclipse/.vrapperrc" ~/.vrapperrc
	ln -sf "${HERE}/eclipse/.vrapperrc.linux" ~/.vrapperrc.env
	# TODO eclipse.ini.linux
	ln -sf "${HERE}/.cheatrc" ~/
	ln -sf "${HERE}/.cheatsheets" ~/
fi

ln -sf "${HERE}/lint/.mdlrc" ~/
ln -sf "${HERE}/lint/.mdlrc.style.rb" ~/
ln -sf "${HERE}/lint/.eslintrc.yml" ~/
ln -sf "${HERE}/lint/.textlintrc" ~/
ln -sf "${HERE}/lint/.textlintrc" ~/
ln -sf "${HERE}/lint/.prh.yml" ~/
# ln -sf "${HERE}/memo" ~/.config/
ln -sb "${HERE}/vim/.gvimrc" ~/
ln -sb "${HERE}/vim/.vimrc" ~/
ln -sb "${HERE}/vim/snippets" ~/.vim/
ln -sf "${HERE}/intellij/.ideavimrc" ~/
mkdir -p ~/.config
ln -sf "${HERE}/.config/git/" ~/.config/git
ln -sb "${HERE}/.bashrc" ~/
ln -sf "${HERE}/.ctags" ~/
ln -sf "${HERE}/.gitconfig" ~/
if [ "${is_home}" ] && [ "${is_unix}" ] ; then
	ln -sf "${HERE}/.gitconfig.home.linux" ~/.gitconfig.env
elif [ "${is_home}" ] && [ "${is_win}" ] ; then
	ln -sf "${HERE}/.gitconfig.home.win" ~/.gitconfig.env
elif [ "${is_office}" ] ; then
	ln -sf "${HERE}/.gitconfig.office" ~/.gitconfig.env
	ln -sf "${HERE}/.gitconfig" ${USERPROFILE} # for npm
	ln -sf "${HERE}/.gitconfig.office" ${USERPROFILE}/.gitconfig.env # for npm
fi
ln -sf "${HERE}/.gitattributes" ~/
ln -sf "${HERE}/.git_templates" ~/
ln -sf "${HERE}/.inputrc" ~/
ln -sf "${HERE}/.tmux.conf" ~/
ln -sf "${HERE}/.todo" ~/
ln -sf "${HERE}/.tern-project" ~/
ln -sf "${HERE}/.remark.css" ~/

if [ "${is_win}" ] ; then
	ln -sf "${HERE}/AutoHotKey.ahk" ~/Documents/
	ln -sf "${HERE}/.minttyrc" ~/
fi

