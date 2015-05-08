#!/bin/bash -e

source "$(dirname "$0")/lib/counter.sh"
source "$(dirname "$0")/lib/root.sh"
source "$(dirname "$0")/lib/makechrootpkg.sh"
source "$(dirname "$0")/lib/cdroot.sh"

clean()
{
    rm -rf "$chroot/$user" "$chroot/$user.lock"
}

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
        chmod 777 "$tmp"
        yaourt -G "${pkg:1}"
        cd "${pkg:1}"
        chmod 777 .
        make_chroot_pkg
        popd
        rm -rf "$tmp"
    else
        pushd "${pkg}"
        if [[ -f dependencies ]]
        then
            for i in $(tsort <(egrep -v '^#' dependencies))
            do
                build "$i"
            done
        else
            make_chroot_pkg
        fi
        popd
    fi
}

clean

build protobuf3
build python-pika
build ^python-pika-git
build grpc
build czmq
build czmqpp-git
build bunsan
build yandex-contest
build bunsan/bacs
build qemu-scripts
build bacs/legacy/userlibs
build bacs/legacy/web
build obnam
build ^rabbitmq
build ^rabbitmqadmin

pushd "$chroot/$user/repo"
mv "repo.db.tar.gz" "${repo_name}.db.tar.gz"
rm -f "repo.db.tar.gz.old"
rm -f "repo.db"
ln -sf "${repo_name}.db.tar.gz" "${repo_name}.db"
tar cf "$root/${repo_name}.tar" .
popd

update_reporel
