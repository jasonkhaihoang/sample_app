# Plan: Revenue-per-order data mart

**Goal:** Build two dbt models — staging view (`stg_orders__order_line_items`) and revenue-per-order mart (`fct_order_revenue`) — on DuckDB-local.

**Architecture:** Single-hop staging→mart. Staging = 1:1 view. Mart = GROUP BY order_id, SUM(line_total).

**Tech Stack:** dbt-core with DuckDB adapter, ephemeral DuckDB at `$VD_EPHM_DUCKDB_PATH`.

## Global Constraints

- Platform: DuckDB-local, `duckdb` dialect
- Source: `raw_order_line_items` in ephemeral DuckDB
- Staging: `stg_orders__order_line_items` (view), mart: `fct_order_revenue` (table, grain `order_id`)
- Metric: `total_revenue` = gross SUM(line_total)
- Tests: `not_null` + `unique` on `order_id`; control columns `not_null`
- No `dev_mode=True`, `.add_limit()`, or target-pinned hacks

---

## Tasks

### Task 1: Generate, build, and test both models

**Files:** `transformation/dbt_project.yml`, `transformation/profiles.yml`, `transformation/macros/git_sha.sql`, `transformation/models/staging/sources.yml`, `transformation/models/staging/stg_orders__order_line_items.sql`, `transformation/models/marts/fct_order_revenue.sql`, `transformation/models/marts/schema.yml`

**Interfaces:** Consumes `raw_order_line_items` (event_id, order_id, line_item_id, product_id, quantity, unit_price, line_total, event_timestamp, ingested_at). Produces `stg_orders__order_line_items` (view), `fct_order_revenue` (table: order_id PK, total_revenue, line_item_count, first_event_at, last_event_at, _loaded_at, _dbt_invocation_id, _git_sha).

- [x] **Step 1: Generate dbt project and both models**
- [x] **Step 2: Sandbox run** — `dbt build --select +fct_order_revenue --target dev`
- [x] **Step 3: Commit**

## Execution evidence

- [x] Task 1 Step 1: `dbt compile --select +fct_order_revenue --target dev` — exit 0 — `transformation/models/staging/stg_orders__order_line_items.sql`, `transformation/models/marts/fct_order_revenue.sql`
- [x] Task 1 Step 2: `dbt build --select +fct_order_revenue --target dev` — exit 0 — 7/7 PASS (2 models, 5 tests) — enforced contract on `fct_order_revenue`, 20 rows, $41,497.98 total
