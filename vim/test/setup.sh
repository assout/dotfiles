#!/bin/bash
vim_dir=${WORKSPACE}/.vim

curl -fLo "${vim_dir}"/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# vim -N -u "${WORKSPACE}"/vim/.vimrc -c "try | set rtp+=${vim_dir} \| PlugUpdate! $* | finally | qall! | endtry" -U NONE -i NONE -V1 -e -s || :
vim -V -N -u "${WORKSPACE}"/vim/.vimrc -c "PlugUpdate" +qa -U NONE -i NONE -V1 -e -s | :


