#!/bin/bash -e

. /etc/qemu-scripts.conf

if [[ $QEMU_BRIDGE ]]
then
    br="${QEMU_BRIDGE}"
else
    br="${bridge?you have to set up bridge interface}"
fi

echo "Executing qemu-ifup"
echo "Bringing up $1 for bridged mode..."
sudo ifconfig "$1" 0.0.0.0 promisc up
echo "Adding "$1" to ${br}..."
sudo brctl addif "${br}" "$1"
sleep 2
