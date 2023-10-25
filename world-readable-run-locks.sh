#!/bin/bash
#
# Show world readable locks in /var/run (rare)

[[ $(uname) != "Linux" ]] && exit 0

find /run/*.lock -perm 644 || exit 0