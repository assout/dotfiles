MKLINK "C:\Users\porin\_gvimrc" "\\wsl$\Ubuntu\home\assout\.ghq\github.com\assout\dotfiles\vim\.gvimrc"
MKLINK "C:\Users\porin\_vimrc" "\\wsl$\Ubuntu\home\assout\.ghq\github.com\assout\dotfiles\vim\.vimrc"

MKLINK "C:\Users\porin\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "\\wsl$\Ubuntu\home\assout\.ghq\github.com\assout\dotfiles\WindowsTerminal\settings.json"
MKLINK "C:\Users\porin\.wslconfig" "\\wsl$\Ubuntu\home\assout\.ghq\github.com\assout\dotfiles\.wslconfig"

rem WSL起動の前にスタートアップが実行されると起動されない？
MKLINK "C:\Users\porin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotkey.ahk" \\wsl$\Ubuntu\home\assout\.ghq\github.com\assout\dotfiles\AutoHotkey.ahk
cp AutoHotkey.ahk "C:\Users\porin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotkey.ahk"

pause

