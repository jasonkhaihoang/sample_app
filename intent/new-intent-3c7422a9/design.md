# Design: Revenue-per-order data mart

## Architecture

**Platform**: DuckDB-local (`duckdb`). dbt models run against the ephemeral DuckDB at `$VD_EPHM_DUCKDB_PATH`.

**Source**: `raw_order_line_items` — synthetic order line-item events (70 rows, 20 distinct orders). Schema: `event_id` (PK), `order_id`, `line_item_id`, `product_id`, `quantity`, `unit_price`, `line_total`, `event_timestamp`, `ingested_at`.

**Approach**: Single-hop staging→mart. Staging (`stg_orders__order_line_items`) is a 1:1 view. The mart (`fct_order_revenue`) aggregates by `order_id` to produce one row per order with gross revenue.

**Grain**: `fct_order_revenue` — one row per order, keyed by `order_id`.

**Materialization**: Staging = view, mart = table (downstream consumers).

**Metric**: `total_revenue` = `SUM(line_total)` — gross, no discounts/taxes/returns netted.

**No intermediate model**: Simple GROUP BY aggregation, no multi-source join or complex business logic.

## Inventory

| # | Model | Layer | Grain | Materialization | Depends On | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `stg_orders__order_line_items` | staging | one row per line-item event (`event_id`) | view | `raw_order_line_items` | working |
| 2 | `fct_order_revenue` | mart | one row per order (`order_id`) | table | `stg_orders__order_line_items` | working |

## Source Mapping / Discovery

**Bronze Adequacy**: Ready.

Profiling of `raw_order_line_items` (ephemeral DuckDB): 70 rows, 20 distinct orders, 0% nulls, event_id 100% unique, late-arrival spread up to 28 minutes.

Source-to-layer: `raw_order_line_items` → `stg_orders__order_line_items` → `fct_order_revenue`.

## Change Impact

Fresh build — no existing dbt models. Net-new mart, zero impact.

## Approvals

- [x] User approved design — 2026-07-31 07:28 UTC
