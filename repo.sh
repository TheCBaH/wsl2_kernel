#!/bin/sh
set -x
set -eu
cmd=$1;shift

repo=wsl2-repo
_git="git -C $repo.git"
case "$cmd" in
init)
    if [ ! -d $repo.git ]; then
        mkdir -p $repo.git
        $_git init .
        $_git remote add origin https://github.com/microsoft/WSL2-Linux-Kernel.git
    fi
    for b in linux-msft-wsl-4.19.y linux-msft-wsl-5.10.y linux-msft-wsl-5.4.y; do
        $_git remote set-branches --add origin $b
    done
    $_git -c protocol.version=2 fetch --no-tags --depth 1 origin
    ;;
update)
    ref=$1;shift
    $_git -c protocol.version=2 fetch --no-tags --depth 1 origin
    _git="git -C $repo"
    if [ -d $repo ]; then
        $_git checkout .
        $_git clean -xdf
    else
        cp -rl $repo.git $repo
    fi
    $_git -c protocol.version=2 fetch --no-tags --depth 1 origin +$ref:remote/$ref
    $_git reset --merge remote/$ref
    ;;
esac