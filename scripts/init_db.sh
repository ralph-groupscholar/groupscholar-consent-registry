#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DATABASE_URL:-}" && -z "${PGHOST:-}" ]]; then
  echo "Set DATABASE_URL or PGHOST/PGUSER/PGDATABASE before running." >&2
  exit 1
fi

if [[ -n "${DATABASE_URL:-}" ]]; then
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f schema/consent_registry.sql
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f views/consent_views.sql
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f seed/seed_data.sql
else
  psql -v ON_ERROR_STOP=1 -f schema/consent_registry.sql
  psql -v ON_ERROR_STOP=1 -f views/consent_views.sql
  psql -v ON_ERROR_STOP=1 -f seed/seed_data.sql
fi
