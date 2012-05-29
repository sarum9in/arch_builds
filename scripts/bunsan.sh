#!/bin/bash -e

if [[ $EUID != 0 ]]
then
    user="$(id -un)"
    group="$(id -gn)"
    sudo "$0" "$user" "$group"
else
    root="$(dirname "$0")/.."
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

    for i in boost.process-svn xmlrpc-c zeromq cppzmq
    do
        pushd "$root/$i"
        run_makepkg
        popd
    done

    for i in common utility pm
    do
        pushd "$root/bunsan/$i"
        run_makepkg
        popd
    done
fi

