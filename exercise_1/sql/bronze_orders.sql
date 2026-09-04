--create the orders table to use with autoloader
USE CATALOG retail_demo;

CREATE OR REFRESH STREAMING TABLE bronze.orders (
  order_id             STRING,
  order_date           STRING,
  customer_id          STRING,
  product_id           STRING,
  quantity             STRING,
  unit_price           STRING,
  region               STRING,
  _rescued_data        STRING,
  source_file          STRING,
  source_file_modified TIMESTAMP
)
AS SELECT
  *,
  _metadata.file_name AS source_file,
  _metadata.file_modification_time AS source_file_modified
FROM STREAM read_files(
  '/Volumes/retail_demo/bronze/landing/orders/',
  format => 'csv',
  header => true,
  schema => 'order_id STRING, order_date STRING, customer_id STRING, product_id STRING, quantity STRING, unit_price STRING, region STRING',
  rescuedDataColumn => '_rescued_data'
);