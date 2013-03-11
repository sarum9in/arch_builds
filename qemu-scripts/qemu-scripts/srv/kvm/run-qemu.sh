 #!/bin/bash -ex

. /etc/qemu-scripts.conf

on_exit()
{
    if [[ $pid ]]
    then
        echo "terminating $pid" >&2
        kill -TERM "$pid"
        wait "$pid"
    fi
    sudo tunctl -d "$iface"
    exit
}
trap on_exit TERM INT EXIT

config="$1"
. "$config"
shift

userid="$(whoami)"
iface="$(sudo tunctl -b -u $userid)"

root="$(dirname "$0")"
if [[ ${root:0:1} != / ]]
then
    root="$PWD/$root"
fi

if [[ -z ${qemu[*]} ]]
then
    echo "You have to specify qemu binary!" >&2 && exit 1
fi

if [[ -z $macaddr ]]
then
    macaddr="$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)))"
fi

"${qemu[@]}" -net nic,macaddr="$macaddr",model=rtl8139 -net tap,ifname="$iface",script="$root/qemu-ifup.sh" "$@" &
pid="$!"

wait "$pid"
