# dotfiles

travis-ci: [![Build Status](https://travis-ci.org/assout/dotfiles.svg)](https://travis-ci.org/assout/dotfiles)
jenkins: [![Build Status](https://jenkins-assout.rhcloud.com/buildStatus/icon?job=dotfiles-statistics)](https://jenkins-assout.rhcloud.com/job/dotfiles-statistics/)

Configuration files for editors and other UNIX tools. This is to make it easier to setup programming environment for me.

## How to install

Linux

```
curl -L https://raw.githubusercontent.com/assout/dotfiles/master/install.sh | bash
```

Windows (CMD) (Caution: change repository git user config)

```
mkdir D:\admin\Development\vim-plugins
cd D:\admin\Development
git clone git@github.com:assout/dotfiles.git
cd .\dotfiles
.\install.bat
```

Windows(unix tool e.g. msysgit) (Caution: change repository git user config)

```
mkdir -p ~/Development/vim-plugins
cd ./Development
git clone git@github.com:assout/dotfiles.git
cd ./dotfiles
cmd //c ".\install.bat"
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



