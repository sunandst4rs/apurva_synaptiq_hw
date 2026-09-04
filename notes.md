Assumptions and judgement calls
Net revenue = quantity × unit_price per order. Negative quantity is treated as a return and allowed to reduce revenue — that's why it's net revenue, not gross.
"Per day" means the order's own date, not the date its file arrived. One order (O1003) is corrected a day after it was placed. Grouping by order date (after keeping only the latest version of each order) puts the correction on the right day.
A later file wins. Same order_id appearing in two files is treated as a correction, not a new order — the most recently loaded version is kept, everything else is dropped before aggregation.
Rows missing something required (price, region, date, quantity) are set aside, not dropped. They go to a separate rejected_rows.orders table with a reason, so nothing disappears silently.
Zero-quantity orders are kept, just flagged. Could be a legitimate $0 order — not enough context to call it invalid, so it's surfaced rather than deleted.
Products with no match in the reference file are kept as "Unmapped." A revenue table that quietly drops orders because of a bad product ID is worse than one with an "Unmapped" line you can go investigate.
Region and category casing is normalized (West/west → West). Otherwise these split into separate rows in the final table.
What in the data shaped the design
One order row has an extra, unlabeled field. It's real, not a hypothetical — severe enough that a naive CSV read fails on it entirely. The pipeline has to decide upfront how to handle a malformed row, not patch it in after the fact.
Order dates show up in three different formats across the two files, including a raw Unix timestamp. That ruled out a single date cast and required explicit format detection.
The same order reappearing across files, sometimes changed, is the reason the pipeline can't just append new files — it has to resolve duplicates before anything gets counted.
What I'd do differently with more time or at real scale
Move the parsing rules (dates, prices) into shared, testable logic instead of inline SQL, so a new date format doesn't mean hunting through the query.
Monitor the rejected and "Unmapped" counts over time — a spike in either usually means something changed upstream.
Confirm the zero- and negative-quantity handling with whoever owns the order system, rather than assuming.
At high order volume, revisit the dedup approach — a keyed upsert scales better than rescanning everything on each run.