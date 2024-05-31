#!/usr/bin/env bash

# This script allows running against a specific lantern-cloud proxy identified by the PFE IP
# It assumes that lantern-cloud is located on the filesystem as a sibling of lantern-desktop

set -euf -o pipefail

PROXY="${1:?please specify the proxy IP}"
TMPDIR="${TMP:-/tmp}/hit_lc_proxy/$PROXY"
OUTFILE="$TMPDIR/proxies.yaml"

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"

echo "Generating config for ${PROXY} in ${OUTFILE}..."
../lantern-cloud/bin/ptool route dump-config --legacy "$PROXY" > "$OUTFILE"

make darwin ffigen && LANTERN_CONFIGDIR=$TMPDIR LANTERN_PROXYALL=true flutter run -d macOS
