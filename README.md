# ITSM Workflow SQL Diagnostics
## Findings
Reworked ITSM tickets experience a 45% SLA performance collapse (19% attainment vs. 64% for clean tickets) despite representing only 7.8% of incident volume. This analysis used SQL to identify rework patterns, normalize event-log data into one-row-per-incident views, and quantify the SLA penalty caused by process friction.

Key finding: Process friction accounts for a 45-percentage-point SLA collapse despite affecting only 7.8% of ticket volume.

## Business Context
IT operations teams often can't see the cost of workflow turbulence. This diagnostic isolates the "Rework Tax" as the primary driver of SLA failure and senior engineer context-switching overhead.

## Approach
I normalized the event-log into a one-row-per-incident view and defined rework thresholds to include reopen_count > 0 and reassignment_count > 3. 


## Dataset & Schema
Source: Public ITSM incident event log dataset (Kaggle).
https://www.kaggle.com/datasets/vipulshinde/incident-response-log

Structure:
- Event-level table (`incidents`)
- Multiple rows per incident (state transitions / updates)
- 36 attributes including lifecycle timestamps, SLA flags, assignment groups, and rework indicators


## Architecture Overview
This project separates logic into layers:
00_setup → 01_profiling → 02_modeling → 03_metrics → 04_governance. 

00_setup  Inspect schema, data types, key fields, and basic integrity signals

01_profiling Understand event density and confirm modeling assumptions. Explore workflow distribution and friction drivers

02_modeling Normalize event-log incidents into one-row-per-incident (latest state). 

03_metrics Identifies the 'SLA Penalty' associated with reassignments and reopens. uantify the cost of process friction (Rework)

04_governance TBD

## Key Queries

### Normalization Logic
A single incident generates multiple event-log rows as it moves through assignment and status changes. I created a normalized view to isolate the latest state of each incident using `ROW_NUMBER()` window functions partitioned by incident number.

See [`02_modeling/create_latest_view.sql`](sql/02_modeling/create_latest_view.sql) for full implementation.

### Rework & SLA Performance Analysis
This query identifies the "Rework Tax" by comparing SLA attainment between clean tickets and those experiencing process friction (reassignment_count > 3 or reopen_count > 0):
WITH rework_flagged AS (
    SELECT 
        number,
        assignment_group,
        -- Ensuring made_sla is treated as a truthy value (1, '1', or 'true')
        CASE 
            WHEN made_sla IN (1, '1', 'true', 'True') THEN 1.0 
            ELSE 0.0 
        END AS is_sla_met,
        (julianday(resolved_at) - julianday(sys_created_at)) * 24 AS cycle_time_hours,
        CASE 
            WHEN reassignment_count > 3 OR reopen_count > 0 THEN 'Rework'
            ELSE 'Clean'
        END AS process_quality
    FROM v_incidents_latest
    WHERE resolved_at IS NOT NULL 
      AND sys_created_at IS NOT NULL
)
SELECT 
    process_quality,
    COUNT(number) AS incident_count,
    ROUND(AVG(cycle_time_hours), 2) AS avg_hours,
    -- KPI: SLA Success Rate by Quality
    ROUND(AVG(is_sla_met) * 100, 2) || '%' AS sla_rate
FROM rework_flagged
GROUP BY process_quality;

## Governance & Data Quality
A single incident may generate multiple rows as it moves through assignment, status changes, and resolution. Because operational decisions are made at the case or incident-level, metrics such as backlog, SLA attainment, and cycle time must reflect one record per incident. Calculating these directly on the event log would overstate workload and distort performance because incidents with more updates would be counted multiple times.

To ensure decision-grade accuracy, a normalized view (v_incidents_latest) was created to isolate the most recent state of each incident. All KPIs are calculated from this case-level view, preventing inflation, preserving auditability, and aligning reporting with how leadership evaluates operational performance.

---

## Tools & Skills Demonstrated

- SQL: Window functions (ROW_NUMBER), CTEs, conditional aggregation
- Data Governance: Case-level normalization, metric integrity, reconciliation logic
- Business Analysis: Root cause isolation, executive framing, diagnostic KPI design


## AI Readiness Considerations

The dataset supports AI-forward extensions such as:

- SLA breach prediction
- Reassignment risk scoring
- Exception monitoring automation
- AI-assisted triage routing

This project intentionally builds the governance foundation required before AI implementation.


---

## How to Run

1. Import CSV into SQLite as table `incidents`
2. Execute setup scripts in `/sql/00_setup`
3. Create modeling views in `/sql/02_modeling`
4. Run metric scripts in `/sql/03_metrics`
5. Validate using `/sql/04_governance_controls`

