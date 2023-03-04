#!/bin/bash
#
# Diagnose tainted kernels, as described by https://docs.kernel.org/admin-guide/tainted-kernels.html

[[ $EUID != 0 ]] && echo "* WARNING: For full output, run $0 as uid 0"

declare -A table=(
    [0]="proprietary module was loaded"
    [1]="module was force loaded"
    [2]="kernel running on an out of specification system"
    [3]="module was force unloaded"
    [4]="processor reported a Machine Check Exception (MCE)"
    [5]="bad page referenced or some unexpected page flags"
    [6]="taint requested by userspace application"
    [7]="kernel died recently, i.e. there was an OOPS or BUG"
    [8]="ACPI table overridden by user"
    [9]="kernel issued warning"
    [10]="staging driver was loaded"
    [11]="workaround for bug in platform firmware applied"
    [12]="externally-built (out-of-tree) module was loaded"
    [13]="unsigned module was loaded"
    [14]="soft lockup occurred"
    [15]="kernel has been live patched"
    [16]="auxiliary taint, defined for and used by distros"
    [17]="kernel was built with the struct randomization plugin"
    [18]="an in-kernel test has been run"
)


taint=$(cat /proc/sys/kernel/tainted)
[[ $taint == 0 ]] && exit

echo "kernel taint value: ${taint}"
for i in $(seq 18); do
    bit=$(($i-1))
    match=$(($taint >> $bit &1))
    [[ $match == 0 ]] && continue
    echo "* matches bit $bit: ${table[$bit]}"
done

echo ""
echo "dmesg:"
dmesg | grep taint
