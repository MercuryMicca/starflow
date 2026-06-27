#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."

app_pid=""

cleanup() {
  status="$?"
  trap - INT TERM HUP EXIT

  if [ -n "$app_pid" ] && kill -0 "$app_pid" 2>/dev/null; then
    kill "$app_pid" 2>/dev/null || true
    wait "$app_pid" 2>/dev/null || true
  fi

  ./scripts/dev-db.sh stop postgres >/dev/null 2>&1 || true
  exit "$status"
}

trap cleanup INT TERM HUP EXIT

./scripts/db-migrate.sh
./scripts/local-env.sh exec -- bun run dev &
app_pid="$!"
wait "$app_pid"
