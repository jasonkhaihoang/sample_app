-- one row per order line-item event (event_id)
SELECT
  event_id,
  order_id,
  line_item_id,
  product_id,
  quantity,
  unit_price,
  line_total,
  event_timestamp,
  ingested_at
FROM {{ source('orders', 'raw_order_line_items') }}
