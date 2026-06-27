#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."

./scripts/dev-db.sh up -d postgres

for _ in $(seq 1 40); do
  if ./scripts/dev-db.sh exec -T postgres sh -c 'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"' >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

./scripts/dev-db.sh exec -T postgres sh -c '
  set -eu
  for migration in /migrations/*.sql; do
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$migration"
  done
'
