#!/bin/bash

readonly CMD_NAME=$(basename "${0}")
readonly HERE=$(cd "$(dirname "$0")" || exit 1; pwd)

is_unix=$(if [ "${OSTYPE}" = linux-gnu ] ; then echo 0 ; fi)
is_home=$(if [ "${USER}" = assout ] ; then echo 0 ; fi)
is_office=$(if [ "${USER}" = admin ] ; then echo 0 ; fi)

if [ "${is_win}" ] ; then
	ln -sf "${HERE}/.cheatrc" "${USERPROFILE}"/
	ln -sf "${HERE}/.cheatsheets" "${USERPROFILE}"/
else
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
ln -snb "${HERE}/vim/snippets" ~/.vim/
ln -sf "${HERE}/intellij/.ideavimrc" ~/
mkdir -p ~/.config
ln -snf "${HERE}/.config/git/" ~/.config/
ln -sb "${HERE}/.flake8" ~/
ln -sb "${HERE}/.bashrc.user" ~/
ln -sf "${HERE}/.ctags" ~/
ln -sf "${HERE}/.gitconfig" ~/
if [ "${is_home}" ] ; then
	ln -sf "${HERE}/.gitconfig.home" ~/.gitconfig.env
elif [ "${is_office}" ] ; then
	ln -sf "${HERE}/.gitconfig.office" ~/.gitconfig.env
	ln -sf "${HERE}/.gitconfig" ${USERPROFILE} # for npm
	ln -sf "${HERE}/.gitconfig.office" ${USERPROFILE}/.gitconfig.env # for npm
fi
ln -sf "${HERE}/.gitattributes" ~/
ln -snf "${HERE}/.git_templates" ~/
ln -sf "${HERE}/.inputrc" ~/
ln -sf "${HERE}/.tmux.conf" ~/
ln -snf "${HERE}/.todo" ~/
ln -sf "${HERE}/.tern-project" ~/
ln -sf "${HERE}/.remark.css" ~/

# ln -sf "${HERE}/wsltty/config" "${APPDATA}/wsltty/config"

if [ "${is_win}" ] ; then
	ln -sf "${HERE}/AutoHotKey.ahk" ~/Documents/
fi

