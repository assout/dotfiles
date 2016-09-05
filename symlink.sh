#!/bin/bash

readonly CMD_NAME=$(basename "${0}")
readonly HERE=$(cd "$(dirname "$0")" || exit 1; pwd)

is_win=$(if [ "${OSTYPE}" = msys ] ; then echo 0 ; fi)
is_unix=$(if [ "${OSTYPE}" = linux-gnu ] ; then echo 0 ; fi)
is_home=$(if [ "${USERNAME}" = oji ] || [ "${USERNAME}" = porinsan ] ; then echo 0 ; fi)
is_office=$(if [ "${USERNAME}" = admin ] ; then echo 0 ; fi)

if [ "${is_win}" ] ; then
  # Note: Eclipse Marsは%USERPROFILE%の".vrapperrc"を見る。
  ln -sfb "${HERE}/eclipse/.vrapperrc" "$(cygpath "${USERPROFILE}")/.vrapperrc"
  ln -sfb "${HERE}/eclipse/.vrapperrc.win" "$(cygpath "${USERPROFILE}")/.vrapperrc.env"
  ln -sfb "${HERE}/eclipse/eclipse.ini.win" ~/Tools/eclipse-java-mars-2-win32-x86_64/eclipse/eclipse.ini
else
  ln -sfb "${HERE}/eclipse/.vrapperrc" ~/.vrapperrc
  ln -sfb "${HERE}/eclipse/.vrapperrc.linux" ~/.vrapperrc.env
  # TODO eclipse.ini.linux
fi

ln -sfb "${HERE}/lint/.mdlrc" ~/
ln -sfb "${HERE}/lint/.mdlrc.style.rb" ~/
ln -sfb "${HERE}/lint/.eslintrc.yml" ~/
ln -sfb "${HERE}/lint/.textlintrc" ~/
ln -sfb "${HERE}/lint/.textlintrc" ~/
ln -sfb "${HERE}/lint/.prh.yml" ~/
ln -sfb "${HERE}/vim/.gvimrc" ~/
ln -sfb "${HERE}/vim/.vimrc" ~/
ln -sfb "${HERE}/.bashrc" ~/
ln -sfb "${HERE}/.ctags" ~/
ln -sfb "${HERE}/.gitconfig" ~/
if [ "${is_home}" ] && [ "${is_unix}" ] ; then
  ln -sfb "${HERE}/.gitconfig.home.linux" ~/.gitconfig.env
elif [ "${is_home}" ] && [ "${is_win}" ] ; then
  ln -sfb "${HERE}/.gitconfig.home.win" ~/.gitconfig.env
elif [ "${is_office}" ] ; then
  ln -sfb "${HERE}/.gitconfig.office" ~/.gitconfig.env
fi
ln -sfb "${HERE}/.gitignore" ~/
ln -sfb "${HERE}/.gitattributes" ~/
ln -sfb "${HERE}/.git_templates" ~/
ln -sfb "${HERE}/.inputrc" ~/
ln -sfb "${HERE}/.tmux.conf" ~/
ln -sfb "${HERE}/.todo" ~/
ln -sfb "${HERE}/.tern-project" ~/

if [ "${is_win}" ] ; then
  ln -sfb "${HERE}/AutoHotKey.ahk" ~/Documents/
  ln -sfb "${HERE}/.minttyrc" ~/
fi

