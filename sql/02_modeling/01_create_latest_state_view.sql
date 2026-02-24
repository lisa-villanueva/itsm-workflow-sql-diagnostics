-- Purpose: Normalize event-log incidents into one-row-per-incident (latest state)
-- Grain: 1 row per number
-- Notes: Source timestamps are d/m/yyyy hh:mm, so we parse to ISO-like format for ordering.

DROP VIEW IF EXISTS v_incidents_latest;

CREATE VIEW v_incidents_latest AS
WITH ranked AS (
  SELECT
    i.*,
    ROW_NUMBER() OVER (
      PARTITION BY number
      ORDER BY
        (
          WITH src(dt) AS (SELECT COALESCE(i.sys_updated_at, i.sys_created_at))
          SELECT
            substr(dt, instr(dt, '/') + 1 + instr(substr(dt, instr(dt, '/') + 1), '/'), 4) || '-' ||
            printf('%02d', CAST(substr(dt, instr(dt, '/') + 1, instr(substr(dt, instr(dt, '/') + 1), '/') - 1) AS INT)) || '-' ||
            printf('%02d', CAST(substr(dt, 1, instr(dt, '/') - 1) AS INT)) || ' ' ||
            substr(dt, instr(dt, ' ') + 1)
          FROM src
        ) DESC,
        sys_mod_count DESC,
        rowid DESC
    ) AS rn
  FROM incidents i
)
SELECT *
FROM ranked
WHERE rn = 1;