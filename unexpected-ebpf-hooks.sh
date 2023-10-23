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

if ! type -P bpftool >/dev/null; then
    echo "exiting early as the rest requires bpftool"
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


progs=$(sudo bpftool prog list --bpffs -p | jq '.[] | select( .pids[0].pid != 1 ) | select( .type != "cgroup_skb" ) | select( .type != "cgroup_device" )')
if [[ "${progs}" != "" ]]; then
    echo "* Unexpected eBPF program found:"
    echo "${progs}"
    echo ""
fi

maps=$(sudo bpftool map list -p | jq '.[] | select( .pids[0].pid != 1 ) | select ( .pids[0].comm != "bpftool" ) | select ( .name != "libbpf_det_bind" )')
if [[ "${maps}" != "" ]]; then
    echo "* Unexpected eBPF map found:"
    echo "${maps}"
    echo ""
fi

