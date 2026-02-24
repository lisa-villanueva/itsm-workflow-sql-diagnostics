-- ============================================
-- Dataset Size and Event-to-Case Ratio
-- Purpose:
-- Understand event density and confirm modeling assumptions.
-- ============================================

-- Total event rows
SELECT COUNT(*) AS total_event_rows
FROM incidents;

-- Distinct incidents (case count)
SELECT COUNT(DISTINCT number) AS distinct_incidents
FROM incidents;

-- Average events per incident
SELECT
  ROUND(1.0 * COUNT(*) / COUNT(DISTINCT number), 2) AS avg_events_per_incident
FROM incidents;

-- Top 10 incidents by event count
SELECT
  number,
  COUNT(*) AS rows_per_incident
FROM incidents
GROUP BY number
ORDER BY rows_per_incident DESC
LIMIT 10;