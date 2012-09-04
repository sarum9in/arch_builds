#!/bin/bash -e

if [[ $EUID != 0 ]]
then
    user="$(id -un)"
    group="$(id -gn)"
    sudo "$0" "$user" "$group"
else
    root="$(dirname "$0")/.."
    package_set="$(basename "$PWD")"
    user="$1"
    group="$2"
    shift

    run_makepkg()
    {
        makepkg -os --asroot --noconfirm
        chown "$user:$group" -R .
        su "$user" -c 'makepkg -f'
        makepkg -i --asroot --noconfirm
    }

    for i in `tsort dependencies`
    do
        pushd "$i"
        run_makepkg
        popd
    done
fi

