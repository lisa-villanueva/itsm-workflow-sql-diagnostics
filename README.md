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