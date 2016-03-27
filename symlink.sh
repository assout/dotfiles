#!/bin/bash

readonly CMD_NAME=$(basename "${0}")
if [ "${OSTYPE}" = msys ] ; then
  echo "${CMD_NAME}: It doesn't meet the prerequisites" >&2
  exit 1
fi

readonly HERE=$(cd "$(dirname "$0")" || exit 1; pwd)

ln -sf "${HERE}/eclipse/_vrapperrc" ~/.vrapperrc
ln -sf "${HERE}/eclipse/_vrapperrc.linux" ~/.vrapperrc.environment
ln -sf "${HERE}/lint/.mdlrc" ~/
ln -sf "${HERE}/lint/.mdlrc.style.rb" ~/
ln -sf "${HERE}/lint/.eslintrc.json" ~/
ln -sf "${HERE}/lint/.textlintrc" ~/
ln -sf "${HERE}/lint/.textstatrc" ~/
ln -sf "${HERE}/vim/.gvimrc" ~/
ln -sf "${HERE}/vim/.vimrc" ~/
ln -sf "${HERE}/.bashrc" ~/
ln -sf "${HERE}/.ctags" ~/
ln -sf "${HERE}/.gitconfig" ~/
ln -sf "${HERE}/.gitconfig.linux" ~/.gitconfig.environment
ln -sf "${HERE}/.gitignore" ~/
ln -sf "${HERE}/.gitattributes" ~/
ln -sf "${HERE}/.inputrc" ~/
ln -sf "${HERE}/.tmux.conf" ~/
ln -sf "${HERE}/.todo" ~/

