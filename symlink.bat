MKLINK "C:\Users\22665952\_gvimrc" "\\wsl$\Ubuntu\home\hirokawak\ghq\github.com\assout\dotfiles\vim\.gvimrc"
MKLINK "C:\Users\22665952\_vimrc" "\\wsl$\Ubuntu\home\hirokawak\ghq\github.com\assout\dotfiles\vim\.vimrc"

MKLINK "C:\Users\porin\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "\\wsl$\Ubuntu\home\assout\ghq\github.com\assout\dotfiles\WindowsTerminal\settings.json"

rem WSL起動の前にスタートアップが実行されると起動されない？
rem MKLINK "C:\Users\porin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotkey.ahk" "\\wsl$\Ubuntu\home\assout\ghq\github.com\assout\dotfiles\AutoHotkey.ahk"
copy "\\wsl$\Ubuntu\home\assout\ghq\github.com\assout\dotfiles\AutoHotkey.ahk" "C:\Users\porin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotkey.ahk"

copy "\\wsl$\Ubuntu\home\assout\ghq\github.com\assout\dotfiles\.wslconfig" "C:\Users\porin\.wslconfig"

pause

