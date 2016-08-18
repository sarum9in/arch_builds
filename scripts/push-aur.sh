#!/bin/bash -e

script="$(readlink -f "$0")"
hook="$(dirname "$script")/pre-commit.sh"

if [[ -f .git ]]
then
    git push aur HEAD:master
else
    git submodule foreach "$script"
fi
