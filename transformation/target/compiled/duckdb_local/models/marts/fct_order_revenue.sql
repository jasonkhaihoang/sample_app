-- fct_order_revenue: one row per order with total revenue.
-- Aggregates line-item revenue from stg_order_line_items, handling the
-- real-world pattern where line items for the same order arrive as
-- separate events with different timestamps.

WITH

line_items AS (
    SELECT * FROM "duckdb-local"."main_staging"."stg_order_line_items"
),

-- GROUP BY order_id sums revenue across all line items regardless of arrival timing
final AS (
    SELECT
        order_id,
        SUM(revenue) AS total_revenue,
        COUNT(*)     AS line_item_count,
        CURRENT_TIMESTAMP AS _loaded_at,
        '3a1afd95-a002-4cc8-9c12-277e6725a1a1' AS _dbt_invocation_id,
        'local' AS _git_sha
    FROM line_items
    GROUP BY order_id
)

SELECT * FROM final