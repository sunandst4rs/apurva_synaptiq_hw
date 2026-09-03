--create the orders table to use with autoloader
USE CATALOG retail_demo;

CREATE OR REFRESH STREAMING TABLE bronze.orders
AS SELECT * FROM STREAM read_files(
  '/Volumes/retail_demo/bronze/landing/orders/',
  format => 'csv',
  header => true
);