REM TODO 既存リンク上書き
REM TODO 改行コードをdosにする
REM TODO %HOME%未定義のとき考慮

mklink /J "%HOME%\dotfiles" "%HOME%\Development\dotfiles"

mklink "%HOME%\Documents\AutoHotkey.ahk" "%HOME%\Development\dotfiles\AutoHotkey.ahk"

mklink "%HOME%\.bashrc" "%HOME%\Development\dotfiles\.bashrc"
mklink "%HOME%\.ctags" "%HOME%\Development\dotfiles\.ctags"
mklink "%HOME%\.gitconfig" "%HOME%\Development\dotfiles\.gitconfig"
mklink "%HOME%\.gitignore" "%HOME%\Development\dotfiles\.gitignore"
mklink "%HOME%\.inputrc" "%HOME%\Development\dotfiles\.inputrc"
mklink "%HOME%\.minttyrc" "%HOME%\Development\dotfiles\.minttyrc"
mklink "%HOME%\.tmux.conf" "%HOME%\Development\dotfiles\.tmux.conf"

mklink "%HOME%\_gvimrc" "%HOME%\Development\dotfiles\vim\.gvimrc"
mklink "%HOME%\_vimrc" "%HOME%\Development\dotfiles\vim\.vimrc"

REM TODO Eclipse Marsは%USERPROFILE%を見る。Keplerは%HOME%を見る。
REM TODO Eclipse Marsは.vrapperrcを見る。Keplerは_vrapperrcを見る。
mklink "%HOME%\.vrapperrc.environment" "%HOME%\Development\dotfiles\eclipse\_vrapperrc.win"
mklink "%USERPROFILE%\.vrapperrc.environment" "%HOME%\Development\dotfiles\eclipse\_vrapperrc.win"
mklink "%HOME%\_vrapperrc" "%HOME%\Development\dotfiles\eclipse\_vrapperrc"
mklink "%USERPROFILE%\.vrapperrc" "%HOME%\Development\dotfiles\eclipse\_vrapperrc"

mklink "%HOME%\.mdlrc" "%HOME%\Development\dotfiles\lint\.mdlrc"
mklink "%HOME%\.mdlrc.style.rb" "%HOME%\Development\dotfiles\lint\.mdlrc.style.rb"

git config user.name "assout"
git config user.email "assout@users.noreply.github.com"
