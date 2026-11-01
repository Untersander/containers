#!/usr/bin/env bash
# Starts the app and waits for HTTP 200 on the given port, for the test target in the bake files.
# It runs as a build step because the runner has no Docker, so a broken app fails before the push.

port="$1"
log=/tmp/startup.log

# Build steps also share a network: an answer from another app would pass this test
if curl -s -m 2 -o /dev/null "http://localhost:${port}/"; then
  echo "Port ${port} is already in use on the builder"
  exit 1
fi

/entrypoint.sh > "$log" 2>&1 &
app=$!
# Build steps share buildkitd's PID namespace, the app would outlive this step or stay as a zombie
trap 'kill -9 "$app" 2>/dev/null; wait "$app" 2>/dev/null' EXIT

for _ in {1..60}; do
  if ! kill -0 "$app" 2>/dev/null; then
    echo "App exited before answering on port ${port}:"
    cat "$log"
    exit 1
  fi
  status=$(curl -sL -m 2 -o /dev/null -w '%{http_code}' "http://localhost:${port}/")
  if [[ "$status" == 200 ]]; then
    echo "App answered on port ${port}"
    exit 0
  fi
  sleep 1
done

echo "No HTTP 200 on port ${port} after 60 tries, last status ${status}:"
tail -n 50 "$log"
exit 1
