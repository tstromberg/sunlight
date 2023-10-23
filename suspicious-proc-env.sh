#!/bin/bash
#
# Find processes who have unusual environment variables

[[ $(uname) != "Linux" ]] && exit 0

if [[ $EUID != 0 ]]; then
  echo "* WARNING: For accurate output, run $0 as uid 0"
  echo ""
fi

cd /proc || exit

for i in *; do
  [[ ! -f $i/environ || $i =~ "self" ]] && continue

    matches=$(xargs -0 -L1 -a "/proc/${i}/environ" 2>/dev/null | grep -E "LD_LIBRARY_PATH|LD_PRELOAD|HISTCONTROL|HISTFILE" | grep -v _history)
    if [[ "${matches}" = "" ]]; then
        continue
    fi

    echo "- $(cat "/proc/${i}/comm")[${i}] has suspicious environment variables set:"
    echo "${matches}"
    echo ""
done
