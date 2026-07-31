-- one row per order (order_id)
-- gross revenue = SUM of all line-item totals for the order
SELECT
  order_id,
  SUM(line_total) AS total_revenue,
  COUNT(*) AS line_item_count,
  MIN(event_timestamp) AS first_event_at,
  MAX(event_timestamp) AS last_event_at,
  CURRENT_TIMESTAMP AS _loaded_at,
  '{{ invocation_id }}' AS _dbt_invocation_id,
  '{{ git_sha() }}' AS _git_sha
FROM {{ ref('stg_orders__order_line_items') }}
GROUP BY order_id
