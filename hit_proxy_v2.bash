#!/usr/bin/env bash

set -ef -o pipefail

usage() {
	cat <<EOF
Usage: $0 [options] [proxy_ip]

A script to run the Lantern client against a specific proxy,
fetched dynamically based on track, provider, or protocol.

Options:
  -T, --track <track>        Fetch proxy config for a specific track.
  -p, --protocol <protocol>  Fetch proxy config for a specific protocol. Ignored if --track is provided.
  -P, --provider <provider>  Filter proxies by a specific provider.

      --proxyless            Enable proxyless transport.
      --no-build             Do not rebuild lantern-client before running.
      --force-refresh        Force download of a new proxy list, ignoring cache.
      --help                 Display this help message.

Details:
- If a [proxy_ip] is provided, it is used directly and all other flags for proxy selection (--track, --provider, --protocol) are ignored.
- If no [proxy_ip] is provided, --track, --provider, or --protocol must be used to find a proxy.
EOF
	exit 1
}

error() {
	echo "$1" >&2
	exit 1
}

# --- Argument Parsing ---
TRACK=""
PROVIDER=""
PROTOCOL=""
BUILD=true
FORCE_REFRESH=false
USE_PROXYLESS=false
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
	case $1 in
	-T | --track)
		TRACK="$2"
		shift 2
		;;
	-P | --provider)
		PROVIDER="$2"
		shift 2
		;;
	-p | --protocol)
		PROTOCOL="$2"
		shift 2
		;;
	--proxyless)
		USE_PROXYLESS=true
		shift
		;;
	--no-build)
		BUILD=false
		shift
		;;
	--force-refresh)
		FORCE_REFRESH=true
		shift
		;;
	--help)
		usage
		;;
	-*)
		echo "Unknown option: $1"
		usage
		;;
	*)
		POSITIONAL_ARGS+=("$1")
		shift
		;;
	esac
done

# --- Argument Validation ---
if [[ -z "$TRACK" && -z "$PROVIDER" && -z "$PROTOCOL" && ${#POSITIONAL_ARGS[@]} -eq 0 ]]; then
	usage
fi

LANTERN_CLOUD="${LANTERN_CLOUD:-../lantern-cloud}"
PROXY=""

fetch_proxies() {
	local args=("${@:1:$(($# - 1))}") # All but last arg
	local outfile="${!#}"             # Last arg
	local route_list

	if [ -f "$outfile" ]; then
		if $FORCE_REFRESH; then
			echo "Forcing refresh of cached proxies..." >&2
			rm "$outfile"
		elif [ "$(find "$outfile" -mtime +1)" ]; then
			echo "Cached proxies are older than 1 hour. Refreshing..." >&2
			rm "$outfile"
		else
			echo "Using cached proxies from $outfile" >&2
			route_list=$(cat "$outfile")
		fi
	fi
	if [[ -z "$route_list" ]]; then
		route_list=$($LANTERN_CLOUD/bin/lc routes list "${args[@]}" 2>&1)
		if [[ $? -ne 0 ]]; then
			if grep -qv "no routes" <<<"$route_list"; then
				error "Failed to fetch proxies: $route_list"
			fi
			route_list=""
		else
			route_list=$(echo "$route_list" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' || true)
			echo "$route_list" >"$outfile"
		fi
	fi
	echo "$route_list"
}

# --- Main Logic ---
TMPDIR="${TMP:-/tmp}/hit_lc_proxy"
mkdir -p "$TMPDIR"

if [[ ${#POSITIONAL_ARGS[@]} -eq 1 ]]; then
	PROXY="${POSITIONAL_ARGS[0]}"
	echo "Using specified proxy IP: "$PROXY""
else
	if ! command -v shuf &>/dev/null; then
		error "'shuf' command not found. Please install GNU coreutils."
	fi

	ROUTE_LIST=""
	# --protocol
	if [[ -n "$PROTOCOL" && -z "$TRACK" ]]; then
		echo "Fetching tracks for protocol: "$PROTOCOL""
		TRACKS_TABLE=$($LANTERN_CLOUD/bin/lc tracks list --columns name,providers --filter-protocol "$PROTOCOL" || echo "")
		if [[ $? -ne 0 ]]; then
			error "Could not fetch tracks for protocol '$PROTOCOL'. Check your connection or if the protocol exists."
		fi

		if [[ -n "$PROVIDER" ]]; then
			TRACKS=$(echo "$TRACKS_TABLE" | tail -n +2 | grep -i "$PROVIDER" | awk '{print $1}' || true)
		else
			TRACKS=$(echo "$TRACKS_TABLE" | tail -n +2 | awk 'NR>2{print a[NR%3]} {a[NR%3]=$1}')
		fi

		if [ -z "$TRACKS" ]; then
			error "No tracks found for protocol '$PROTOCOL' with provider '$PROVIDER'."
		fi

		for track in $(echo "$TRACKS" | shuf); do
			echo "Attempting to fetch proxies for track: "$track""
			OUTFILE="$TMPDIR/${track}_all_proxies.txt"
			ROUTE_LIST=$(fetch_proxies --track "$track" "$OUTFILE")
			if [[ -n "$ROUTE_LIST" ]]; then
				echo "Found proxies for track: "$track""
				break
			fi
			echo "No routes for "$track".."
		done
	# --track and/or --provider
	else
		LC_ARGS=()
		CACHE_KEY="proxies"
		if [[ -n "$TRACK" ]]; then
			LC_ARGS+=(--track "$TRACK")
			CACHE_KEY="${TRACK}"
		fi
		if [[ -n "$PROVIDER" ]]; then
			LC_ARGS+=(--provider "$PROVIDER")
			CACHE_KEY="${CACHE_KEY}_${PROVIDER}"
		fi
		OUTFILE="$TMPDIR/${CACHE_KEY}_all_proxies.txt"

		echo "Fetching all proxies for "${LC_ARGS[*]}""
		ROUTE_LIST=$(fetch_proxies "${LC_ARGS[@]}" "$OUTFILE")
	fi

	if [[ -z "$ROUTE_LIST" ]]; then
		error "No proxies found. Please check your configuration or network connection."
	fi

	PROXY=$(echo "$ROUTE_LIST" | sort -R | head -n 1 | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' || true)
	if [ -z "$PROXY" ]; then
		error "Could not find a valid proxy IP in the fetched list."
	fi
	echo "Selected random proxy: $PROXY"
fi

# --- Execution ---
if [ -z "$PROXY" ]; then
	error "Could not determine a proxy to use."
fi

PROXY_TMP_DIR="${TMP:-/tmp}/hit_lc_proxy/$PROXY"
OUTFILE="$PROXY_TMP_DIR/user.conf"

rm -rf "$PROXY_TMP_DIR"
mkdir -p "$PROXY_TMP_DIR"

echo "Generating config for ${PROXY} in ${OUTFILE}..."
CONFIG=$($LANTERN_CLOUD/bin/lc route dump-config "$PROXY")
# wrap the proxy config to match the format expected by flashlight.
# [ConfigResponse (getlantern/flashlight/apipb/types.proto)]
OUTPUT="{\"country\": \"US\",\"proxy\":{\"proxies\":[${CONFIG}]}}"

if command -v jq &>/dev/null; then
	echo "$OUTPUT" | jq . >"$OUTFILE"
else
	echo "$OUTPUT" >"$OUTFILE"
fi

if [ "$(uname)" == "Linux" ]; then
	if $BUILD; then
		make linux-amd64
	fi
	CMD="flutter run"
else
	if $BUILD; then
		make macos ffigen
	fi
	CMD="flutter run -d macOS"
fi

PROXYLESS=$USE_PROXYLESS CONFIG_DIR=$PROXY_TMP_DIR READABLE_CONFIG=true STICKY_CONFIG=true $CMD
