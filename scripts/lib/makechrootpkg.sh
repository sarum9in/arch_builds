#!/bin/bash -e

source "$(dirname "$0")/lib/chroot.sh"

make_chroot_pkg()
{
    makechrootpkg -r "$chroot" -d -- "$@"
    repo_sync "$user"
    failed=0
    while ! chroot_run "pacman --noconfirm -Sw $(source ./PKGBUILD && echo "$pkgname")" "$user"
    do
        failed=$((failed + 1))
        if (( failed >= 10 ))
        then
            echo "Unable to build ${PWD#$root}" >&2
            return 1
        fi
    done
}
