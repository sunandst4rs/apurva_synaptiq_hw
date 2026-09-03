--create the products table to use with autoloader
USE CATALOG retail_demo;

CREATE OR REFRESH MATERIALIZED VIEW bronze.products
AS SELECT * FROM read_files(
  '/Volumes/retail_demo/bronze/landing/products/',
  format => 'csv',
  header => true
);