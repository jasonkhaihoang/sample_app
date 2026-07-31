---
kind: transformation
---

# Intent: Revenue-per-order data mart

## Goal

A data mart that shows total revenue per order for the sales-insights domain, enabling order-level revenue analysis. The source system emits one event per order line item, and a single order's line items can arrive as separate events minutes apart — so a row in the raw source is a line item, not an order.

## Source system

Order event stream (emits one event per order line item; line items for the same order may arrive minutes apart).

## Target

DuckDB-local domain database (`duckdb-local.duckdb`), dbt transformation layer.

## Objects in scope

- Orders (aggregated from line-item events)
- Order line items (raw source events)
- Revenue (sum of line-item amounts per order)

## Deliverables inventory

| # | Deliverable | Kind | Notes |
| --- | --- | --- | --- |
| 1 | Order revenue mart (`fct_order_revenue`) | mart/model | Grain: one row per order, keyed by `order_id`. Metric: `total_revenue` = SUM(line_total), gross — no discounts/taxes/returns netted. Consumers: downstream models/dashboards → table materialization. Freshness: daily refresh. |

## Success criteria

- Mart produces one row per order with `order_id` as the primary key
- `total_revenue` equals the gross sum of all line-item amounts for that order
- `not_null` and `unique` on `order_id`
- Daily refresh cadence

## Out of scope

- Nothing beyond the revenue-per-order mart — no customer dimension, no product breakdown, no historical snapshots.

## Open questions

- Source table name and schema (resolved: synthetic `raw_order_line_items` in ephemeral DuckDB)

## Approvals

- [x] User approved intent — 2026-07-31 07:28 UTC
