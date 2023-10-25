#!/bin/bash
# If osquery is installed, see if osquery-detection-kit picks up anything interesting.

if ! type -P osqueryi >/dev/null; then
    echo "skipping, requires osquery (installation recommended)"
    exit 0
fi


[[ $EUID != 0 ]] && echo "* WARNING: For accurate output, run $0 as uid 0"

tmpdir=$(mktemp -d)
if ! type -P git >/dev/null; then
    cp -Rp third_party/osquery-defense-kit/* "${tmpdir}"
else
    git clone --depth 1 --quiet https://github.com/chainguard-dev/osquery-defense-kit.git "${tmpdir}" >/dev/null
fi

cd "${tmpdir}" || exit 1

uname=$(uname)
case "${uname}" in
    Linux)
        ignore_platform="macos|darwin"
        ;;
    Darwin)
        ignore_platform="linux"
    ;;
esac

queries=()

for qfile in detection/*/*.sql; do
    # skip events tables as they require osqueryd
    if grep -q "_events" "${qfile}"; then
        continue
    fi

    if echo "${qfile}" | grep -q -E "${ignore_platform}"; then
        continue
    fi

    if grep -q -E -- "-- platform: .*${ignore_platform}" "${qfile}"; then
        continue
    fi

    queries+=("${qfile}")
done


echo "* Running ${#queries[@]} ${uname} detection queries (this will take a minute)..."
matched=0

for qfile in "${queries[@]}"; do
    (cat "${qfile}"; echo ";") | osqueryi \
            --read_max=4096000000 > out.txt 2>&1

    if [[ -s out.txt ]]; then
        echo "${qfile}"
        echo "==========================================================================================="
        cat out.txt
        matched=1
    fi
done

exit "${matched}"