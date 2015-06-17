#!/bin/bash -e

script="$(readlink -f "$0")"

if [[ -f .git ]]
then
    url="ssh://aur@aur4.archlinux.org/$(basename "$PWD").git"
    if git remote add aur "$url" &>/dev/null
    then
        echo "Added aur = $url"
    else
        git remote set-url aur "$url"
        echo "Fixed aur = $url"
    fi
else
    git submodule foreach "$script"
fi
