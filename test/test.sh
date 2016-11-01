#!/bin/sh

vim --cmd version --cmd quit

vint --version
vint vim/.vimrc
vint vim/.gvimrc
# TODO: vlmlparser通らないっぽいからダメ - vint eclipse/_vrapperrc

bashate -i E002,E003 .bashrc "$(find -name "*.sh")"
shellcheck .bashrc "$(find -name "*.sh")"

