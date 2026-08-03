# Design: Orders data product from legacy billing system

## Architecture

**Platform**: DuckDB-local (`duckdb`). dlt ingestion and dbt transformation both target the ephemeral DuckDB at `$VD_EPHM_DUCKDB_PATH`.

**Source**: Legacy billing system — not yet configured (no `[sources.*]` in `ingestion/.dlt/config.toml`). Source setup (`add-or-update-source`) is deferred to `plan.md` as the first task before schema discovery and pipeline generation.

**Ingestion**: dlt pipeline loading orders and refunds into bronze. Latest-snapshot only (SCD: replace). Write disposition: `replace`.

**Domain rules**:
- null `customer_id` = guest checkout (not a data quality defect) — pipeline must pass nulls through as-is.
- Refunds grouped by `fulfillment_warehouse`, not billing region — domain-level dimension choice for all refund reporting. See `docs/adr/ADR-0001-fulfillment-warehouse-refund-dimension.md`.

**Transformation**: Two-hop staging→mart (standard medallion). Staging views are 1:1 with bronze tables. Marts materialized as tables.
- `fct_daily_revenue` — SUM(revenue) per day, daily grain.
- `fct_refunds_by_warehouse` — aggregated by `fulfillment_warehouse`.

**Schedule**: Daily orchestration (exact cron TBD after source configured). Schedule section below.

## Pipeline Inventory

| resource | entry_point | columns | tables | data_type | write_disposition | incremental_cursor | notes | status |
|---|---|---|---|---|---|---|---|---|
| orders | TBD | freeze | evolve | freeze | replace | | null `customer_id` = guest checkout; primary key TBD | working |
| refunds | TBD | freeze | evolve | freeze | replace | | grouped by fulfillment_warehouse downstream; primary key TBD | working |

`entry_point` and primary keys are TBD until source is configured and schema is discovered.

## Model Inventory

| # | Model | Layer | Grain | Materialization | Depends On | Status |
|---|---|---|---|---|---|---|
| 1 | `stg_legacy_billing__orders` | staging | one row per order | view | bronze `orders` | working |
| 2 | `stg_legacy_billing__refunds` | staging | one row per refund | view | bronze `refunds` | working |
| 3 | `fct_daily_revenue` | mart | one row per day | table | `stg_legacy_billing__orders` | working |
| 4 | `fct_refunds_by_warehouse` | mart | one row per fulfillment warehouse | table | `stg_legacy_billing__refunds` | working |

## Source Mapping / Discovery

**Source not configured.** `ingestion/.dlt/config.toml` does not exist — no `[sources.*]` section present. Schema discovery (`discovering-source-schema`) is blocked until the source connection is set up.

`plan.md` task order:
1. `add-or-update-source` — configure the legacy billing system connection
2. `discovering-source-schema` — read schema, pin contracts
3. `generating-dlt-pipeline` — generate the pipeline from discovered schema

Column-level mapping and grain decisions for staging models are deferred until bronze schema is known.

## Schedule

```yaml
schedules:
  - name: legacy-billing-daily
    cron: "0 6 * * *"
    timezone: UTC
    selector: legacy_billing_pipeline
    engine: dlt
    depends_on: []
```

## Change Impact

Fresh build — no existing ingestion pipeline or transformation models for this source. Net-new data product, zero impact on existing models. The existing `raw_order_line_items` source and its downstream models (`stg_orders__order_line_items`, `fct_order_revenue`) are unrelated — they come from a different source system (order event stream).

## Approvals
