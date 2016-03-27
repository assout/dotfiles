# dotfiles

travis-ci: [![Build Status](https://travis-ci.org/assout/dotfiles.svg)](https://travis-ci.org/assout/dotfiles)
jenkins: [![Build Status](https://jenkins-assout.rhcloud.com/buildStatus/icon?job=dotfiles-statistics)](https://jenkins-assout.rhcloud.com/job/dotfiles-statistics/)

Configuration files for editors and other UNIX tools. This is to make it easier to setup programming environment for me.

## How to symlink

Linux

```
git clone https://github.com/assout/dotfiles
cd dotfiles
./symlink.sh
```

Windows (CMD) (Caution: change repository git user config)

```
mkdir D:\admin\Development\vim-plugins
cd D:\admin\Development
git clone git@github.com:assout/dotfiles.git
cd .\dotfiles
.\symlink.bat
```

Windows(unix tool e.g. msysgit) (Caution: change repository git user config)

```
mkdir -p ~/Development/vim-plugins
cd ./Development
git clone git@github.com:assout/dotfiles.git
cd ./dotfiles
cmd //c ".\symlink.bat"
```

## Notes

### gitignore by gibo

    (gibo \
    Eclipse \
    Java \
    Linux \
    Vim \
    Windows \
    ; cat .gitignore.manual) > .gitignore



