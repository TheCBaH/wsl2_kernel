#!/bin/sh
set -x
set -eu
cmd=$1;shift

repo=wsl2-repo
_git="git -C $repo.git"
case "$cmd" in
init)
    rm -rf $repo $repo.git;mkdir -p $repo.git
    $_git init .
    $_git remote add origin https://github.com/microsoft/WSL2-Linux-Kernel.git
    for b in linux-msft-wsl-4.19.y linux-msft-wsl-5.10.y linux-msft-wsl-5.4.y; do
        $_git remote set-branches --add origin $b
    done
    ;;
update)
    ref=$1;shift
    $_git -c protocol.version=2 fetch --no-tags --depth 1 origin
    rm -rf $repo;cp -rl $repo.git $repo
    _git="git -C $repo"
    $_git -c protocol.version=2 fetch --no-tags --depth 1 origin $ref:$ref
    $_git checkout $ref
    ;;
done