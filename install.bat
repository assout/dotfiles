rem TODO: 既存リンク上書き
rem TODO: %HOME%未定義のとき考慮

rem 当ファイル自身のパス
set here=%~dp0

mklink /J "%HOME%\dotfiles" "%here%"
mklink "%HOME%\Documents\AutoHotkey.ahk" "%here%\AutoHotkey.ahk"

mklink "%HOME%\.bashrc" "%here%\.bashrc"
mklink "%HOME%\.ctags" "%here%\.ctags"
mklink "%HOME%\.gitconfig" "%here%\.gitconfig"
mklink "%HOME%\.gitignore" "%here%\.gitignore"
mklink "%HOME%\.gitattributes" "%here%\.gitattributes"
mklink "%HOME%\.inputrc" "%here%\.inputrc"
mklink "%HOME%\.minttyrc" "%here%\.minttyrc"
mklink "%HOME%\.tmux.conf" "%here%\.tmux.conf"

mklink "%HOME%\_gvimrc" "%here%\vim\.gvimrc"
mklink "%HOME%\_vimrc" "%here%\vim\.vimrc"

rem TODO: Eclipse Marsは%USERPROFILE%を見る。Keplerは%HOME%を見る。
rem TODO: Eclipse Marsは.vrapperrcを見る。Keplerは_vrapperrcを見る。
mklink "%HOME%\.vrapperrc.environment" "%here%\eclipse\_vrapperrc.win"
mklink "%USERPROFILE%\.vrapperrc.environment" "%here%\eclipse\_vrapperrc.win"
mklink "%HOME%\_vrapperrc" "%here%\eclipse\_vrapperrc"
mklink "%USERPROFILE%\.vrapperrc" "%here%\eclipse\_vrapperrc"

mklink "%HOME%\.mdlrc" "%here%\lint\.mdlrc"
mklink "%HOME%\.mdlrc.style.rb" "%here%\lint\.mdlrc.style.rb"

git config user.name "assout"
git config user.email "assout@users.noreply.github.com"

