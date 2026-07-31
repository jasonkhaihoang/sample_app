
  
  create view "duckdb-local"."main_staging"."stg_order_line_items__dbt_tmp" as (
    -- stg_order_line_items: one row per order line-item event.
-- Light rename/cast from the seed — no business logic.

SELECT
    order_id,
    line_item_id,
    product_id,
    revenue::DECIMAL(10,2) AS revenue,
    quantity::INTEGER AS quantity,
    unit_price::DECIMAL(10,2) AS unit_price,
    customer_id,
    event_timestamp::TIMESTAMP AS event_timestamp
FROM "duckdb-local"."main"."raw_order_line_items"
  );
