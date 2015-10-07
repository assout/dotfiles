#!/bin/bash

mkdir -p ~/Development/vim-plugins
cd ~/Development
git clone git@github.com:assout/dotfiles.git

ln -sf ~/Development/dotfiles/ ~/
ln -sf ~/Development/dotfiles/.bashrc ~/
ln -sf ~/Development/dotfiles/.tmux.conf ~/
ln -sf ~/Development/dotfiles/.inputrc ~/
ln -sf ~/Development/dotfiles/.gitconfig ~/
ln -sf ~/Development/dotfiles/.gitignore ~/
ln -sf ~/Development/dotfiles/markdown/.mdlrc ~/
ln -sf ~/Development/dotfiles/markdown/.mdlrc.style.rb ~/
ln -sf ~/Development/dotfiles/vim/_vimrc ~/.vimrc
ln -sf ~/Development/dotfiles/vim/.vimrc.devlopment ~/Development/vim-plugins
ln -sf ~/Development/dotfiles/vim/_gvimrc ~/.gvimrc
ln -sf ~/Development/dotfiles/eclipse/_vrapperrc ~/.vrapperrc
ln -sf ~/Development/dotfiles/eclipse/_vrapperrc.linux ~/.vrapperrc.environment
