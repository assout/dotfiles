#!/bin/bash

readonly CMD_NAME=$(basename "${0}")
readonly HERE=$(cd "$(dirname "$0")" || exit 1; pwd)

if [ "${OSTYPE}" = msys ] ; then
  # Note: Eclipse Marsは%USERPROFILE%の".vrapperrc"を見る。
  ln -sf "${HERE}/eclipse/.vrapperrc" "$(cygpath "${USERPROFILE}")/.vrapperrc"
  ln -sf "${HERE}/eclipse/.vrapperrc.win" "$(cygpath "${USERPROFILE}")/.vrapperrc.environment"
else
  ln -sf "${HERE}/eclipse/.vrapperrc" ~/.vrapperrc
  ln -sf "${HERE}/eclipse/.vrapperrc.linux" ~/.vrapperrc.environment
fi

ln -sf "${HERE}/lint/.mdlrc" ~/
ln -sf "${HERE}/lint/.mdlrc.style.rb" ~/
ln -sf "${HERE}/lint/.eslintrc.json" ~/
ln -sf "${HERE}/lint/.textlintrc" ~/
ln -sf "${HERE}/lint/.textlintrc" ~/
ln -sf "${HERE}/lint/.prh.yml" ~/
ln -sf "${HERE}/vim/.gvimrc" ~/
ln -sf "${HERE}/vim/.vimrc" ~/
ln -sf "${HERE}/.bashrc" ~/
ln -sf "${HERE}/.ctags" ~/
ln -sf "${HERE}/.gitconfig" ~/
if [ "${OSTYPE}" = msys ] ; then
  ln -sf "${HERE}/.gitconfig.windows" ~/.gitconfig.environment
else
  ln -sf "${HERE}/.gitconfig.linux" ~/.gitconfig.environment
fi
ln -sf "${HERE}/.gitignore" ~/
ln -sf "${HERE}/.gitattributes" ~/
ln -sf "${HERE}/.git_templates" ~/
ln -sf "${HERE}/.inputrc" ~/
ln -sf "${HERE}/.tmux.conf" ~/
ln -sf "${HERE}/.todo" ~/

if [ "${OSTYPE}" = msys ] ; then
  ln -sf "${HERE}/AutoHotKey.ahk" ~/Documents/
  ln -sf "${HERE}/.minttyrc" ~/
fi

