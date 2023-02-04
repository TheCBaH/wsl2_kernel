#!/bin/sh
set -x
set -eu
cmd=$1;shift

with_retry() {
    rc=0
    for i in $(seq 1 10); do
        if "$@" ; then
            break
        fi
        rc=$?
        sleep $(od -A n -t d -N 1 /dev/urandom)
    done
    if [ $rc -ne 0 ]; then
        exit $rc
    fi
}

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
    with_retry $_git -c protocol.version=2 fetch --no-tags --depth 1 origin
    ;;
update)
    ref=$1;shift
    with_retry $_git -c protocol.version=2 fetch --no-tags --depth 1 origin
    _git="git -C $repo"
    if [ -d $repo ]; then
        $_git checkout .
        $_git clean -xdf
    else
        cp -rl $repo.git $repo
    fi
    with_retry $_git -c protocol.version=2 fetch --no-tags --depth 1 origin $ref
    $_git reset --merge FETCH_HEAD
    ;;
esac
