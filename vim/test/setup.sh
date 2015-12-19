#!/bin/bash
bundle_dir=${WORKSPACE}/target/bundle
mkdir -p "${bundle_dir}"
git clone https://github.com/Shougo/neobundle.vim "${bundle_dir}/neobundle.vim"

vim -N -u "${WORKSPACE}"/vim/.vimrc -c "try | NeoBundleUpdate! $* | finally | qall! | endtry" -U NONE -i NONE -V1 -e -s || :

