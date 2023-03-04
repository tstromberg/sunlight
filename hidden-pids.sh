#!/bin/bash
#
# Reveal rootkits that hide processes from getdents() calls to /proc
#
# Inspired by:
# https://github.com/sandflysecurity/sandfly-processdecloak/blob/master/processutils/processutils.go

[[ $(uname) != "Linux" ]] && exit 0
[[ $EUID != 0 ]] && echo "* WARNING: For accurate output, run $0 as uid 0"

declare -A visible
cd /proc || exit

start=$(date +%s)
for pid in *; do
    visible[$pid]=1
done

for i in $(seq 2 "$(cat /proc/sys/kernel/pid_max)"); do
    [[ ${visible[$i]} = 1 ]] && continue
    [[ ! -e /proc/$i/status ]] && continue
    [[ $(stat -c %Z /proc/$i) -ge $start ]] && continue

    #  pid is a kernel thread
    [[ $(awk '/Tgid/{ print $2 }' "/proc/${i}/status") != "${i}" ]] && continue

    exe=$(readlink "/proc/$i/exe")
    cmdline=$(tr '\000' ' ' <"/proc/$i/cmdline")
    echo "- hidden $(cat /proc/$i/comm)[${i}] is running ${exe}: ${cmdline}"
done
