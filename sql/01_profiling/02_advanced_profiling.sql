-- ============================================
-- ADVANCED BEGINNER PROFILING QUERIES
-- Purpose: Explore workflow distribution and friction drivers
-- ============================================

-- ============================================
-- Workflow Distribution: Priority & Assignment Group
-- This shows how cases are distributed across priorities and teams, which can indicate workload balance and risk concentration.
-- ============================================

-- Priority distribution (case-level)
-- Skills demonstrated: GROUP BY, window function, percentage calculation
-- Why it matters: Shows workload mix and operational risk concentration

SELECT
  priority,
  COUNT(*) AS case_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM v_incidents_latest
GROUP BY priority
ORDER BY case_count DESC;


-- Assignment group distribution (case-level)
-- This identifies workload concentration.
-- Executive question: Are 2 teams handling 70% of demand?

SELECT
  assignment_group,
  COUNT(*) AS case_count
FROM v_incidents_latest
GROUP BY assignment_group
ORDER BY case_count DESC
LIMIT 15;

-- ============================================
-- Rework
-- ============================================

-- Rework & Friction Analysis
-- This shows how many cases have been reopened, which can indicate issues with resolution quality or complexity.
-- Skills: CASE, Bucketing logic
-- Business impact: Reopen_count is rework. Rework drives cycle time and SLA breaches.

SELECT
  reopen_count,
  COUNT(*) AS case_count
FROM v_incidents_latest
GROUP BY reopen_count
ORDER BY reopen_count DESC;

-- Better version (risk segmentation)
'High Rework'
  END AS rework_category,
  COUNT(*) AS case_count

  SELECT
  CASE
    WHEN reopen_count = 0 THEN 'No Reopen'
    WHEN reopen_count = 1 THEN 'Reopened Once'
    ELSE 'Reopened Multiple'
  END AS reopen_bucket,
  COUNT(*) AS case_count
FROM v_incidents_latest
GROUP BY reopen_bucket;

-- Reassignment Impact on SLA
-- Linking Operational friction → performance outcome

SELECT
  CASE
    WHEN reassignment_count = 0 THEN 'No Reassignment'
    WHEN reassignment_count BETWEEN 1 AND 2 THEN '1-2 Reassignments'
    ELSE '3+ Reassignments'
  END AS reassignment_bucket,
  COUNT(*) AS total_cases,
  SUM(CASE WHEN made_sla IN (1, 'true', 'TRUE') THEN 1 ELSE 0 END) AS sla_met,
  ROUND(
    1.0 * SUM(CASE WHEN made_sla IN (1, 'true', 'TRUE') THEN 1 ELSE 0 END) / COUNT(*),
    3
  ) AS sla_rate
FROM v_incidents_latest
GROUP BY reassignment_bucket;

-- ============================================
-- Aging
-- ============================================

-- Aging Buckets
-- This shows how many cases are in different age buckets, which can indicate backlog and potential SLA risks.
-- Skills: Date math, Conditional segmentation
-- CEO translation: Is backlog aging dangerously?

SELECT
  CASE
    WHEN closed_at IS NOT NULL THEN 'Closed'
    WHEN julianday('now') - julianday(opened_at) < 3 THEN '<3 days'
    WHEN julianday('now') - julianday(opened_at) < 7 THEN '3-7 days'
    WHEN julianday('now') - julianday(opened_at) < 14 THEN '7-14 days'
    ELSE '14+ days'
  END AS aging_bucket,
  COUNT(*) AS case_count
FROM v_incidents_latest
GROUP BY aging_bucket
ORDER BY case_count DESC;

-- ============================================
-- Data quality
-- ============================================

--Null & Data Quality Profiling
-- This identifies data quality issues that could impact analysis and decision-making.
-- Skills: NULL handling, Data quality assessment
-- Business impact: Data quality issues can lead to incorrect insights and poor decisions.
SELECT
  SUM(CASE WHEN opened_at IS NULL THEN 1 ELSE 0 END) AS missing_opened,
  SUM(CASE WHEN closed_at IS NULL THEN 1 ELSE 0 END) AS missing_closed,
  SUM(CASE WHEN assignment_group IS NULL THEN 1 ELSE 0 END) AS missing_assignment_group
FROM v_incidents_latest;

-- ============================================
-- Driver exploration
-- ============================================
-- Correlation Proxy (Intermediate but clean) | Cycle time vs reassignment:
SELECT
  reassignment_count,
  AVG((julianday(closed_at) - julianday(opened_at)) * 24.0) AS avg_cycle_hours
FROM v_incidents_latest
WHERE closed_at IS NOT NULL
GROUP BY reassignment_count
ORDER BY reassignment_count;

-- Demand Segmentation by Category
-- This shows how cases are distributed across categories, which can indicate demand patterns and potential areas for improvement.
-- Good for: Demand mix analysis
SELECT
  category,
  COUNT(*) AS case_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM v_incidents_latest
GROUP BY category
ORDER BY case_count DESC
LIMIT 15;

