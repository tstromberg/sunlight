#!/bin/bash
#
# Ignore header and 802.1x (888e) entries

if [[ $EUID != 0 ]]; then
  echo "This script requires root"
  exit 1
fi

for inode in $(egrep -v "^sk|\s888e\s" /proc/net/packet | awk '{ print $9 }'); do
    proc=$(find /proc -type l -lname "socket:\[${inode}\]" -ls 2>/dev/null | egrep -o "/proc/[0-9]+" | sort -u)
    if [[ "${proc}" == "" ]]; then
        echo "Unable to find pid behind socket ${inode}"
        continue
    fi
    pid=$(basename ${proc})
    path=$(readlink /proc/$pid/exe)
    name=$(cat /proc/$pid/comm)
    echo "Raw packet sniffer: ${name} [${pid}] at ${path}:"
    egrep "^sk|\s${inode}" /proc/net/packet
    echo ""
done
