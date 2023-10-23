#!/bin/bash
#
# Reveal processes that are powered by deleted programs

[[ $(uname) != "Linux" ]] && exit 0
matches=$(ls -la /proc/*/exe 2>/dev/null \
  | grep '(deleted)' \
  | grep -v "/usr/local/bin/lima-guestagent (deleted)")

if [[ "${matches}" != "" ]]; then
    echo "${matches}"
    exit 1
fi
exit 0

