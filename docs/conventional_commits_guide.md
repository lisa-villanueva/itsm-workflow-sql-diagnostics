
# Conventional Commits: Governed AI Strategist’s Cheat Sheet
2026-02-24

This guide is a reflection of my project management style focusing on **Process Ownership** and **Operational Discipline**. The tenets center on these values:

* **Auditability:** Treat data projects like production-grade software.
* **Communication:** Translates technical work into business value for a CIO or executive leadership
* **Discipline:** Must follow a repeatable framework.

### 1. The Standard Format

`type(scope): description`

* **Type:** The category of change (e.g., `feat`, `fix`).
* **Scope:** The specific folder or module impacted (e.g., `metrics`, `agent_specs`).
* **Description:** A short, outcome-focused summary in the imperative mood (e.g., "add," not "added").

---

### 2. Strategic Commit Types

| Type | When to Use | Example for Your Portfolio |
| --- | --- | --- |
| **`feat`** | Adding a new KPI, view, or Agent logic. | `feat(metrics): add cycle time variability analysis` |
| **`fix`** | Correcting a logical error or a broken join. | `fix(modeling): resolve null handling in latest_state_view` |
| **`docs`** | Updating READMEs, Handoffs, or Agent Specs. | `docs(agent_specs): update HITL triggers for ITSM tutor` |
| **`refactor`** | Cleaning up SQL without changing its output. | `refactor(sql): optimize window function for 100M rows` |
| **`test`** | Adding governance or reconciliation checks. | `test(gov): add negative cycle time unit test` |
| **`chore`** | Updating `.gitignore` or repository structure. | `chore(repo): initialize automation/agent_specs directory` |

---

### 3. Writing "Governed" Descriptions

Avoid vague messages like "updated sql." Instead, use language that reflects my principles:

* **Instead of:** `feat: added sla query`
* **Use:** `feat(metrics): quantify SLA attainment by assignment group to identify ROI leaks`
* **Instead of:** `fix: fixed view`
* **Use:** `fix(modeling): enforce case-level grain in v_incidents_latest`

---


