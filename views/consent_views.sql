SET search_path TO groupscholar_consent_registry;

CREATE OR REPLACE VIEW v_latest_consent AS
SELECT DISTINCT ON (scholar_id, channel_id, purpose_id)
  consent_event_id,
  scholar_id,
  channel_id,
  purpose_id,
  status,
  effective_at,
  expires_at,
  recorded_at,
  source,
  recorded_by,
  notes,
  metadata
FROM consent_events
ORDER BY scholar_id, channel_id, purpose_id, effective_at DESC, recorded_at DESC;

CREATE OR REPLACE VIEW v_active_consent AS
SELECT
  lc.*
FROM v_latest_consent lc
WHERE lc.status = 'granted'
  AND (lc.expires_at IS NULL OR lc.expires_at > NOW());

CREATE OR REPLACE VIEW v_scholar_consent_summary AS
SELECT
  s.scholar_id,
  s.external_id,
  s.full_name,
  s.email,
  s.region,
  COUNT(DISTINCT lc.channel_id) AS channels_tracked,
  COUNT(DISTINCT lc.purpose_id) AS purposes_tracked,
  SUM(CASE WHEN lc.status = 'granted' THEN 1 ELSE 0 END) AS granted_count,
  SUM(CASE WHEN lc.status = 'revoked' THEN 1 ELSE 0 END) AS revoked_count,
  MAX(lc.effective_at) AS last_consent_update
FROM scholars s
LEFT JOIN v_latest_consent lc ON lc.scholar_id = s.scholar_id
GROUP BY s.scholar_id, s.external_id, s.full_name, s.email, s.region;
