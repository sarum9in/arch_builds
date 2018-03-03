#!/bin/bash -e

reporel=1291

counter_file="$(readlink -f "$BASH_SOURCE")"

update_reporel()
{
    reporel=$((reporel + 1))
    sed -r "s|^(reporel=).*$|\1${reporel}|" -i "$counter_file"
}

release_repo()
{
    rm -f "$chroot/$user/repo/${repo_name}.db.tar.gz.old"
    rm -f "$chroot/$user/repo/${repo_name}.db.tar.gz.old.sig"
    rm -f "$chroot/$user/repo/${repo_name}.files.tar.gz.old"
    tar cf "$root/${repo_name}.tar" \
        --directory="$chroot/$user/repo" \
        --owner=root:0 \
        --group=root:0 \
        .
    update_reporel
}
