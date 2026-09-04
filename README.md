# Daily Order Sales Pipeline

## The scenario

We receive daily order exports and a product reference file from a client, in a mix of CSV and Excel formats. Their data isn't clean: inconsistent formatting, occasional missing fields, and corrections that arrive a day after the original order, so the goal was to build something that produces a reliable daily sales summary despite that, without needing manual cleanup each time a new file lands.

## Our approach

The solution is built natively in Databricks, using Unity Catalog to organize the data and a medallion architecture (bronze → silver → gold) to move it from raw files to something analysis-ready. Each layer has one clear job: land the data untouched, clean and validate it, then summarize it — to ensure observability and ability to trace an error at the layer it occurs. New files flow through the same pipeline automatically; nothing needs to be rebuilt as new days of data arrive.

## The layers

**Bronze** lands the raw files exactly as received — no interpretation, no cleanup. This preserves an unaltered copy of what the client actually sent, and it's where Databricks automatically detects anything structurally unusual about an incoming file (like an extra, unexpected field) without stopping the pipeline.

**Silver** is where the real work happens: dates, prices, and regions get standardized into consistent formats, and duplicate or corrected orders are resolved so each order is only counted once, using its most recent version. Rows that can't be reliably cleaned (for example, missing a price or region) are set aside into a separate table rather than silently dropped, so nothing disappears without a record of why.

**Gold** is the final output: daily sales totals broken out by product category and region, giving net revenue, order count, units sold, and average order value — ready to hand off for reporting or analysis.

## On The Use of AI

This project was assisted by a chat based LLM (not an IDE based coding assistant). The model was helpful primarily in the rapid creation of DDL and DML. It had access to the exercise files, and took a 'by the book approach' to some of the design that I had to override. Please see the AI-use-notes.md file for more detailed information. 
