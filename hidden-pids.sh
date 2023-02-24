#!/bin/bash
#
# Reveal rootkits that hide processes from getdents() calls to /proc
#
# Inspired by:
# https://github.com/sandflysecurity/sandfly-processdecloak/blob/master/processutils/processutils.go

if [[ $EUID != 0 ]]; then
  echo "* WARNING: For accurate output, run $0 as uid 0"
fi

declare -A visible
cd /proc || exit
start=$(date +%s)
for pid in *; do
    visible[$pid]=1
done

max=$(cat /proc/sys/kernel/pid_max)
echo "- Scanning hidden pids from 1 to ${max} ..."
for i in $(seq 1 "${max}"); do
    if [[ ! -e /proc/$i/status ]]; then
        continue
    fi
    if [[ ${visible[$i]} = 1 ]]; then
        continue
    fi

    if [[ $(stat -c %Z /proc/$$) -gt $start ]]; then
        continue
    fi

    # This process is actually a thread
    if [[ $(awk '/Tgid/{ print $2 }' "/proc/${i}/status") != "${i}" ]]; then
        continue
    fi

    exe=$(readlink "/proc/$i/exe")
    cmdline=$(tr '\000' ' ' <"/proc/$i/cmdline")
    name=$(cat "/proc/$i/comm")
    echo "HIDDEN: ${name}[${i}] is running ${exe}: ${cmdline}"
done
