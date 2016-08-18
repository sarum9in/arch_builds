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
    if [[ ${pkg:0:1} = '^' ]]
    then
        if [[ -d "${pkg:1}" ]]
        then
            build-directory "${pkg:1}"
        else
            build-yaourt "${pkg:1}"
        fi
    else
        build-directory "$pkg"
    fi
}

build-directory()
{
    pushd "$1"
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
}

build-yaourt()
{
    local tmp="$(mktemp -d)"
    pushd "$tmp"
    chmod 777 "$tmp"
    # FIXME it works but returns non-zero
    yaourt -G "$1" || true
    cd "$1"
    # FIXME test PKGBUILD presence instead of yaourt's exit status
    test -f PKGBUILD
    chmod 777 .
    make_chroot_pkg
    popd
    rm -rf "$tmp"
}

build-go()
{
    local tmp="$(mktemp -d)"
    pushd "$tmp"
    chmod 777 "$tmp"
    go-makepkg -d . "$@"
    make_chroot_pkg
    popd
    rm -rf "$tmp"
}

clean

# Base libraries
build turtle
build turtle-git
build protobuf3
build python-pika
build grpc
build czmq
build czmqpp-git
build cppcms
build cppdb
build boost.dll-git
build ^boost-nowide

# Bunsan / Yandex.Contest / BACS
build bunsan
build yandex-contest
build bacs
build bacs/legacy/userlibs
build bacs/legacy/web

# Infrastructure
build ^rabbitmqadmin

# Utils
build obnam
build qemu-scripts
build ^arno-iptables-firewall
build ^pacmixer
build python-cram
build ip-wait-online

build ^cower
build ^pacaur

# Go packages
build-go \
    -m "Aleksey Filippov <sarum9in@gmail.com>" \
    -n go-bunsan.broker-git \
    -D bunsan.pm-git,bunsan.broker-git \
    "bunsan.borker" git+https://github.com/bunsanorg/broker/...

pushd "$chroot/$user/repo"
mv "repo.db.tar.gz" "${repo_name}.db.tar.gz"
rm -f "repo.db.tar.gz.old"
rm -f "repo.db"
ln -sf "${repo_name}.db.tar.gz" "${repo_name}.db"
tar cf "$root/${repo_name}.tar" .
popd

update_reporel
