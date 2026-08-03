---
kind: ingestion
---

# Intent: Orders data product from legacy billing system

## Goal

Load orders and refunds from the legacy billing system into the DuckDB-local lakehouse, then transform into: (1) a daily revenue aggregation mart at the daily grain, and (2) a refund model grouped by fulfillment warehouse (not billing region) — which will serve as the dimension for current and future refund reporting. The source system treats a null `customer_id` as a guest checkout — not a data quality defect — and the pipeline must preserve that meaning.

## Source system

Legacy billing system. Latest-snapshot only (no SCD2 history tracking). Objects: orders (null `customer_id` = guest checkout), refunds.

## Target

DuckDB-local domain database, sandbox at `$VD_EPHM_DUCKDB_PATH`. Daily refresh cadence. Design will include a `## Schedule` section (orchestration).

## Objects in scope

- Orders (from the legacy billing system)
- Refunds (from the legacy billing system)
- Daily revenue (aggregated from orders at daily grain)
- Refunds by fulfillment warehouse

## Deliverables inventory

| # | Deliverable | Kind | Notes |
| --- | --- | --- | --- |
| 1 | Orders + refunds ingestion pipeline | pipeline | Source: legacy billing system. null `customer_id` = guest checkout. Lands orders and refunds into bronze. |
| 2 | Daily revenue mart | mart/model | Aggregated at daily grain. Depends on #1 (bronze orders). |
| 3 | Refunds-by-warehouse model | mart/model | Grouped by fulfillment warehouse, not billing region. Depends on #1 (bronze refunds). |

## Success criteria

- Pipeline loads orders and refunds into bronze without data loss, on a daily schedule
- null `customer_id` values are preserved as-is (guest checkout semantics)
- Daily revenue mart produces one row per day with correct revenue totals
- Refund model groups by fulfillment warehouse, not billing region
- All models build with exit code 0 and pass basic data tests

## Out of scope

- Semantic Model / MetricFlow definitions
- Product or customer dimension models (these two marts only)

## Open questions

- Source connection type and details (not yet configured — no `[sources.*]` in `ingestion/.dlt/config.toml`)
- Source schema / table structure for orders and refunds (unreadable until source is configured)

## Approvals

- [x] User approved intent — 2026-08-03 07:22 UTC
