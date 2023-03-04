#!/bin/bash
# Reveal programs whose process space may have been taken over by another program

[[ $(uname) != "Linux" ]] && exit 0

cd /proc
for i in *; do
  if [[ ! -f $i/exe || $i =~ "self" || $i == $$ ]]; then
    continue
  fi

  path=$(readlink $i/exe)
  name=$(cat $i/comm)
  cmdline=$(/bin/cat -v $i/cmdline)
  init=$(grep "r--p 00000000" /proc/$i/maps | head -n1)

  if [[ ${init} == "" || ${init} =~ "[vvar]" || ${init} =~ ${path} ]]; then
    continue
  fi

  dev=$(echo $init | cut -d" " -f4)
  inode=$(echo $init | cut -d" " -f5)

  if [[ "${dev}" != "00:00" ]]; then
    continue
  fi

  if [[ "${inode}" != 0 ]]; then
    continue
  fi

  # We either have to check against an early adddress (like ddexec uses), or
  # Whitelist sandboxed webkit/chromium based applications, because their memory map similarly shows
  # a blank section before the real one.
  segment=$(echo $init | cut -c1)
  if [[ $segment == 0 ]]; then
    echo $i : $init : $name
  fi
done

