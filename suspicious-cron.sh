#!/bin/bash
# Reveal suspicious crontab entries

[[ $(uname) != "Linux" ]] && exit 0

# cron-free system
if ! type -P crontab >/dev/null; then
    exit 0
fi

re='curl|@reboot|/\.[a-zA-Z0-9]|kthread|wget|/dev/shm|/dev/mqueue|/usr/share|/lib64|/tmp|\| bash|\| sh'

crontab -l | grep -E "${re}" 2>/dev/null
find /etc/cron* /var/cron* -type f -exec grep -EH "${re}" {} \; 2>/dev/null

exit 0
