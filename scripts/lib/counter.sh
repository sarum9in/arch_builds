#!/bin/bash -e

reporel=1215

counter_file="$(readlink -f "$BASH_SOURCE")"

update_reporel()
{
    reporel=$((reporel + 1))
    sed -r "s|^(reporel=).*$|\1${reporel}|" -i "$counter_file"
}
