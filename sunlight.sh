#!/bin/bash
#
# Reveal rootkits and other weird programs.

if [[ $EUID != 0 ]]; then
  echo "* WARNING: For accurate output, run $0 as uid 0"
  echo ""
fi

failures=""
for program in *.sh
do
  [[ ${program} == "sunlight.sh" ]] && continue
  printf "%-80.80s\n" "-- [ ${program} ] -------------------------------------------------------------"
  ./${program} || { e=$?; echo "failed with $e"; failures="${failures} ${program}"; }
  echo ""
done


if [[ "${failures}" != "" ]]; then
  echo ""
  echo "** failed scripts: ${failures}"
  exit 1;
fi
