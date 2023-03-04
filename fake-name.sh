#!/bin/bash
#
# Uncover unexpected programs that are faking their name

declare -A expected=(
    ["/bin/bash"]=1
    ["/bin/dash"]=1
    ["/usr/bin/bash"]=1
    ["/usr/bin/perl"]=1
    ["/usr/bin/udevadm"]=1
    ["/usr/lib/electron##/electron"]=1
    ["/usr/lib/firefox/firefox"]=1
    ["/usr/lib/systemd/systemd"]=1
    ["/usr/local/bin/rootlesskit"]=1
    ["/usr/bin/python#.#"]=1
)

cd /proc || exit 1
for i in *; do
  [[ ! -f $i/exe || $i =~ "self" ]] && continue

  path=$(readlink $i/exe)
  base=$(basename $path)
  name=$(cat $i/comm)
  short_name=$(echo $name | cut -d- -f1 | cut -d: -f1 | cut -d" " -f1)
  short_base=$(echo $base | cut -c1-5)

  [[ "${path}" =~ "${short_name}" || "${name}" =~ "${short_base}" ]] && continue

  pattern=$(echo $path | tr '[0-9]' '#')
  [[ ${expected[$pattern]} == 1 ]] && continue
  printf "%8.8s %16.16s %s %s\n" $i "${name}" "${path}"
done
