#!/bin/bash
#
# Reveal processes that are powered by deleted programs

[[ $(uname) != "Linux" ]] && exit 0
ls -la /proc/*/exe 2>/dev/null | grep '(deleted)' || exit 0
