#!/usr/bin/env bash

# This script allows running against a specific lantern-cloud proxy identified by the PFE IP
# Assume lantern-cloud is a sibling of lantern-client unless told otherwise.
LANTERN_CLOUD=$([[ ! -z "$LANTERN_CLOUD" ]] && echo "$LANTERN_CLOUD" || echo "../lantern-cloud")

set -ef -o pipefail

PROXY="${1:?please specify the proxy IP}"
TMPDIR="${TMP:-/tmp}/hit_lc_proxy/$PROXY"
OUTFILE="$TMPDIR/user.conf"

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"

echo "Generating config for ${PROXY} in ${OUTFILE}..."
CONFIG=$($LANTERN_CLOUD/bin/lc route dump-config $PROXY)
OUTPUT="{\"proxy\":{\"proxies\":[${CONFIG}]}}"

# check if jq is installed and reformat the output
if command -v jq &> /dev/null
then
	echo $OUTPUT | jq . > $OUTFILE
else
	echo $OUTPUT > $OUTFILE
fi

make darwin ffigen
LANTERN_CONFIGDIR=$TMPDIR \
LANTERN_STICKYCONFIG=true \
LANTERN_READABLECONFIG=true \
LANTERN_PROXYALL=true \
LANTERN_STARTUP=false \
flutter run -d macOS
