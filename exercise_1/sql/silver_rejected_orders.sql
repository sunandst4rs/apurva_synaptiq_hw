--rejected orders, in our case only on the fields required for gold processing
USE CATALOG retail_demo;

CREATE OR REFRESH MATERIALIZED VIEW rejected_rows.orders
AS SELECT
  'silver'                        AS source_layer,
  order_id,
  order_date_clean                AS order_date,
  customer_id,
  product_id,
  quantity_clean                  AS quantity,
  unit_price_clean                AS unit_price,
  region_clean                    AS region,
  CASE
    WHEN order_date_clean IS NULL THEN 'order_date_error'
    WHEN unit_price_clean IS NULL THEN 'unit_price_error'
    WHEN region_clean     IS NULL THEN 'region_error'
    WHEN quantity_clean   IS NULL THEN 'quantity_error'
  END                              AS rejection_reason,
  current_timestamp()              AS rejected_at
FROM silver.orders_parsed
WHERE order_date_clean IS NULL
   OR unit_price_clean IS NULL
   OR region_clean     IS NULL
   OR quantity_clean   IS NULL;