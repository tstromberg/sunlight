#!/bin/bash
#
# Reveal rootkits and other weird programs.

if [[ $EUID != 0 ]]; then
  echo "* WARNING: For accurate output, run $0 as uid 0"
  echo ""
fi

for program in *.sh
do
  [[ ${program} == "sunlight.sh" ]] && continue
  printf "%-80.80s\n" "-- [ ${program} ] -------------------------------------------------------------"
  ./${program}
  echo ""
done
