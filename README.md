# Group Scholar Consent Registry

A Postgres-backed consent tracking schema for Group Scholar communications, fundraising, and research workflows. It captures scholar consent events across channels and purposes, provides auditability, and exposes reporting views for operations.

## Features
- Normalized consent events with channels, purposes, status, and expiration
- Audit trail for consent changes and document references
- Reporting views for latest consent state, active consent, and scholar summaries
- Seed data for realistic initial reporting
- SQL-based tests to validate core integrity expectations

## Tech
- SQL (PostgreSQL)

## Getting Started

### Prerequisites
- `psql` available in your shell
- A Postgres connection set via `DATABASE_URL` or `PGHOST/PGUSER/PGDATABASE`

### Initialize Schema + Views + Seed Data
```bash
scripts/init_db.sh
```

### Run Tests
```bash
scripts/run_tests.sh
```

## Project Structure
- `schema/consent_registry.sql`: schema + tables + indexes
- `views/consent_views.sql`: reporting views
- `seed/seed_data.sql`: sample data
- `tests/consent_registry_test.sql`: integrity tests
- `scripts/`: helper scripts

## Notes
- Use a dedicated schema (`groupscholar_consent_registry`) to avoid table collisions.
- Store production credentials in environment variables, never in source control.
