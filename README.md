# ITSM Workflow SQL Diagnostics

## Overview

This repository demonstrates intermediate-level SQL applied to an IT Service Management (ITSM) event log dataset.  

The focus is operational workflow diagnostics, SLA governance, and structured metric validation — not dashboard production.

The goal is to show:
- Lifecycle modeling from event logs
- Case-level normalization using window functions
- KPI definition discipline
- Governance and reconciliation logic
- Business-oriented diagnostic thinking

---

## Dataset

Source: Public ITSM incident event log dataset (Kaggle).
https://www.kaggle.com/datasets/vipulshinde/incident-response-log

Structure:
- Event-level table (`incidents`)
- Multiple rows per incident (state transitions / updates)
- 36 attributes including lifecycle timestamps, SLA flags, assignment groups, and rework indicators

Key modeling decision:
Event log → Latest state view for case-level reporting.

Event Log vs. Case-Level Modeling:
The source table incidents is an event log: each row represents a system update in an incident’s lifecycle. A single incident may generate multiple rows as it moves through assignment, status changes, and resolution.

Operational decisions, however, are made at the incident (case) level. Metrics such as backlog, SLA attainment, and cycle time must reflect one record per incident. Calculating these directly on the event log would overstate workload and distort performance because incidents with more updates would be counted multiple times.

To ensure decision-grade accuracy, a normalized view (v_incidents_latest) was created to isolate the most recent state of each incident. All KPIs are calculated from this case-level view, preventing inflation, preserving auditability, and aligning reporting with how leadership evaluates operational performance.

---

## Modeling Approach

This project separates logic into layers:

1. Raw event log (`incidents`)
2. Latest-state view (`v_incidents_latest`)
3. Metric-ready view (normalized dates + SLA flag)
4. Governance validation queries

Why this matters:
Event logs inflate counts and distort KPIs unless properly normalized.

---

---
## Key Metrics Implemented

- Backlog (current open incidents)
- Backlog aging buckets
- Cycle time (opened → closed)
- SLA attainment rate
- Reassignment impact
- Reopen impact
- Backlog reconciliation logic

Each metric includes explicit definition and control validation.


---

## SQL Techniques Demonstrated

- Window functions (ROW_NUMBER partitioning)
- Common Table Expressions (CTEs)
- Conditional aggregation
- Date parsing and normalization
- Governance reconciliation math
- Data quality exception checks


---

## Business Diagnostic Summary (High-Level)

This project evaluates:

- Concentration of SLA breaches
- Impact of reassignment on resolution time
- Rework amplification via reopen_count
- Operational volatility across assignment groups

The intent is to translate SQL outputs into actionable operational insights.


---

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


---

## Author Intent

This repository is part of a structured progression of building my own skills toward:

- Advanced SQL fluency
- Workflow-level operational diagnostics
- AI-enabled business transformation roles

## Executive Insights & Baselines (Feb 2026)
Through architectural normalization and SQL diagnostics, the following performance baselines were established to guide AI orchestration:

# The "Rework Tax" (SLA Penalty):
Clean Tickets: 64.16% SLA Attainment.

Reworked Tickets: 19.07% SLA Attainment.

Insight: Process friction (reassignments/reopens) results in a 45% collapse in service reliability. This is the primary target for AI-augmented triage.

#Volume vs. Impact:

Finding: While "Rework" only accounts for ~7.8% of total volume, it accounts for a disproportionate amount of SLA breaches and senior engineer "context switching."

# Process Integrity (The 3-3-3 Rule):

Baseline: Tickets with reassignment_count > 3 are statistically unlikely to meet SLA promises, regardless of priority. This establishes a Hard Trigger for human intervention.