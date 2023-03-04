#!/bin/bash
#
# Reveal if there is a hidden /sys/module entry

hard_links=$(stat -c '%h' /sys/module)
visible_entries=$(ls -d /sys/module/* | wc -l)
hidden_count=$(( $hard_links - ${visible_entries} - 2 ))

if [[ "${hidden_count}" -gt 0 ]]; then
    echo "DANGER: /sys/modules appears to have ${hidden_count} entries"
fi
