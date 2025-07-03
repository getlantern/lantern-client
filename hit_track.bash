#!/usr/bin/env bash

LANTERN_CLOUD=$([[ ! -z "$LANTERN_CLOUD" ]] && echo "$LANTERN_CLOUD" || echo "../lantern-cloud")

set -ef -o pipefail

echo "Fetching all proxies for "$@""

# First check for all proxies in a temporary directory from a prior run, and use them
# if they exist. If not, fetch them from the lantern-cloud.
TMPDIR="${TMP:-/tmp}/hit_lc_proxy"
mkdir -p "$TMPDIR"
OUTFILE="$TMPDIR/all_proxies.txt"
if [ -f "$OUTFILE" ]; then
  echo "Using cached proxies from $OUTFILE"
  ALLPROXIES=$(cat "$OUTFILE")
else
  echo "No cached proxies found. Fetching from lantern-cloud..."
  $LANTERN_CLOUD/bin/lc routes list -T "$@" > "$OUTFILE"
  ALLPROXIES=$(cat "$OUTFILE")
fi

if [ -z "$ALLPROXIES" ]; then
  echo "No proxies found. Please check your configuration or network connection."
  exit 1
fi

# Check if shuf is available and tell the user to install it with OS-specific instructions if not.
if ! command -v shuf &> /dev/null; then
  echo "shuf command not found. Please install coreutils (Linux) or use brew install coreutils (macOS)."
  exit 1
fi

# The proxies will be in the format: "routeId track IP", and we want to choose 
# a random IP from the list.
PROXYLINE=$(echo "$ALLPROXIES" | tail -n +2 | sort -R | tail -n 1)
if [ -z "$PROXYLINE" ]; then
  echo "No valid proxy line found. Please check your configuration."
  exit 1
fi
PROXY=$(echo "$PROXYLINE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
if [ -z "$PROXY" ]; then
  echo "No valid proxy IP extracted from the selected line."
  exit 1
fi

echo "Running lantern-client with the selected proxy IP: $PROXY"
./hit_proxy.bash "$PROXY"

