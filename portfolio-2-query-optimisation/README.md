# Portfolio 2: Query Processing and Optimisation

## Steps (run these yourself and paste the real output)
```bash
psql paywise -f seed.sql
psql paywise -c "EXPLAIN (ANALYZE, BUFFERS) <query>"   # for each of Q1-Q5, BEFORE indexes -> save as plans/before-qN.txt
psql paywise -f indexes.sql
psql paywise -c "EXPLAIN (ANALYZE, BUFFERS) <query>"   # AFTER indexes -> save as plans/after-qN.txt
```

## What the queries demonstrate
| Query | Concept | Expected optimisation |
|---|---|---|
| Q1 | OR predicate + ORDER BY/LIMIT | Seq Scan + sort -> composite indexes on (from_account, created_at DESC) and (to_account, created_at DESC); planner can use BitmapOr |
| Q2 | Range filter + aggregate | Partial index on created_at WHERE status='SUCCESS' |
| Q3 | 3-way join + group by | Hash joins; index on accounts(customer_id) helps; mostly aggregation cost |
| Q4 | FILTER aggregate | Full scan is expected (touches most rows); index will not help; explain why |
| Q5 | Window function | Uses index on (from_account, created_at) |

## Performance analysis (fill in with YOUR numbers)
| Query | Before (ms) | After (ms) | Plan change |
|---|---|---|---|
| Q1 |262.5 | |Seq Scan |
| Q2 | 55.6| | Seq Scan|
| Q3 | 839.5| | Seq Scan + Hash Joins|
| Q4 |700.2 | | Seq Scan + Hash Joins|
| Q5 | 160.0| | Seq Scan|

Write 1 short paragraph per query: what the plan was (Seq Scan / Index Scan / Bitmap), why it changed, and one case where an index did NOT help and why (Q4). Mention the write-cost trade-off of extra indexes.
