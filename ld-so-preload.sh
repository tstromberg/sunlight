#!/bin/bash
#
# Find preload entries

[[ $(uname) != "Linux" ]] && exit 0

if [[ ! -f /etc/ld.so.preload ]]; then
    exit 0;
fi

echo "* Discovered usermode rootkit:"
stat /etc/ld.so.preload
echo ""
echo "Contents:"
echo "---------"
cat /etc/ld.so.preload
echo ""
echo "Referenced libraries:"
echo "---------------------"
for path in $(cat /etc/ld.so.preload); do
  stat "${path}"
  echo ""
  strings "${path}" | grep -Ev "^\.|@GLIBC"
done
