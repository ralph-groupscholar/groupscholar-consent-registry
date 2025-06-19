-- Schema: groupscholar_consent_registry
CREATE SCHEMA IF NOT EXISTS groupscholar_consent_registry;
SET search_path TO groupscholar_consent_registry;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'consent_status') THEN
    CREATE TYPE consent_status AS ENUM ('granted', 'revoked', 'pending', 'expired');
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS scholars (
  scholar_id BIGSERIAL PRIMARY KEY,
  external_id TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  email TEXT,
  region TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS consent_channels (
  channel_id SERIAL PRIMARY KEY,
  channel TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS consent_purposes (
  purpose_id SERIAL PRIMARY KEY,
  purpose TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS consent_documents (
  document_id BIGSERIAL PRIMARY KEY,
  scholar_id BIGINT NOT NULL REFERENCES scholars(scholar_id) ON DELETE CASCADE,
  doc_type TEXT NOT NULL,
  doc_version TEXT NOT NULL,
  storage_ref TEXT NOT NULL,
  signed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS consent_events (
  consent_event_id BIGSERIAL PRIMARY KEY,
  scholar_id BIGINT NOT NULL REFERENCES scholars(scholar_id) ON DELETE CASCADE,
  channel_id INT NOT NULL REFERENCES consent_channels(channel_id) ON DELETE RESTRICT,
  purpose_id INT NOT NULL REFERENCES consent_purposes(purpose_id) ON DELETE RESTRICT,
  status consent_status NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  effective_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  source TEXT NOT NULL,
  recorded_by TEXT,
  notes TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS consent_change_audit (
  audit_id BIGSERIAL PRIMARY KEY,
  consent_event_id BIGINT NOT NULL REFERENCES consent_events(consent_event_id) ON DELETE CASCADE,
  change_type TEXT NOT NULL,
  old_status consent_status,
  new_status consent_status,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  changed_by TEXT,
  details JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_consent_events_scholar ON consent_events(scholar_id);
CREATE INDEX IF NOT EXISTS idx_consent_events_status ON consent_events(status);
CREATE INDEX IF NOT EXISTS idx_consent_events_effective ON consent_events(effective_at DESC);
CREATE INDEX IF NOT EXISTS idx_consent_events_scope ON consent_events(scholar_id, channel_id, purpose_id, effective_at DESC);
CREATE INDEX IF NOT EXISTS idx_consent_documents_scholar ON consent_documents(scholar_id);
