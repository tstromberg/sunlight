#!/bin/bash
cd /proc
for i in *; do
  [[ ! -f $i/exe || $i =~ "self" ]] && continue

  path=$(readlink $i/exe)
  base=$(basename $path)
  name=$(cat $i/comm)
  short_name=$(echo $name | cut -d- -f1 | cut -d: -f1 | cut -d" " -f1)
  short_base=$(echo $base | cut -c1-5)

  [[ "${path}" =~ "${short_name}" || "${name}" =~ "${short_base}" ]] && continue

  printf "%8.8s %16.16s %s\n" $i "${name}" "${path}"
done
