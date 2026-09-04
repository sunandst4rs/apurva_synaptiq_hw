--grain: one row per order_date x category x region. Reads only silver.orders (valid rows) — rejected rows (in silver_rejected_orders) are excluded automatically.'

USE CATALOG retail_demo;

CREATE OR REFRESH MATERIALIZED VIEW gold.daily_sales_by_category_region (
  CONSTRAINT positive_order_count EXPECT (order_count > 0) ON VIOLATION FAIL UPDATE
)
AS
SELECT
  o.order_date_clean                        AS order_date,
  coalesce(p.category, 'Unmapped')          AS category,
  o.region_clean                            AS region,
  round(sum(o.quantity_clean * o.unit_price_clean), 2)      AS net_revenue,
  count(DISTINCT o.order_id)                AS order_count,
  sum(o.quantity_clean)                     AS units_sold,
  round(sum(o.quantity_clean * o.unit_price_clean)
        / count(DISTINCT o.order_id), 2)    AS avg_order_value
FROM silver.orders o
LEFT JOIN silver.products p ON p.product_id = o.product_id
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;