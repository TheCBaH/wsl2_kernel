#!/bin/sh
set -x
set -eu

repo=wsl2-repo
rm -rf $repo;mkdir -p $repo
_git="git -C $repo"
$_git init .
$_git remote add origin https://github.com/microsoft/WSL2-Linux-Kernel.git
for b in linux-msft-wsl-4.19.y linux-msft-wsl-5.10.y linux-msft-wsl-5.4.y; do
    $_git remote set-branches --add origin $b
done
$_git -c protocol.version=2 fetch --depth 1 origin
t