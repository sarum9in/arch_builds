#!/bin/bash -e

source "$(dirname "$0")/root.sh"

cd "$(dirname "$(dirname "$0")")"

root="$PWD"

chroot="$root/chroot"

new_chroot()
{
    mkarchroot "$chroot" base base-devel sudo --ignore linux
}

update_chroot()
{
    mkarchroot -u "$chroot"
}

if [[ -d $chroot ]]
then
    if ! update_chroot
    then
        rm -rf "$chroot"
        new_chroot
    fi
else
    new_chroot
fi
