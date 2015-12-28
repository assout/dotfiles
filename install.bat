REM TODO 既存リンク上書き

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
mklink "%HOME%\.vrapperrc.environment" "%HOME%\Development\dotfiles\eclipse\_vrapperrc.win"
mklink "%USERPROFILE%\.vrapperrc.environment" "%HOME%\Development\dotfiles\eclipse\_vrapperrc.win"
mklink "%HOME%\_vrapperrc" "%HOME%\Development\dotfiles\eclipse\_vrapperrc"
mklink "%USERPROFILE%\_vrapperrc" "%HOME%\Development\dotfiles\eclipse\_vrapperrc"

git config user.name "assout"
git config user.email "assout@users.noreply.github.com"
