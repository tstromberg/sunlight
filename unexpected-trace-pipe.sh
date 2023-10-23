#!/bin/bash
#
# Discover kernel modules logging to the trace pipe - may be the sign of an ebpfkit derived rootkit

[[ $(uname) != "Linux" ]] && exit 0

if [[ $EUID != 0 ]]; then
  echo "This script requires root"
  exit 1
fi

pipe="/sys/kernel/debug/tracing/trace_pipe"

if [[ ! -f "${pipe}" ]]; then
  exit 0
fi

# read for one second
tmp=$(mktemp)
cat "${pipe}" > "${tmp}" &
sleep 10
kill %1

if [[ -s "${tmp}" ]]; then
  echo "* Unexpected debug data in ${pipe}"
  cat "${tmp}"
fi