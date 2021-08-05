#!/bin/bash
set -x
set -eu
config=$1
disable () {
    echo "s/^(CONFIG_$1)=.*/# \1 is not set/"
}

enable () {
    echo 's/# (CONFIG_'$1').*/\1=y/'
}

sed -Ei\
 -e "$(disable BTRFS_FS)"\
 -e "$(disable CC_OPTIMIZE_FOR_PERFORMANCE)"\
 -e "$(disable CEPH_FS)"\
 -e "$(disable CIFS)"\
 -e "$(disable CPU_SUP_CENTAUR)"\
 -e "$(disable HOTPLUG_CPU)"\
 -e "$(disable IPV6)"\
 -e "$(disable JBD2)"\
 -e "$(disable NFSD)"\
 -e "$(disable NFS_FS)"\
 -e "$(disable PPP)"\
 -e "$(disable RANDOMIZE_MEMORY)"\
 -e "$(disable RETPOLINE)"\
 -e "$(disable SLHC)"\
 -e "$(disable WIREGUARD)"\
 -e "$(disable XFS_FS)"\
 -e "$(enable BLK_DEV_NBD)"\
 -e "$(enable CC_OPTIMIZE_FOR_SIZE)"\
 $config

git -C $(dirname $config) diff