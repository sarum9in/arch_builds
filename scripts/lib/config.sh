#!/bin/bash -e

script="$(readlink -f "$0")"
root="$(cd "$(dirname "$(dirname "$script")")" && pwd)"
scriptsdir="$root/scripts"
bindir="$scriptsdir/bin"
libdir="$scriptsdir/lib"

repo_name="mirror.cs.istu.ru"

try_source()
{
    local src
    for src
    do
        if [[ -f $src ]]
        then
            source "$src"
        fi
    done
}

# User settings
try_source "$scriptsdir/etc/config.sh"
