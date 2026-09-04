# Overriding and Guiding the AI model

For the follow-up conversation: this is a record of where I directed, corrected,
simplified, or overrode the AI's suggestions during this build. Organized by
category rather than strict chronological order.

## Scope and architecture decisions I made

- Chose to build natively on Databricks instead of the brief's suggested
  Postgres/local PySpark path — using DBX free edition.
- Decided the pharma_demo project (another of my DBX project's repo) and this exercise are separate workstreams
  and explicitly declined adding an `ops` schema just for structural parity
  with that other project — rejected scope creep that wasn't justified by
  this exercise's actual requirements.
- Set the scope boundary on Excel files: rather than build full Excel-parsing
  robustness into the pipeline, decided the pipeline expects CSV going forward,
  with Excel handled as a one-time bootstrap exception. Wrote that decision
  in my own words for NOTES.md (Flag 2).
- Decided to move source CSV/xlsx files out of the git repo and into a Unity
  Catalog volume, rather than leaving data files committed to version control.
- Made the repo-structure call to separate "files the client gave us"
  (`exercise_source_files/`) from "what I produced" (`sql/`, `output/`).

## Places I caught something the AI got wrong or was inconsistent about

- **Caught an unjustified inconsistency**: asked "why aren't we doing this for
  orders as well? why only products?" when bronze.products was given a looser
  schema than bronze.orders with no stated reason — this led directly to
  fixing bronze.products to match the same all-STRING discipline.
- **Caught a real data-loss risk**: when told to "drop the column and log it,"
  I asked "if we receive a column like this and drop it before ingestion, do
  we risk losing data?" — this caught that the AI's proposed fix (blindly
  dropping any "Unnamed:" column) would have silently discarded the EXTRA_FLAG
  values, and forced the log-then-drop redesign instead.
- **Found the actual bug myself**: ran the pipeline, hit a real
  `DELTA_INVALID_CHARACTERS_IN_COLUMN_NAMES` error, and brought the exact
  error message back for diagnosis — this wasn't hypothetical troubleshooting,
  it was a real failure I encountered and reported precisely.
- Independently noticed the negative-quantity row (`O2004`) in the source data
  and asked whether the pipeline handled it, rather than being told about it.

## Design decisions I initiated or redirected

- Proposed a simpler rejected-rows schema myself ("can the rejected rows table
  have a column for row and then another for what layer it came from?") after
  finding the AI's original JSON-blob design unclear — this became the actual
  design.
- Asked "is there a more friendly output than json_struct" — drove the later
  simplification from a single JSON blob column to plain, readable columns.
- Challenged file structure directly ("why do I need
  staging_silver_orders_parsed.sql") and then asked to reduce complexity,
  which led to merging the dedup and parsing steps into one file instead of two.
- Decided the file/schema naming conventions throughout — dropped `staging_`
  prefix once out of bronze, chose `silver_` prefix explicitly, picked
  `rejected_rows` as the schema name after asking for alternatives to
  "quarantine."
- Made the explicit call to keep bronze and silver split cleanly (asked
  clarifying questions about whether these SQL files were one-time DDL or
  re-run per pipeline trigger, which shaped the file-splitting decision).

## Judgement calls I wrote myself (verbatim, then logged as flags)

I set up a running "flag" system specifically so every debatable decision
would be traceable back to reasoning, not just asserted after the fact:

- **Flag 2** (Excel scope decision) — written by me, in my own words, not
  drafted by the AI first.
- **Flag 4** (negative quantity as a likely return) — same, written by me
  after independently spotting the row.
- **Flag 5** (customer_id vs. required-field logic) — same, articulating the
  underlying principle (only fields in the gold grain or feeding an output
  metric are rejection-worthy) in my own words.

## Verification and gap-checks I initiated

- Asked directly whether the xlsx and csv versions of the same file actually
  contained identical data, rather than assuming — this got verified with an
  actual diff, not just asserted.
- Asked "are we missing anything asked in candidate.md?" as a final gap-check
  against the original brief before considering the submission done — this
  surfaced the missing Postgres-deviation justification and the stale output
  table issue before submission, not after.
- Asked for NOTES.md to be rewritten in simpler, more succinct language —
  an explicit editorial/communication-quality decision, not a technical one.
