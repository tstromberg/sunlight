#!/bin/bash
# Reveal suspicious crontab entries

[[ $(uname) != "Linux" ]] && exit 0

re='curl|@reboot|/\.[a-zA-Z0-9]|kthread|wget|/dev/shm|/dev/mqueue|/usr/share|/lib64|/tmp|\| bash|\| sh'

crontab -l | grep -E "${re}"
find /etc/cron* /var/cron* -type f -exec grep -EH "${re}" {} \; 2>/dev/null
