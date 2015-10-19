REM TODO 既存リンク上書き

mklink /J "D:\admin\dotfiles" "D:\admin\Development\dotfiles"
mklink "C:\Users\admin\_vimrc" "D:\admin\Development\dotfiles\vim\.vimrc"
mklink "C:\Users\admin\_gvimrc" "D:\admin\Development\dotfiles\vim\.gvimrc"
mklink "C:\Users\admin\.bashrc" "D:\admin\Development\dotfiles\.bashrc"
mklink "C:\Users\admin\.inputrc" "D:\admin\Development\dotfiles\.inputrc"
mklink "C:\Users\admin\.tmux.conf" "D:\admin\Development\dotfiles\.tmux.conf"
mklink "C:\Users\admin\.minttyrc" "D:\admin\Development\dotfiles\.minttyrc"
mklink "C:\Users\admin\.gitconfig" "D:\admin\Development\dotfiles\.gitconfig"
mklink "C:\Users\admin\.gitignore" "D:\admin\Development\dotfiles\.gitignore"
mklink "D:\admin\_vrapperrc" "D:\admin\Development\dotfiles\eclipse\_vrapperrc"
mklink "D:\admin\.vrapperrc.environment" "D:\admin\Development\dotfiles\eclipse\_vrapperrc.win"

git config user.name "assout"
git config user.email "assout@users.noreply.github.com"
