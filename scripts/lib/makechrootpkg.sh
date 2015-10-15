#!/bin/bash -e

source "$(dirname "$0")/lib/chroot.sh"

export LC_ALL=C

readonly makechrootpkg="$bindir/makechrootpkg"

add_to_db()
{
    local pkgfile="$1"
    mkdir -p "$chroot/$user/repo"
    pushd "$chroot/$user/repo" >/dev/null
    cp -v "$pkgfile" .
    repo-add repo.db.tar.gz "${pkgfile##*/}"
    popd >/dev/null
    repo_sync "$user"
}

patch_makechrootpkg()
{
    mkdir -p "$root/scripts/bin"
    sed -r 's|--verifysource|& --skippgpcheck|' "$(which makechrootpkg)" >"$makechrootpkg"
    chmod +x "$makechrootpkg"
}

backup_pkgbuild()
{
    cp -f PKGBUILD PKGBUILD.bak
}

restore_pkgbuild()
{
    cp -f PKGBUILD.bak PKGBUILD
}

raw_make_chroot_pkg()
{
    backup_pkgbuild
    {
        patch_makechrootpkg
        sed -r "s|^_github_token=.*$|_github_token=${github_token}|" -i PKGBUILD || true
        sudo -u "$user" -g "$group" makepkg --nobuild --nodeps --skippgpcheck
        sed -r "s|^pkgrel=.*$|pkgrel=${reporel}|" -i PKGBUILD
        "$makechrootpkg" -r "$chroot" -- --holdver --skippgpcheck "$@"
    } || {
        ret=$?
        restore_pkgbuild
        return $ret
    }
    restore_pkgbuild
}

pkg_name_version()
(
    . "$1"
    echo -n "$cpkgname-"
    if [[ -n $epoch ]]
    then
        echo -n "$epoch:"
    fi
    echo "$pkgver-$pkgrel"
)

make_chroot_pkg()
{
    echo >&2
    echo "[[[ Making package $PWD ]]]" >&2
    echo >&2
    raw_make_chroot_pkg "$@"
    local cpkgname
    for cpkgname in $(. ./PKGBUILD && echo "${pkgname[@]}")
    do
        echo "Adding $cpkgname" >&2
        local arch=""

        for arch in any i686 x86_64
        do
            local spkgfile="$(pkg_name_version "$chroot/$user/startdir/PKGBUILD")-${arch}.pkg.tar.xz"
            if [[ -f $spkgfile ]]
            then
                local pkgfile="$(readlink -f "$spkgfile")"
                echo "$spkgfile exists as $pkgfile" >&2
                break
            else
                echo "$spkgfile does not exist, retrying..." >&2
            fi
        done
        add_to_db "$pkgfile"
        failed=0
        while ! chroot_run "$user" pacman --noconfirm -Sw "$cpkgname"
        do
            add_to_db "$pkgfile"
            failed=$((failed + 1))
            if (( failed >= 10 ))
            then
                echo "Unable to build ${PWD#$root}" >&2
                return 1
            fi
        done
    done
    echo >&2
    echo "[[[ $PWD make completed ]]]" >&2
}
