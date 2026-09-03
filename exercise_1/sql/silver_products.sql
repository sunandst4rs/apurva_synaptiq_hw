--load products from bronze
--some product names are mixed case, so normalize using initcap
USE CATALOG retail_demo;

CREATE OR REFRESH MATERIALIZED VIEW silver.products (
  CONSTRAINT valid_product_id EXPECT (product_id IS NOT NULL) ON VIOLATION DROP ROW
)
AS SELECT
  product_id,
  product_name,
  initcap(trim(category)) AS category,
  cast(list_price AS DECIMAL(10,2)) AS list_price
FROM bronze.products;