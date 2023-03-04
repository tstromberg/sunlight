#!/bin/bash
#
# If osquery is installed, see if osquery-detection-kit picks up anything interesting.

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
url=$(curl -s https://api.github.com/repos/chainguard-dev/osquery-defense-kit/releases/latest | grep -E 'browser_download_url.*odk-detection.conf' | cut -d'"' -f4)
curl -s -LO -C - ${url}

cat > osquery.conf <<EOF
{
  // Configure the daemon below:
  "packs": {
    "detection": "odk-detection.conf"
  }
}
EOF

osqueryi \
    --read_max=4096000000 \
    --config_path=osquery.conf \
    --pack detection \
    2>&1 | grep -v "_events"
