#!/bin/bash

if [ "${OSTYPE}" = msys ] ; then
  echo "install.sh: It doesn't meet the prerequisites" >&2
  exit 1
fi

readonly INSTALL_DIR=~/Development
readonly HERE="${INSTALL_DIR}/dotfiles"

mkdir -p ~/Development/vim-plugins

cd "${INSTALL_DIR}" || exit
if [ ! -d "./dotfiles" ] ; then
  git clone git@github.com:assout/dotfiles.git
fi

ln -sf "${HERE}/" ~/

ln -sf "${HERE}/eclipse/_vrapperrc" ~/.vrapperrc
ln -sf "${HERE}/eclipse/_vrapperrc.linux" ~/.vrapperrc.environment
ln -sf "${HERE}/lint/.mdlrc" ~/
ln -sf "${HERE}/lint/.mdlrc.style.rb" ~/
ln -sf "${HERE}/lint/.eslintrc.json" ~/
ln -sf "${HERE}/lint/.textlintrc" ~/
ln -sf "${HERE}/lint/.textstatrc" ~/
ln -sf "${HERE}/vim/.gvimrc" ~/
ln -sf "${HERE}/vim/.vimrc" ~/
ln -sf "${HERE}/vim/.vimrc.development" ~/Development/vim-plugins
ln -sf "${HERE}/.bashrc" ~/
ln -sf "${HERE}/.ctags" ~/
ln -sf "${HERE}/.gitconfig" ~/
ln -sf "${HERE}/.gitconfig.linux" ~/.gitconfig.environment
ln -sf "${HERE}/.gitignore" ~/
ln -sf "${HERE}/.gitattributes" ~/
ln -sf "${HERE}/.inputrc" ~/
ln -sf "${HERE}/.tmux.conf" ~/
ln -sf "${HERE}/.todo" ~/

