# dotfiles

travis-ci: [![Build Status](https://travis-ci.org/assout/dotfiles.svg)](https://travis-ci.org/assout/dotfiles)
jenkins: [![Build Status](https://jenkins-assout.rhcloud.com/buildStatus/icon?job=dotfiles-statistics)](https://jenkins-assout.rhcloud.com/job/dotfiles-statistics/)

Configuration files for editors and other UNIX tools. This is to make it easier to setup programming environment for me.

## How to symlink

    git clone https://github.com/assout/dotfiles
    cd dotfiles
    ./symlink.sh

## Notes

### gitignore by gibo

    (gibo \
    Eclipse \
    GitBook \
    Java \
    JetBrains \
    Linux \
    Maven \
    Node \
    Vim \
    Windows \
    ; cat .gitignore.manual) > .config/git/ignore

### WSL tty

    Font=Ricty Diminished
    FontHeight=10

    BackgroundColour=29,31,33
    ForegroundColour=197,200,198
    BoldBlack=40,42,46
    Black=25,29,35
    BoldRed=165,66,66
    Red=204,102,102
    BoldGreen=140,148,64
    Green=181,189,104
    BoldYellow=222,147,95
    Yellow=240,198,116
    BoldBlue=95,129,157
    # Blue=129,162,190
    BoldMagenta=133,103,143
    Magenta=178,148,187
    BoldCyan=94,141,135
    Cyan=138,190,183

# vim: filetype=config:
