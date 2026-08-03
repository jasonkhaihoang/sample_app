# duckdb-local — Context

Ubiquitous language for this domain: business terms, entities, source-system quirks, and
naming conventions the agents rely on when building, fixing, or advising on this domain's
data products.

## Language

**raw_order_line_items**:
Source table in the orders domain. One row per line-item event emitted by the order system. A single order's line items can arrive as separate events minutes apart (observed up to 28 minutes). Grain is `event_id`, not `order_id` — aggregation by `order_id` is required for order-level analysis.

**order_id**:
Unique identifier for an order. Multiple line-item events in `raw_order_line_items` share the same `order_id`. The grain of any order-level mart.

**line_total**:
Pre-computed line-item amount (`quantity × unit_price`) in the source. Used as the basis for gross revenue aggregation (`total_revenue = SUM(line_total)`). No discounts, taxes, or returns are netted — this is gross revenue.

**total_revenue**:
Gross revenue per order, defined as `SUM(line_total)` across all line-item events for an `order_id`. Computed in `fct_order_revenue`.

_Design decisions_: Revenue is gross (no netting) — discounts, taxes, and returns are separate concerns.

**legacy billing system**:
Source system for orders and refunds. Latest-snapshot only (no SCD2 history). Connected via dlt ingestion pipeline (not yet configured).

**guest checkout**:
In the legacy billing system, a null `customer_id` means the order was placed by a guest — not a data quality defect. Downstream models must preserve nulls rather than filtering or flagging them.

**fulfillment warehouse**:
The dimension for grouping refunds. Preferred over the original billing region for current and future refund reporting. Set at the domain level — all refund models in this domain use this dimension.

**daily revenue**:
Gross revenue aggregated at the daily grain from orders. Computed as `SUM(line_total)` grouped by date.

<!--
Append one entry per term, as it surfaces (never pre-populate speculative terms):

**<Term>**:
One or two sentences — what it means in this domain, and why it matters to a data product.
_Avoid_: near-synonyms this domain has rejected, and why.
-->
