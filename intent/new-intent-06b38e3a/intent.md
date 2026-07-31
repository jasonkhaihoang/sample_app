# Intent: Revenue-per-Order Data Mart

## Classification
- **Action**: `work`
- **Type**: `transformation`
- **Scale**: `product`

## Goal
Provide a data mart that shows total revenue per order, enabling the sales-insights domain to analyze order-level financials. Since the source emits one event per order line item — and a single order's line items can arrive as separate events minutes apart — the mart must correctly aggregate line-item revenue to the order grain.

## Source system
Generated sample data — representative order line-item events in DuckDB. Each event represents one line item with an order identifier, line-item revenue, and a timestamp. Line items for the same order may have different timestamps (simulating the real-world pattern of separate events arriving minutes apart).

## Target
DuckDB-local ephemeral sandbox (`$VD_EPHM_DUCKDB_PATH`), dbt models under `transformation/`.

## Objects in scope
- Order line-item events (source — TBD)
- Revenue-per-order mart (target model)

## Deliverables inventory

| # | Deliverable | Kind | Notes |
| --- | --- | --- | --- |
| 1 | Revenue-per-order mart | mart/model | Aggregates line-item revenue to order grain; handles late-arriving line items for the same order |

## Success criteria
- A dbt model exists that produces one row per order with total revenue
- Revenue correctly sums all line items belonging to the same order, regardless of arrival order or timing
- Model compiles and runs successfully in the DuckDB sandbox

## Out of scope
- Ingestion pipeline (unless source data does not yet exist in the lakehouse)
- Orchestration / scheduling
- Semantic model

## Open questions
- What columns should the sample line-item events include beyond order_id, line_item_id, revenue, and timestamp? (e.g., product_id, customer_id, quantity, unit_price)

## Approvals

- [x] User approved intent — `2026-07-31 02:10` (UTC)
