#!/bin/bash -e

if [[ $EUID != 0 ]]
then
    user="$(id -un)"
    group="$(id -gn)"
    exec sudo "$0" "$user" "$group" "$@"
else
    user="$1"
    group="$2"
    shift 2
fi
