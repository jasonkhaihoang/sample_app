# Design: Revenue-per-Order Data Mart

## Architecture

- **Platform**: DuckDB-local. Source data generated as a dbt seed; models built and run in the ephemeral sandbox (`$VD_EPHM_DUCKDB_PATH`).
- **Grain**: The mart (`fct_order_revenue`) has one row per order. Each order aggregates revenue from all its line-item events, which may arrive with different timestamps.
- **Materialization**: Staging as `view` (light pass-through from seed), mart as `table` (materialized aggregate for query performance).
- **Layers**: Single-hop -- staging (`stg_order_line_items`) normalizes the generated seed, mart (`fct_order_revenue`) groups by `order_id` and sums revenue.
- **Key decision -- no intermediate layer**: The transformation is a straight `GROUP BY` aggregation from a single source. An intermediate model would add no reusable logic, so staging -> mart is sufficient.
- **Key decision -- seed over external table**: Sample data is generated as a dbt seed CSV (`seeds/raw_order_line_items.csv`) rather than created directly in DuckDB. This keeps the data alongside the models in version control and makes the build reproducible.

## Model Inventory

| # | Model | Layer | Grain | Materialization | Depends On | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `stg_order_line_items` | staging | One row per line-item event | view | seed: `raw_order_line_items` | working |
| 2 | `fct_order_revenue` | mart | One row per order | table | `stg_order_line_items` | working |

## Source Mapping / Discovery

**Bronze Adequacy: Deferred** — no source data exists yet. The intent specifies generated sample data. A Build Plan step (`01-generate-sample-data`) will create the seed CSV with these columns:

| Column | Type | Description |
| --- | --- | --- |
| `order_id` | INTEGER | Parent order identifier |
| `line_item_id` | INTEGER | Line item within the order |
| `product_id` | INTEGER | Product SKU |
| `revenue` | DECIMAL(10,2) | Line-item revenue |
| `quantity` | INTEGER | Units sold |
| `unit_price` | DECIMAL(10,2) | Price per unit |
| `customer_id` | INTEGER | Customer who placed the order |
| `event_timestamp` | TIMESTAMP | When the line-item event was emitted |

The seed will include multiple line items per order with staggered timestamps to validate the `GROUP BY order_id` aggregation logic.

## Change Impact

No existing models — fresh workspace. No downstream consumers to assess.

## Build Plan

- `01-generate-sample-data` — phase: Build — goal: Create seed CSV with representative order line-item events — skill: `generating-dbt-model` — status: working — evidence:
- `02-generate-staging-model` — phase: Build — goal: Generate `stg_order_line_items` staging model — skill: `generating-dbt-model` — status: working — evidence:
- `03-generate-mart-model` — phase: Build — goal: Generate `fct_order_revenue` mart model — skill: `generating-dbt-model` — status: working — evidence:
- `04-sandbox-run` — phase: Build — goal: Run `dbt build` in the DuckDB sandbox — skill: `running-dbt-in-sandbox` — status: working — evidence:
- `05-profile-and-validate` — phase: Verify — goal: Profile landed data and validate row counts — skill: `profiling-source-data` — status: working — evidence:
- `06-dbt-tests` — phase: Verify — goal: Run dbt data tests (uniqueness, not-null) — skill: `dbt-unit-testing` — status: working — evidence:
- `07-evaluate-project` — phase: Verify — goal: Run dbt_project_evaluator checks — skill: `evaluating-dbt-project` — status: working — evidence:
- `08-publish-contracts` — phase: Publish — goal: Enforce model contracts and document — skill: `publishing-dbt-contracts` — status: working — evidence:
- `09-verify-completion` — phase: Publish — goal: Final completion check — skill: `verifying-completion-claims` — status: working — evidence:

## Gate Ledger

| Gate | Status | Timestamp (UTC) |
| --- | --- | --- |
| Intent | ✅ | 2026-07-31 02:10 |
| Design | — | — |
| Build | — | — |
| Verify | — | — |
| Publish | — | — |

## Approvals

- [x] User approved intent — `2026-07-31 02:10` (UTC)
- [ ] User approved design — `YYYY-MM-DD HH:MM` (UTC)
- [ ] User approved ship — `YYYY-MM-DD HH:MM` (UTC)
