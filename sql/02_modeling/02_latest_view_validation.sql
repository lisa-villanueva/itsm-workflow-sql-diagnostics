-- Validation: v_incidents_latest should have 1 row per incident number
SELECT
  COUNT(*) AS latest_rows,
  COUNT(DISTINCT number) AS distinct_numbers
FROM v_incidents_latest;

-- Expectation: latest_rows = distinct_numbers = 20769

-- Spot-check: how many raw rows per incident (distribution top end)
SELECT
  number,
  COUNT(*) AS rows_per_incident,
  MIN(sys_mod_count) AS min_mod,
  MAX(sys_mod_count) AS max_mod
FROM incidents
GROUP BY number
ORDER BY rows_per_incident DESC
LIMIT 15;