# sunlight

[![Actions Status](https://github.com/tstromberg/sunlight/workflows/verify/badge.svg)](https://github.com/tstromberg/sunlight/actions)
[![Latest Release](https://img.shields.io/github/v/release/tstromberg/sunlight?include_prereleases)](https://github.com/tstromberg/sunlight/releases/latest)
[![stable](https://badges.github.io/stability-badges/dist/stable.svg)](https://github.com/badges/stability-badges)

Shell scripts that reveal rootkits and other weird processes

## Requirements

* A UNIX-like operating system (best tested with Linux)
* bash

## Usage

To run all of the scripts:

```shell
sudo ./sunlight.sh
```

To run a single script:

```shell
./mystery-char-device.sh
```

## Example output

This shows the output when run on a Debian VM with [reveng_rtkit](https://github.com/reveng007/reveng_rtkit) installed:

```log
-- [ deleted-or-replaced.sh ] --------------------------------------------------
lrwxrwxrwx 1 root root 0 Mar  3 19:42 /proc/1216/exe -> /usr/local/bin/lima-guestagent (deleted)

-- [ fake-name.sh ] ------------------------------------------------------------

-- [ hidden-parent-pid.sh ] ----------------------------------------------------

-- [ hidden-pids.sh ] ----------------------------------------------------------

-- [ kernel-taint.sh ] ---------------------------------------------------------
kernel taint value: 12288
* matches bit 12: externally-built (out-of-tree) module was loaded
* matches bit 13: unsigned module was loaded

dmesg:
[  368.765518] reveng_rtkit: loading out-of-tree module taints kernel.
[  368.777600] reveng_rtkit: module verification failed: signature and/or required key missing - tainting kernel

-- [ mystery-char-devices.sh ] -------------------------------------------------
low dynamic major device etx_device[247]
* crw------- 1 root root 247, 0 Mar  3 19:48 /dev/etx_device
* /proc/devices: 247 etx_Dev


-- [ osquery-detection-kit.sh ] ------------------------------------------------
skipping, requires osqueryi

-- [ thieves.sh ] -------------------------------------------------------------
```
