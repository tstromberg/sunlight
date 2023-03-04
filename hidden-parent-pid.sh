#!/bin/bash
#
# Find processes who have hidden parent IDs

[[ $(uname) != "Linux" ]] && exit 0

cd /proc || exit

for i in *; do
  [[ ! -f $i/exe || $i =~ "self" ]] && continue

  parent=$(awk '/^PPid:/{ print $2 }' "/proc/${i}/status")
  [[ "${parent}" == 0 ]] && continue

  if [[ ! -e "/proc/${parent}/comm" ]]; then
    echo "${i} has a hidden parent pid: ${parent}"
  fi
done
