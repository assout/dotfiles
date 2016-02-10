#!/bin/bash

# TODO: チェック処理リファクタ
if [ "${OSTYPE}" = msys ] ; then echo "install.sh: It doesn't meet the prerequisites" >&2 && exit 1 ; fi

mkdir -p ~/Development/vim-plugins
cd ~/Development

if [ ! -d "./dotfiles" ] ; then
	git clone git@github.com:assout/dotfiles.git
fi

ln -sf ~/Development/dotfiles/ ~/

ln -sf ~/Development/dotfiles/.bashrc ~/
ln -sf ~/Development/dotfiles/.ctags ~/
ln -sf ~/Development/dotfiles/.gitconfig ~/
ln -sf ~/Development/dotfiles/.gitconfig.linux ~/.gitconfig.environment
ln -sf ~/Development/dotfiles/.gitignore ~/
ln -sf ~/Development/dotfiles/.gitattributes ~/
ln -sf ~/Development/dotfiles/.inputrc ~/
ln -sf ~/Development/dotfiles/.tmux.conf ~/
ln -sf ~/Development/dotfiles/eclipse/_vrapperrc ~/.vrapperrc
ln -sf ~/Development/dotfiles/eclipse/_vrapperrc.linux ~/.vrapperrc.environment
ln -sf ~/Development/dotfiles/lint/.mdlrc ~/
ln -sf ~/Development/dotfiles/lint/.mdlrc.style.rb ~/
ln -sf ~/Development/dotfiles/lint/.eslintrc.json ~/
ln -sf ~/Development/dotfiles/lint/.textlintrc ~/
ln -sf ~/Development/dotfiles/lint/.textstatrc ~/
ln -sf ~/Development/dotfiles/vim/.gvimrc ~/
ln -sf ~/Development/dotfiles/vim/.vimrc ~/
ln -sf ~/Development/dotfiles/vim/.vimrc.development ~/Development/vim-plugins
