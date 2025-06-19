SET search_path TO groupscholar_consent_registry;

DO $$
BEGIN
  IF (SELECT COUNT(*) FROM scholars) < 4 THEN
    RAISE EXCEPTION 'Expected at least 4 scholars in seed data.';
  END IF;

  IF (SELECT COUNT(*) FROM consent_events) < 20 THEN
    RAISE EXCEPTION 'Expected consent events to be seeded.';
  END IF;

  IF (SELECT COUNT(*) FROM v_latest_consent) = 0 THEN
    RAISE EXCEPTION 'v_latest_consent should not be empty.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM v_latest_consent
    GROUP BY scholar_id, channel_id, purpose_id
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION 'v_latest_consent contains duplicate scopes.';
  END IF;

  IF (SELECT COUNT(*) FROM v_active_consent) = 0 THEN
    RAISE EXCEPTION 'v_active_consent should have at least one granted record.';
  END IF;
END $$;
