SET search_path TO groupscholar_consent_registry;

INSERT INTO consent_channels (channel)
VALUES
  ('email'),
  ('sms'),
  ('phone'),
  ('whatsapp')
ON CONFLICT DO NOTHING;

INSERT INTO consent_purposes (purpose)
VALUES
  ('program_updates'),
  ('fundraising'),
  ('marketing'),
  ('research'),
  ('emergency')
ON CONFLICT DO NOTHING;

INSERT INTO scholars (external_id, full_name, email, region)
VALUES
  ('GS-1001', 'Amina Rivera', 'amina.rivera@example.org', 'Midwest'),
  ('GS-1002', 'Jon Park', 'jon.park@example.org', 'Southwest'),
  ('GS-1003', 'Leila Ahmed', 'leila.ahmed@example.org', 'Northeast'),
  ('GS-1004', 'Marcus Lee', 'marcus.lee@example.org', 'West')
ON CONFLICT (external_id) DO NOTHING;

WITH channel_ids AS (
  SELECT channel_id, channel FROM consent_channels
),
purpose_ids AS (
  SELECT purpose_id, purpose FROM consent_purposes
),
base AS (
  SELECT scholar_id, external_id FROM scholars
)
INSERT INTO consent_events (
  scholar_id,
  channel_id,
  purpose_id,
  status,
  recorded_at,
  effective_at,
  expires_at,
  source,
  recorded_by,
  notes,
  metadata
)
SELECT
  b.scholar_id,
  c.channel_id,
  p.purpose_id,
  CASE
    WHEN b.external_id = 'GS-1002' AND c.channel = 'sms' THEN 'revoked'::consent_status
    WHEN b.external_id = 'GS-1004' AND p.purpose = 'marketing' THEN 'pending'::consent_status
    ELSE 'granted'::consent_status
  END,
  NOW() - INTERVAL '14 days',
  NOW() - INTERVAL '14 days',
  CASE
    WHEN p.purpose = 'fundraising' THEN NOW() + INTERVAL '180 days'
    ELSE NULL
  END,
  'import',
  'ops-bot',
  'Seeded consent status',
  jsonb_build_object('seed', true, 'batch', '2026-02-08')
FROM base b
CROSS JOIN channel_ids c
CROSS JOIN purpose_ids p
WHERE NOT EXISTS (
  SELECT 1
  FROM consent_events ce
  WHERE ce.scholar_id = b.scholar_id
    AND ce.channel_id = c.channel_id
    AND ce.purpose_id = p.purpose_id
);

INSERT INTO consent_documents (scholar_id, doc_type, doc_version, storage_ref, signed_at)
SELECT
  s.scholar_id,
  'data-consent',
  'v2.1',
  CONCAT('gs://consent/', s.external_id, '/consent-v2.1.pdf'),
  NOW() - INTERVAL '30 days'
FROM scholars s
ON CONFLICT DO NOTHING;

INSERT INTO consent_change_audit (
  consent_event_id,
  change_type,
  old_status,
  new_status,
  changed_by,
  details
)
SELECT
  ce.consent_event_id,
  'seed',
  NULL,
  ce.status,
  'ops-bot',
  jsonb_build_object('seed', true)
FROM consent_events ce
WHERE NOT EXISTS (
  SELECT 1
  FROM consent_change_audit ca
  WHERE ca.consent_event_id = ce.consent_event_id
);
