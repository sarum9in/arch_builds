#!/bin/bash -e

source "$(dirname "$0")/lib/chroot.sh"

export LC_ALL=C

add_to_db()
{
    local pkgfile="$1"
    mkdir -p "$chroot/$user/repo"
    pushd "$chroot/$user/repo" >/dev/null
    cp "$pkgfile" .
    repo-add repo.db.tar.gz "${pkgfile##*/}"
    popd >/dev/null
}

raw_make_chroot_pkg()
{
    local oldver="$(. ./PKGBUILD && echo "$pkgver")"
    local oldrel="$(. ./PKGBUILD && echo "$pkgrel")"
    sudo -u "$user" -g "$group" makepkg --nobuild --nodeps
    sed -r "s|^pkgrel=.*$|pkgrel=${reporel}|" -i PKGBUILD
    makechrootpkg -r "$chroot" -- --holdver "$@"
    sed -r "s|^pkgver=.*$|pkgver=${oldver}|" -i PKGBUILD
    sed -r "s|^pkgrel=.*$|pkgrel=${oldrel}|" -i PKGBUILD
}

make_chroot_pkg()
{
    raw_make_chroot_pkg "$@"
    local cpkgname
    for cpkgname in $(. ./PKGBUILD && echo "${pkgname[@]}")
    do
        echo "Adding $cpkgname" >&2
        local arch=""

        for arch in any i686 x86_64
        do
            local spkgfile="$(. "$chroot/$user/startdir/PKGBUILD" && echo "$cpkgname-$(if [[ -n $epoch ]]; then echo "$epoch:"; fi)$pkgver-$pkgrel")-${arch}.pkg.tar.xz"
            echo "$spkgfile"
            if [[ -f $spkgfile ]]
            then
                pkgfile="$(readlink -f "$spkgfile")"
                break
            fi
        done
        add_to_db "$pkgfile"

        repo_sync "$user"
        failed=0
        while ! chroot_run "$user" pacman --noconfirm -Sw "$cpkgname"
        do
            failed=$((failed + 1))
            if (( failed >= 10 ))
            then
                echo "Unable to build ${PWD#$root}" >&2
                return 1
            fi
        done
    done
}
