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
        elif [[ -d "patched/${pkg:1}" ]]
        then
            build-directory "patched/${pkg:1}"
        else
            build-aur "${pkg:1}"
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

build-aur()
{
    local tmp="$(mktemp -d)"
    pushd "$tmp"
    chmod 777 "$tmp"
    cower --download --ignorerepo "$1"
    cd "$1"
    test -f PKGBUILD
    chmod 777 .
    make_chroot_pkg
    popd
    rm -rf "$tmp"
}

# go get -u github.com/seletskiy/go-makepkg
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

# Patched from base system
for pkg in $(ls patched)
do
    build-directory "patched/$pkg"
done

# Base libraries
build turtle
build turtle-git
build python-pika
build grpc
build czmq
build cppcms
build boost.dll-git
build ^libprotobuf2

# Bunsan / Yandex.Contest / BACS
build bunsan
build yandex-contest
build bacs

# legacy may depend on new features
build bacs/legacy/backend
build bacs/legacy/userlibs
build bacs/legacy/web

# Utils
build obnam
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
    "bunsan.broker" git+https://github.com/bunsanorg/broker/...

build-go \
    -m "Aleksey Filippov <sarum9in@gmail.com>" \
    -n go-manul-git \
    "manul" git+https://github.com/kovetskiy/manul/...

pushd "$chroot/$user/repo"
mv "repo.db.tar.gz" "${repo_name}.db.tar.gz"
rm -f "repo.db.tar.gz.old"
rm -f "repo.db"
ln -sf "${repo_name}.db.tar.gz" "${repo_name}.db"
tar cf "$root/${repo_name}.tar" .
popd

update_reporel
