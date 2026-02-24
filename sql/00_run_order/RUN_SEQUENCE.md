# SQL Execution Order

1. 00_setup
   - 01_schema_inspection.sql

2. 01_profiling
   - 01_row_counts_and_uniqueness.sql

3. 02_modeling
   - 01_create_latest_state_view.sql
   - 02_latest_view_validation.sql

4. 03_metrics
   - (backlog, SLA, cycle time)

5. 04_governance_controls
   - reconciliation + data quality checks