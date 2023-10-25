#!/bin/bash
#
# Discover weird things in eBPF land

[[ $(uname) != "Linux" ]] && exit 0

if [[ $EUID != 0 ]]; then
  echo "This script requires root"
  exit 1
fi

if type -P tc >/dev/null; then
    clsact=$(sudo tc qdisc | grep clsact)
    if [[ "${clsact}" != "" ]]; then
    echo "* Found interface with network traffic-control filtering enabled (tc qdisc):"
    echo "${clsact}"
    echo ""
    fi
fi


entries=$(sudo find /sys/fs/bpf ! -name ip ! -name xdp ! -name tc ! -name globals ! -name bpf)
if [[ "$entries" != "" ]]; then
  echo "* Found unexpected eBPF filesystem entry:"
  echo "${entries}"
  echo ""
fi

if ! type -P bpftool >/dev/null; then
    echo "exiting early, as the remaining parts require bpftool"
    exit 0
fi

net=$(sudo bpftool net show -p | grep -Ev "^\[|\[\]|}$|\]$")
if [[ "${net}" != "" ]]; then
    echo "* Unexpected eBPF networking attachment found:"
    echo "${net}"
    echo ""
fi

if ! type -P jq >/dev/null; then
    echo "exiting early as the rest requires jq"
    exit 0
fi


progs=$(sudo bpftool prog list --bpffs -p | jq '.[] | select( .pids[0].pid != 1 ) | select( .type != "cgroup_skb" ) | select( .type != "cgroup_device" ) | select (.type != "tracing" )')
if [[ "${progs}" != "" ]]; then
    echo "* Unexpected eBPF program found:"
    echo "${progs}"
    echo ""
fi

maps=$(sudo bpftool map list -p | jq '.[] | select( .pids[0].pid != 1 ) | select ( .pids[0].comm != "bpftool" ) | select ( .name != "libbpf_det_bind" ) | select ( .name != "hid_jmp_table" ) | select ( .name != "libbpf_global" )')
if [[ "${maps}" != "" ]]; then
    echo "* Unexpected eBPF map found:"
    echo "${maps}"
    echo ""
fi

