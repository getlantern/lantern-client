# Runs json-server in the background and prints its PID to stdout
set -eo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Run and write logs to somewhere
# XXX This is important, else the process hangs forever if not run in a TTY
json-server "$SCRIPT_DIR/replica_db.json" \
  --port $1 --routes "$SCRIPT_DIR/replica_routes.json" \
  >> ./json-server.log 2>&1 </dev/null &
# Print pid
echo "$!"
