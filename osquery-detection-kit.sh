#!/bin/bash
# If osquery is installed, see if osquery-detection-kit picks up anything interesting.
#
# NOTE: event-based queries won't work under osqueryi (interactive). For fuller
# detection use osquery-detection-kit paired with osqueryd (daemon).

if ! type -P osqueryi >/dev/null; then
    echo "skipping, requires osqueryi"
    exit 0
fi

if ! type -P curl >/dev/null; then
    echo "skipping, requires curl"
    exit 0
fi


[[ $EUID != 0 ]] && echo "* WARNING: For accurate output, run $0 as uid 0"

tmpdir=$(mktemp -d)
cd $tmpdir || exit 1

for file in osquery.conf odk-detection.conf; do
  url=$(curl -s https://api.github.com/repos/chainguard-dev/osquery-defense-kit/releases/latest | grep -E "browser_download_url.*${file}" | cut -d'"' -f4)
  curl -s -LO -C - "${url}"
done

osqueryi \
    --read_max=4096000000 \
    --config_path=osquery.conf \
    --pack detection \
    2>&1 | grep -Ev "_events|Error reading the query pack" || exit 0
