#!/bin/bash
# Uncover mysterious character devices
# Based on https://www.kernel.org/doc/Documentation/admin-guide/devices.txt

declare -A expected_major=(
    [1]="memory"
    [2]="pty master"
    [3]="pty slave"
    [4]="tty"
    [5]="alt tty"
    [6]="parallel"
    [7]="vcs"
    # [8]="scsi tape"
    [9]="md"
    [10]="misc"
    [13]="input"
    [21]="scsi"
    [29]="fb"
    [81]="v4l"
    [180]="usb"
    [90]="memorydev"
    [108]="ppp"
    [116]="alsa"
    [189]="usb serial"
    [202]="msr"
    [203]="cpu"
    [226]="dri"
)

declare -A expected_low=(
    ["bsg/"]=1
    ["dma_heap/system"]=1
    ["gpiochip"]=1
    ["hidraw"]=1
    ["media"]=1
    ["mei"]=1
    ["ngn"]=1
    ["nvme"]=1
    ["rtc"]=1
    ["watchdog"]=1
    ["tpmrm"]=1
)

declare -A expected_high=(
    ["drm_dp_aux"]=1
    ["iiodevice"]=1
)

for path in $(find /dev -type c); do
    hex=$(stat -c '%t' $path)
    major=$(( 16#${hex} ))
    pattern=$(echo $path | cut -d/ -f3- | tr -d '[:0-9]')

    # Unix98 PTY Slaves
    (( major >= 136 && major <= 143 )) && continue
    [[ ${expected_major[$major]} != "" ]] && continue

    class="UNKNOWN"
    (( major >= 60 && major <= 63 )) && class="LOCAL/EXPERIMENTAL"
    (( major >= 120 && major <= 127 )) && class="LOCAL/EXPERIMENTAL"
    if (( major >= 234 && major <= 254 )); then
        class="low dynamic"
        [[ ${expected_low[$pattern]} == 1 ]] && continue
    fi

    if (( major >= 384 && major <= 511 )); then
        class="high dynamic"
        [[ ${expected_high[$pattern]} == 1 ]] && continue
    fi

    echo "${class} major device ${pattern}[${major}]"
    echo "* $(ls -lad $path)"
    echo "* /proc/devices: $(sed -n '/Block devices:/q;p' /proc/devices | grep -e "^ *${major}")"
    echo ""
done
