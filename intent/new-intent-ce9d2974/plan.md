# Plan: Orders data product from legacy billing system

**Goal:** Configure the legacy billing system source, ingest orders and refunds via dlt, then build two dbt marts — daily revenue and refunds-by-warehouse — on DuckDB-local.

**Architecture:** dlt ingestion pipeline (latest-snapshot, replace) → bronze → dbt staging views → dbt marts (tables). Daily orchestration.

**Tech Stack:** dlt (DuckDB destination), dbt-core with DuckDB adapter, ephemeral DuckDB at `$VD_EPHM_DUCKDB_PATH`.

## Global Constraints

- Platform: DuckDB-local, `duckdb` dialect
- Sandbox: `$VD_EPHM_DUCKDB_PATH`
- SCD: Latest snapshot only (write disposition: replace)
- Domain rule: null `customer_id` = guest checkout — preserve as-is, do not filter or flag
- Domain rule: Refunds grouped by `fulfillment_warehouse`, not billing region (ADR-0001)
- Freshness: Daily schedule
- Source: Not yet configured — no `[sources.*]` in `ingestion/.dlt/config.toml`
- Pipeline naming: `legacy_billing_pipeline`
- Staging naming: `stg_legacy_billing__{table}`
- Mart naming: `fct_daily_revenue`, `fct_refunds_by_warehouse`
- Schema contract defaults: columns=freeze, tables=evolve, data_type=freeze
- No `dev_mode=True`, `.add_limit()`, or target-pinned hacks

---

## Tasks

### Task 1: Configure legacy billing system source

**Files:**
- Create: `ingestion/.dlt/config.toml` (populated with `[sources.legacy_billing]` section)

**Interfaces:**
- Consumes: Nothing (first task)
- Produces: Source connection `legacy_billing` in `ingestion/.dlt/config.toml`

- [ ] **Step 1: add-or-update-source** — configure the legacy billing system connection via `add-or-update-source`, introspecting the connector for auth methods and fields, writing `[sources.legacy_billing]` to `ingestion/.dlt/config.toml`.

- [ ] **Step 2: test-source-connection** — verify the connection resolves and passes.

- [ ] **Step 3: Commit**

```bash
git add ingestion/.dlt/config.toml
git commit -m "ingestion: configure legacy billing system source"
```

### Task 2: Discover source schema

**Files:**
- Modify: `intent/new-intent-ce9d2974/design.md` (update Pipeline Inventory with discovered schema)

**Interfaces:**
- Consumes: Source connection `legacy_billing` from Task 1
- Produces: Discovered schema (columns, types, primary keys) for `orders` and `refunds` resources, recorded in `design.md` Pipeline Inventory

- [ ] **Step 1: discovering-source-schema** — run schema discovery against the configured `legacy_billing` source for both `orders` and `refunds` resources. Record column names, data types, and primary keys.

- [ ] **Step 2: Update Pipeline Inventory** — fill in `entry_point`, `notes` (primary key), and pin schema contracts in `design.md`.

- [ ] **Step 3: Commit**

```bash
git add intent/new-intent-ce9d2974/design.md
git commit -m "design: pin source schema for legacy billing orders and refunds"
```

### Task 3: Generate and run dlt pipeline

**Files:**
- Create: `ingestion/legacy_billing_pipeline.py`
- Create: `ingestion/last-run-preview.md` (bronze preview)

**Interfaces:**
- Consumes: Source schema from Task 2, source connection from Task 1
- Produces: Bronze tables `orders` and `refunds` in ephemeral DuckDB, pipeline script `ingestion/legacy_billing_pipeline.py`

- [ ] **Step 1: generating-dlt-pipeline** — generate the dlt pipeline script from the discovered schema and pipeline inventory. Apply schema contracts (columns=freeze, tables=evolve, data_type=freeze), write disposition=replace (latest snapshot). Wrap in VibeData runtime. Preserve null `customer_id` as-is.

- [ ] **Step 2: running-dlt-in-sandbox** — run the pipeline against the ephemeral DuckDB at `$VD_EPHM_DUCKDB_PATH`. Verify exit code 0, rows landed in both `orders` and `refunds` bronze tables.

- [ ] **Step 3: Bronze preview** — render bronze preview per `_shared/references/playbooks/bronze-preview.md`, writing `ingestion/last-run-preview.md`.

- [ ] **Step 4: ingestion-data-testing** — validate landed bronze data: row counts > 0, schema conformance, null `customer_id` values present (guest checkout), no unexpected nulls on primary keys.

- [ ] **Step 5: Commit**

```bash
git add ingestion/legacy_billing_pipeline.py ingestion/last-run-preview.md
git commit -m "ingestion: legacy billing pipeline — orders and refunds"
```

### Task 4: Generate dbt staging models

**Files:**
- Create: `transformation/models/staging/stg_legacy_billing__orders.sql`
- Create: `transformation/models/staging/stg_legacy_billing__refunds.sql`
- Modify: `transformation/models/staging/sources.yml` (register bronze tables as dbt sources)

**Interfaces:**
- Consumes: Bronze tables `orders` and `refunds` from Task 3
- Produces: Staging views `stg_legacy_billing__orders`, `stg_legacy_billing__refunds`

- [ ] **Step 1: registering-dbt-sources** — register bronze `orders` and `refunds` tables in `transformation/models/staging/sources.yml`.

- [ ] **Step 2: generating-dbt-model** — create staging views. `stg_legacy_billing__orders`: 1:1 with bronze `orders`, preserve null `customer_id`. `stg_legacy_billing__refunds`: 1:1 with bronze `refunds`, preserve `fulfillment_warehouse`.

- [ ] **Step 3: Commit**

```bash
git add transformation/models/staging/
git commit -m "transformation: staging views for legacy billing orders and refunds"
```

### Task 5: Generate dbt marts and run dbt build

**Files:**
- Create: `transformation/models/marts/fct_daily_revenue.sql`
- Create: `transformation/models/marts/fct_refunds_by_warehouse.sql`
- Create: `transformation/models/marts/schema.yml` (mart contracts + tests)

**Interfaces:**
- Consumes: `stg_legacy_billing__orders`, `stg_legacy_billing__refunds` from Task 4
- Produces: Mart tables `fct_daily_revenue` (grain: date), `fct_refunds_by_warehouse` (grain: fulfillment_warehouse)

- [ ] **Step 1: generating-dbt-model** — create `fct_daily_revenue`: GROUP BY order_date, SUM(revenue) per day. Create `fct_refunds_by_warehouse`: GROUP BY fulfillment_warehouse, SUM(refund_amount), COUNT(refund_id). Add schema.yml with `not_null` + `unique` tests on primary keys.

- [ ] **Step 2: running-dbt-in-sandbox** — `dbt build --select +fct_daily_revenue +fct_refunds_by_warehouse --target dev`. Verify exit code 0, all models and tests pass.

- [ ] **Step 3: Commit**

```bash
git add transformation/models/marts/
git commit -m "transformation: daily revenue and refunds-by-warehouse marts"
```

### Task 6: Generate orchestration

**Files:**
- Create: Orchestration definition per DuckDB-local platform (dbt + dlt schedule artifacts)

**Interfaces:**
- Consumes: Pipeline `legacy_billing_pipeline` from Task 3, dbt models from Task 5
- Produces: Schedule definition matching `design.md` Schedule contract

- [ ] **Step 1: generating-orchestration** — generate the daily orchestration definition for `legacy-billing-daily` schedule: cron `0 6 * * *`, timezone UTC, engine dlt.

- [ ] **Step 2: Commit**

```bash
git add orchestration/
git commit -m "orchestration: daily schedule for legacy billing pipeline"
```

## Execution evidence
