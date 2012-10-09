#!/bin/bash -e

source "$(dirname "$0")/lib/root.sh"
source "$(dirname "$0")/lib/makechrootpkg.sh"
source "$(dirname "$0")/lib/cdroot.sh"

packages()
{
    find . -type f -name '*.pkg.tar.xz'
}

#packages -delete

for pkg in '~bunsan/pm' '~yandex-contest/invoker' 'qemu-scripts' #'obnam-bzr'
do
    if [[ ${pkg:0:1} = '~' ]]
    then
        pushd "${pkg:1}/.."
        for i in `tsort <dependencies`
        do
            pushd "$i"
            make_chroot_pkg
            popd
            if [[ $(basename "$pkg") = $i ]]
            then
                break
            fi
        done
        popd
    else
        pushd "${pkg}"
        make_chroot_pkg
        popd
    fi
done
