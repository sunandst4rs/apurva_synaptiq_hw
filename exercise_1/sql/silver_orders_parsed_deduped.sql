--loading orders from bronze. latest file wins for duplicated order.
--inline parsing / type-checking for order date, unit price, quantity and region

USE CATALOG retail_demo;

CREATE OR REFRESH MATERIALIZED VIEW silver.orders_parsed
AS
WITH deduped AS (
  SELECT * EXCEPT(rn) FROM (
    SELECT o.*,
      row_number() OVER (
        PARTITION BY order_id
        ORDER BY _metadata.file_modification_time DESC, _metadata.file_name DESC
      ) AS rn
    FROM bronze.orders o
  )
  WHERE rn = 1
)
SELECT
  order_id,
  CASE
    WHEN order_date RLIKE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN to_date(order_date, 'yyyy-MM-dd')
    WHEN order_date RLIKE '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN to_date(order_date, 'MM/dd/yyyy')
    WHEN order_date RLIKE '^[0-9]{10}$'                  THEN to_date(timestamp_seconds(cast(order_date AS BIGINT)))
    ELSE NULL
  END AS order_date_clean,
  customer_id,
  product_id,
  try_cast(quantity AS DECIMAL(10,2)) AS quantity_clean,
  cast(regexp_replace(unit_price, '[$,]', '') AS DECIMAL(10,2)) AS unit_price_clean,
  initcap(trim(region)) AS region_clean,
  _rescued_data
FROM deduped;