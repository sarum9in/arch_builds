#!/bin/bash -e

on_exit()
{
    rm -rf "$tmp"
}
trap on_exit EXIT INT TERM

tmp="$(mktemp -d)"

cd "$(dirname "$0")"
. ./PKGBUILD

cp -r "$pkgname" "$tmp/$pkgname-$pkgver"
(cd "$tmp" && tar cJf - "$pkgname-$pkgver" ) >"$pkgname-$pkgver.tar.xz"

lines="$(egrep -n '^md5sums=' PKGBUILD | cut -f1 -d':')"
lines_count="$(echo "$lines" | wc -l)"

if [[ $lines_count = 1 ]]
then
    head -n $(($lines-1)) PKGBUILD >"$tmp/PKGBUILD"
    makepkg -g >>"$tmp/PKGBUILD"
    tail -n +$(($lines+1)) PKGBUILD >>"$tmp/PKGBUILD"
    cat "$tmp/PKGBUILD" >PKGBUILD
else
    makepkg -g
fi
