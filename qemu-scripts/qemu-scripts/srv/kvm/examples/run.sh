#!/bin/bash -ex

###########################################
# example run.sh file for virtual machine #
###########################################

root="$(dirname "$0")"
if [[ ${root:0:1} != / ]]
then
	root="$PWD/$root"
fi

exec "$root/../run-qemu.sh" "$root/config.sh" -nographic -m 2G -hda "$root/img.qcow" "$@"
