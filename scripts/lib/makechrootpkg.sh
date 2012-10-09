#!/bin/bash -e

source "$(dirname "$0")/lib/chroot.sh"

make_chroot_pkg()
{
    makechrootpkg -r "$chroot" -d -- "$@"
    repo_sync "$user"
}
