#!/bin/bash
#
# Reveal processes running as root with a socket but no dependencies outside of libc

[[ $(uname) != "Linux" ]] && exit 0

declare -A false_positive=(
    ["/usr/bin/containerd"]=1
    ["/usr/bin/fusermount3"]=1
    ["/usr/sbin/acpid"]=1
    ["/usr/sbin/mcelog"]=1
    ["/usr/bin/docker-proxy"]=1
)

if [[ $EUID != 0 ]]; then
  echo "This script requires root"
  exit 1
fi

cd /proc || exit

for pid in *; do
    [[ ! -f ${pid}/exe || ${pid} =~ "self" ]] && continue

    euid=$(grep Uid /proc/${pid}/status | awk '{ print $2 }')
    [[ "${euid}" != 0 ]] && continue

    sockets=$(find /proc/${pid}/fd -lname "socket:*" | wc -l)
    [[ "${sockets}" == 0 ]] && continue

    libs=$(find /proc/${pid}/map_files/ -type l -lname "*.so.*" -exec readlink {} \; | sort -u | wc -l)
    [[ "${libs}" != 2 ]] && continue

    path=$(readlink /proc/$pid/exe)

    [[ ${false_positive[$path]} == 1 ]] && continue
    [[ "${path}" == "/usr/sbin/agetty" ]] && continue

    name=$(cat /proc/$pid/comm)
    echo "found euid=0 process with sockets but no libraries: ${name} [${pid}] at ${path}"
done
