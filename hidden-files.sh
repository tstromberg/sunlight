#!/bin/bash
#
# Reveal hidden files

[[ $EUID != 0 ]] && echo "* WARNING: For accurate output, run $0 as uid 0"

dirs="/var /tmp /etc /usr /lib /lib64 /boot /dev/shm /dev/mqueue /Library"

matched=0
for dir in ${dirs}; do
    if [[ -e "${dir}" ]]; then
        sudo find "${dir}/" -maxdepth 2 -name ".*" \
            \! -name ".*.hmac" \
            \! -name ".bash_profile" \
            \! -name ".build-id" \
            \! -name ".com.google.Chrome.*" \
            \! -name ".config" \
            \! -name ".git" \
            \! -name ".dwz" \
            \! -name ".github" \
            \! -name ".gitignore" \
            \! -name ".resolv.conf.systemd-resolved.bak" \
            \! -name ".ssh-host-keys-migration" \
            \! -name .AppleCustomMac \
            \! -name .AppleDiagnosticsSetupDone \
            \! -name .AppleSetupDone \
            \! -name .CFUserTextEncoding \
            \! -name .DS_Store \
            \! -name .GKRearmTimer \
            \! -name .GlobalPreferences.plist \
            \! -name .ICE-unix \
            \! -name .LastGKReject \
            \! -name .MASManifest \
            \! -name .PKInstallSandboxManager \
            \! -name .RunLanguageChooserToo \
            \! -name .SystemPolicy-default \
            \! -name .Test-unix \
            \! -name .X11-unix \
            \! -name .XIM-unix \
            \! -name .bash_logout \
            \! -name .bashrc \
            \! -name .cleanup.user \
            \! -name .configureLocalKDC \
            \! -name .file \
            \! -name .font-unix \
            \! -name .keystone_install_lock \
            \! -name .keystone_system_install_lock \
            \! -name .localized \
            \! -name .metadata_never_index \
            \! -name .placeholder \
            \! -name .profile \
            \! -name .pwd.lock \
            \! -name .sim_diagnosticd_socket \
            \! -name .staging \
            \! -name .updated \
            \! -path "/Library//Keychains/.*" \
            \! -path "/Library/Keychains/.*" \
            \! -path "/var//root/.*" \
            \! -path "/var/root/.*" \
            \! -path /var/root \
            -ls 2>/dev/null || matched=1
    fi
done

exit "${matched}"
