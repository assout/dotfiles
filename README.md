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

