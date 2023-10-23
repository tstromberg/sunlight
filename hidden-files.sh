#!/bin/bash
#
# Reveal hidden files

[[ $EUID != 0 ]] && echo "* WARNING: For accurate output, run $0 as uid 0"

sudo find /var /tmp /etc /usr /lib /lib64 /boot /dev/shm /dev/mqueue -maxdepth 2 -name ".*" \
    \! -name ".bash_profile" \
    \! -name ".build-id" \
    \! -name ".com.google.Chrome.*" \
    \! -name ".config" \
    \! -name ".git" \
    \! -name ".github" \
    \! -name ".gitignore" \
    \! -name ".resolv.conf.systemd-resolved.bak" \
    \! -name .ICE-unix \
    \! -name .X11-unix \
    \! -name .XIM-unix \
    \! -name .Test-unix \
    \! -name .bash_logout \
    \! -name .bashrc \
    \! -name .cleanup.user \
    \! -name .font-unix \
    \! -name .placeholder \
    \! -name .profile \
    \! -name .pwd.lock \
    \! -name .updated \
    \! -name .GlobalPreferences.plist \
    \! -name .localized \
    \! -name .file \
    \! -name .staging \
    \! -name .metadata_never_index \
    \! -name .DS_Store \
    \! -name .PKInstallSandboxManager \
    \! -path "/Library/Keychains/.*" \
    \! -name ".*.hmac" \
    \! -name ".ssh-host-keys-migration" \
    -ls 2>/dev/null
