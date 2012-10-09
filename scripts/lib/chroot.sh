#!/bin/bash -e

source "$(dirname "$0")/lib/config.sh"

chroot="$root/chroot"

new_chroot()
{
    mkdir -p "$chroot"
    mkarchroot "$chroot/root" base base-devel sudo
}

update_chroot()
{
    mkarchroot -u "$chroot/root"
}

make_chroot()
{
    if [[ -d $chroot/root ]]
    then
        if ! update_chroot
        then
            rm -rf "$chroot"
            new_chroot
        fi
    else
        new_chroot
    fi
}
