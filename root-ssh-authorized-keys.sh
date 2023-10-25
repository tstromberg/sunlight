#!/bin/bash
#
# Find root SSH authorized keys

if [[ $EUID != 0 ]]; then
  echo "This script requires root"
  exit 1
fi

root_ssh=~root/.ssh/authorized_keys

if [[ ! -s "${root_ssh}" ]]; then
  exit 0
fi

echo "root ssh keys found:"
echo "--------------------"
stat $root_ssh
echo ""
cat $root_ssh
exit 1