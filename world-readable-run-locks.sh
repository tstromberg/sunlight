#!/bin/bash
#
# Show world readable locks in /var/run (rare)

find /run/*.lock -perm 644 || exit 0