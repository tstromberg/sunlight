#!/bin/bash
#
# Reveal rootkits and other weird programs.

if [[ $EUID != 0 ]]; then
  echo "* WARNING: For accurate output, run $0 as uid 0"
  echo ""
fi

programs="deleted-or-replaced fake-name hidden-parent-pid hidden-pids thieves"

for program in $programs
do
  echo "-- [ ${program} ] -----------------------------------------------"
  ./${program}.sh
  echo ""
done