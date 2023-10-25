#!/bin/bash
#
if [[ $EUID != 0 ]]; then
  echo "This script only returns full output when run as root"
fi

# Reveal processes with weird lock files open in /var/run open
for pid in $(sudo find /proc -type l -lname "/run/*.lock" 2>/dev/null | cut -d/ -f3 | sort -u); do
    path=$(readlink /proc/$pid/exe)
    name=$(cat /proc/$pid/comm)

    if [[ "${name}" = "pipewire" ]]; then
      continue
    fi

    echo "Suspicious lock files open: ${name} [${pid}] at ${path}:"
    for fd in /proc/$pid/fd/*; do
        readlink $fd | grep lock
    done
done
