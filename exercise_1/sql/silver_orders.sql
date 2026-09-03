--the good records from bronze, and check that quantity is not 0 (-1 could be a return?)

USE CATALOG retail_demo;

CREATE OR REFRESH MATERIALIZED VIEW silver.orders (
  CONSTRAINT nonzero_quantity EXPECT (quantity_clean != 0)
)
AS SELECT *
FROM silver.orders_parsed
WHERE order_date_clean IS NOT NULL
  AND unit_price_clean IS NOT NULL
  AND region_clean     IS NOT NULL
  AND quantity_clean    IS NOT NULL;