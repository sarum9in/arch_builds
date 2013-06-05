#!/bin/bash -e

source "$(dirname "$0")/lib/config.sh"

chroot="$root/chroot"

chroot_run()
{
    mkarchroot -r "$1" "$chroot/${2:-root}"
}

repo_sync()
{
    chroot_run "pacman -Sy" "$@"
}

new_chroot()
{
    mkdir -p "$chroot"
    mkarchroot "$chroot/root" base base-devel sudo
    local mflags="$(sed -rn 's|^MAKEFLAGS=(".*")$|\1|p' /etc/makepkg.conf)"
    if [[ -n $mflags ]]
    then
        sed -ri "s|^.*(MAKEFLAGS=).*$|\1$mflags|" "$chroot/root/etc/makepkg.conf"
    fi
    sed -ri 's|^CheckSpace|#&|' "$chroot/root/etc/pacman.conf"
    sed -ri 's|^(SigLevel[[:space:]]*=).*$|\1 Optional|' "$chroot/root/etc/pacman.conf"
    cat >>"$chroot/root/etc/pacman.conf" <<EOF
[repo]
Server = file:///repo
EOF
    mkdir -p "$chroot/root/repo"
    pushd "$root/empty"
    rm -f *.pkg.tar.xz
    makepkg --asroot -f
    local pkgname="$(ls *.pkg.tar.xz)"
    cp -f "$pkgname" "$chroot/root/repo"
    popd
    repo-add "$chroot/root/repo/repo.db.tar.gz" "$chroot/root/repo/$pkgname"
    repo_sync
}

update_chroot()
{
    mkarchroot -u "$chroot/root"
}

make_chroot()
{
    if [[ -d $chroot/root ]]
    then
        if ! update_chroot
        then
            rm -rf "$chroot"
            new_chroot
        fi
    else
        new_chroot
    fi
}
