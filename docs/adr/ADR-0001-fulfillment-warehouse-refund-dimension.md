# ADR-0001: Fulfillment warehouse as the refund-grouping dimension

**Date:** 2026-08-03
**Status:** Accepted

## Context

Refund reporting requires a consistent grouping dimension. Two candidates: billing region (the customer's original billing address) and fulfillment warehouse (the physical location that shipped the order). The domain owner chose fulfillment warehouse as the dimension for all current and future refund reporting.

## Decision

Group refunds by `fulfillment_warehouse`, not by billing region. This applies domain-wide — every refund model in this domain uses this dimension.

## Consequences

- All refund models must include a `fulfillment_warehouse` column in their grain.
- Billing-region-based refund analysis is out of scope for this domain.
- Downstream consumers (dashboards, reports) must key refund views on warehouse, not region.
