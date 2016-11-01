#!/bin/bash

vim --cmd version --cmd quit

vint --version
vint vim/.vimrc
vint vim/.gvimrc
# TODO: vlmlparser通らないっぽいからダメ - vint eclipse/_vrapperrc

# find \( -name "*.sh" -o -name ".bashrc" \) -exec bashate -i E002,E003 {} +
# find \( -name "*.sh" -o -name ".bashrc" \) -exec shellcheck {} +

