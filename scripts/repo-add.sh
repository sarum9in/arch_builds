#!/bin/bash -e

source "$(dirname "$0")/lib/root.sh"
source "$(dirname "$0")/lib/makechrootpkg.sh"
source "$(dirname "$0")/lib/cdroot.sh"

rm -rf "$chroot/$user" "$chroot/$user.lock"

name="mirror.cs.istu.ru"

build()
{
    local pkg="$1"
    if [[ ${pkg:0:1} = '~' ]]
    then
        pushd "${pkg:1}/.."
        for i in `tsort <dependencies`
        do
            build "$i"
            if [[ $(basename "$pkg") = $i ]]
            then
                break
            fi
        done
        popd
    elif [[ ${pkg:0:1} = '^' ]]
    then
        local tmp="$(mktemp -d)"
        pushd "$tmp"
        yaourt -G "${pkg:1}"
        cd "${pkg:1}"
        make_chroot_pkg
        popd
        rm -rf "$tmp"
    else
        pushd "${pkg}"
        if [[ -f dependencies ]]
        then
            for i in `tsort <dependencies`
            do
                build "$i"
            done
        else
            make_chroot_pkg
        fi
        popd
    fi
}

for pkg in 'bunsan' '~yandex-contest/invoker' 'bunsan/bacs' 'qemu-scripts' 'bacs/legacy/userlibs' #'obnam-bzr'
do
    build "$pkg"
done

pushd "$chroot/$user/repo"
mv "repo.db.tar.gz" "$name.db.tar.gz"
rm -f "repo.db.tar.gz.old"
rm -f "repo.db"
ln -sf "$name.db.tar.gz" "$name.db"
tar cf "$root/$name.tar" .
popd
