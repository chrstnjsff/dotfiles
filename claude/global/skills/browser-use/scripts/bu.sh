#!/usr/bin/env bash
set -euo pipefail

PORT=9333
export BU_NAME=e2e-test BU_CDP_URL="http://127.0.0.1:$PORT"
export BH_TELEMETRY=0 ANONYMIZED_TELEMETRY=false BH_UPDATE_CHECK=0 BH_TAB_MARKER=0

PROFILE="$HOME/.cache/e2e-test-chrome"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

is_up() { curl -sf "http://127.0.0.1:$PORT/json/version" >/dev/null; }

if ! is_up; then
  flags=(--remote-debugging-port="$PORT" --user-data-dir="$PROFILE" --no-first-run --no-default-browser-check --window-size=1440,900)
  [[ "${HEADED:-0}" == 1 ]] || flags+=(--headless=new)
  nohup "$CHROME" "${flags[@]}" about:blank >/dev/null 2>&1 &
  for _ in $(seq 1 50); do
    is_up && break
    sleep 0.2
  done
  is_up || { echo "test Chrome did not start on port $PORT" >&2; exit 1; }
fi

exec browser-use "$@"
