#!/bin/bash -e

if [[ $EUID != 0 ]]
then
    user="$(id -un)"
    group="$(id -gn)"
    exec sudo "$0" "$user" "$group" "$@"
else
    root="$(dirname "$0")/.."
    package_set="$(basename "$PWD")"
    user="$1"
    group="$2"
    target="$3" # not essential

    run_makepkg()
    {
        rm -f *.pkg.tar.xz
        makepkg -os --asroot --noconfirm
        chown "$user:$group" -R .
        su "$user" -c 'makepkg -f'
    }

    install_main()
    {
        makepkg -i --asroot --noconfirm
    }

    install_dep()
    {
        pacman -U --asdeps --noconfirm *.pkg.tar.xz
    }

    for i in `tsort dependencies`
    do
        pushd "$i"
        run_makepkg
        if [[ $i = $target ]] || fgrep "$i" install >/dev/null 2>&1
        then
            install_main
        else
            install_dep
        fi
        popd
        if [[ $i = $target ]]
        then
            break
        fi
    done
fi

