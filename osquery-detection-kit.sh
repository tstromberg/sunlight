#!/bin/bash
# If osquery is installed, see if osquery-detection-kit picks up anything interesting.

if ! type -P osqueryi >/dev/null; then
    echo "skipping, requires osqueryi (INSTALLATION HIGHLY RECOMMENDED)"
    exit 0
fi

if ! type -P curl >/dev/null; then
    echo "skipping, requires curl"
    exit 0
fi


[[ $EUID != 0 ]] && echo "* WARNING: For accurate output, run $0 as uid 0"

tmpdir=$(mktemp -d)
cd "${tmpdir}" || exit 1

url=$(curl -s https://api.github.com/repos/chainguard-dev/osquery-defense-kit/releases/latest | grep -E "browser_download_url.*odk-packs.zip" | cut -d'"' -f4)
curl -q -s -LO -C - "${url}"

unzip -qq odk-packs.zip

for pack in odk-detection-*.conf; do
    echo "- Running ${pack} ..."
    name=$(echo "${pack}" | sed -e s/"odk-detection-"/""/ -e s/"\.conf"//g)
    echo "{ \"packs\": { \"${name}\": \"${pack}\" }}" > osquery.conf
    osqueryi \
        --read_max=4096000000 \
        --config_path=osquery.conf \
        --pack "${name}" \
        2>&1 | grep -v "_events"
done

