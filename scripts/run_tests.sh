#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DATABASE_URL:-}" && -z "${PGHOST:-}" ]]; then
  echo "Set DATABASE_URL or PGHOST/PGUSER/PGDATABASE before running." >&2
  exit 1
fi

if [[ -n "${DATABASE_URL:-}" ]]; then
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f tests/consent_registry_test.sql
else
  psql -v ON_ERROR_STOP=1 -f tests/consent_registry_test.sql
fi
