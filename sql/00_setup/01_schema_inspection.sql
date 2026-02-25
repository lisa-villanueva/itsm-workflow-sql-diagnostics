-- ============================================
-- 01_schema_inspection.sql
-- Purpose:
-- Inspect schema, data types, key fields, and basic integrity signals
-- for the ITSM incident event log loaded into SQLite as table `incidents`.
-- ============================================

-- 1) SQLite version (useful for confirming window function support)
SELECT sqlite_version() AS sqlite_version;

-- 2) Table existence check
SELECT name, type
FROM sqlite_master
WHERE type IN ('table','view')
ORDER BY type, name;

-- 3) Column inventory (names, types, nullability, PK flags)
PRAGMA table_info(incidents);

-- 4) Create statement (captures how SQLite stored the schema)
SELECT sql
FROM sqlite_master
WHERE type='table' AND name='incidents';

-- 5) Row count (event log size)
SELECT COUNT(*) AS total_event_rows
FROM incidents;

-- 6) Distinct incident count (case count)
SELECT COUNT(DISTINCT number) AS distinct_incidents
FROM incidents;

-- 7) Event density (average events per incident)
SELECT
  ROUND(1.0 * COUNT(*) / COUNT(DISTINCT number), 2) AS avg_events_per_incident
FROM incidents;

-- 8) Candidate key check (should be FALSE for event logs; useful to confirm)
-- If number were unique, this would match total_event_rows. It should not.
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT number) AS distinct_numbers
FROM incidents;

-- 9) Timestamp field coverage (NULL/blank rates)
SELECT
  SUM(CASE WHEN opened_at IS NULL OR TRIM(CAST(opened_at AS TEXT)) = '' THEN 1 ELSE 0 END) AS missing_opened_at,
  SUM(CASE WHEN sys_created_at IS NULL OR TRIM(CAST(sys_created_at AS TEXT)) = '' THEN 1 ELSE 0 END) AS missing_sys_created_at,
  SUM(CASE WHEN sys_updated_at IS NULL OR TRIM(CAST(sys_updated_at AS TEXT)) = '' THEN 1 ELSE 0 END) AS missing_sys_updated_at,
  SUM(CASE WHEN resolved_at IS NULL OR TRIM(CAST(resolved_at AS TEXT)) = '' THEN 1 ELSE 0 END) AS missing_resolved_at,
  SUM(CASE WHEN closed_at IS NULL OR TRIM(CAST(closed_at AS TEXT)) = '' THEN 1 ELSE 0 END) AS missing_closed_at
FROM incidents;

-- 10) Date range sanity (raw strings)
SELECT
  MIN(opened_at) AS min_opened_at_raw,
  MAX(opened_at) AS max_opened_at_raw,
  MIN(sys_updated_at) AS min_sys_updated_at_raw,
  MAX(sys_updated_at) AS max_sys_updated_at_raw
FROM incidents;

-- 11) sys_mod_count range (version/update counter signal)
SELECT
  MIN(sys_mod_count) AS min_sys_mod_count,
  MAX(sys_mod_count) AS max_sys_mod_count
FROM incidents;

-- 12) Distribution of events per incident (top 15, identifies high-churn cases)
SELECT
  number,
  COUNT(*) AS rows_per_incident,
  MIN(sys_mod_count) AS min_mod,
  MAX(sys_mod_count) AS max_mod
FROM incidents
GROUP BY number
ORDER BY rows_per_incident DESC
LIMIT 15;

-- 13) Possible primary segmentation fields (top values)
-- Priority mix (as stored)
SELECT priority, COUNT(*) AS n
FROM incidents
GROUP BY priority
ORDER BY n DESC;

-- Incident state values (helps map open/closed logic)
SELECT incident_state, COUNT(*) AS n
FROM incidents
GROUP BY incident_state
ORDER BY n DESC;

-- Assignment group concentration (work distribution)
SELECT assignment_group, COUNT(*) AS n
FROM incidents
GROUP BY assignment_group
ORDER BY n DESC
LIMIT 15;

-- Category demand mix
SELECT category, COUNT(*) AS n
FROM incidents
GROUP BY category
ORDER BY n DESC
LIMIT 15;

-- 14) Boolean/flag encoding discovery (to normalize later)
SELECT made_sla, COUNT(*) AS n
FROM incidents
GROUP BY made_sla
ORDER BY n DESC;

SELECT active, COUNT(*) AS n
FROM incidents
GROUP BY active
ORDER BY n DESC;

SELECT knowledge, COUNT(*) AS n
FROM incidents
GROUP BY knowledge
ORDER BY n DESC;

-- 15) Quick integrity check: are there events missing the case identifier?
SELECT COUNT(*) AS missing_number
FROM incidents
WHERE number IS NULL OR TRIM(CAST(number AS TEXT)) = '';

-- 16) Quick integrity check: duplicates on (number, sys_mod_count)
-- If present, latest-state selection must use timestamp + rowid tie-breakers.
SELECT
  number,
  sys_mod_count,
  COUNT(*) AS dup_rows
FROM incidents
GROUP BY number, sys_mod_count
HAVING COUNT(*) > 1
ORDER BY dup_rows DESC, number
LIMIT 25;