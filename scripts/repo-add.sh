#!/bin/bash -e

source "$(dirname "$0")/lib/root.sh"
source "$(dirname "$0")/lib/makechrootpkg.sh"
source "$(dirname "$0")/lib/cdroot.sh"

rm -rf "$chroot/$user" "$chroot/$user.lock"

name="mirror.cs.istu.ru"

for pkg in 'bunsan' '~yandex-contest/invoker' 'qemu-scripts' #'obnam-bzr'
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
        if [[ -f dependencies ]]
        then
            for i in `tsort <dependencies`
            do
                pushd "$i"
                make_chroot_pkg
                popd
            done
        else
            make_chroot_pkg
        fi
        popd
    fi
done

pushd "$chroot/$user/repo"
mv "repo.db.tar.gz" "$name.db.tar.gz"
rm -f "repo.db.tar.gz.old"
rm -f "repo.db"
ln -sf "$name.db.tar.gz" "$name.db"
tar cf "$root/$name.tar" .
popd
