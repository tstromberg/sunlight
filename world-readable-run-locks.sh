#!/bin/bash
#
# Show world readable locks in /var/run (rare)

[[ $(uname) != "Linux" ]] && exit 0

find /run/*.lock -perm 644 2>/dev/null || exit 0