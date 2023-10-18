#!/bin/bash
#
# Detect rootkits, such as Diamorphine, that respond to exotic signals
set -u

# Currently Linux only because we don't look up kernel modules in the correct place
[[ $(uname) != "Linux" ]] && exit 0

if [[ $EUID == 0 ]]; then
  echo "NOTE: root-escalation detection requires a non-root user"
fi


for sig in $(seq 0 64); do
    trap "" "${sig}"
done


# rotate through all signals twice
pattern="$(seq 0 64) $(seq 0 64)"

for sig in $pattern; do
    old_proc=$(ls -1 /proc/ | grep -E "^$$\$")
    old_id=$(id)

    old_mods="$(mktemp)"
    awk '{print $1 }' < /proc/modules | sort > "${old_mods}"
    # allow writes to continue if EUID changes
    chmod 666 "${old_mods}"

    # skip the following untrappable signals
    case $sig in
        9|19|32|33)
            continue
        ;;
    esac

    # echo "Sending $sig to $$"
    kill "-${sig}" $$ || true

    new_proc=$(ls -1 /proc/ | grep -E "^$$\$")
    if [[ "${new_proc}" == "" && "${old_proc}" != "" ]]; then 
       echo "- SIGNAL $sig made /proc/$$ (this process) invisible!"
    fi

    if [[ "${new_proc}" != "" && "${old_proc}" == "" ]]; then 
       echo "- SIGNAL $sig made /proc/$$ (this process) visible again!"
    fi

    new_id=$(id)
    if [[ "${new_id}" != "${old_id}" ]]; then
        echo "- SIGNAL $sig changed my id from \"${old_id}\" to \"${new_id}\""
    fi

    new_mods="$(mktemp)"
    awk '{print $1 }' < /proc/modules | sort > "${new_mods}"
    chmod 666 "${new_mods}"

    diff=$(diff -ubB "${old_mods}" "${new_mods}")
    if [[ "${diff}" != "" ]]; then
        echo "- SIGNAL $sig caused /proc/modules to change:"
        echo "${diff}"
    fi

    rm -f "${old_mods}"
    rm -f "${new_mods}"
done
