# Portfolio 2: Query Processing and Optimisation

## Steps 
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

## Performance analysis 
| Query | Before (ms) | After (ms) | Plan change |
|---|---|---|---|
| Q1 | 262.5 | 0.9 | Seq Scan -> Bitmap Index Scan (BitmapOr of two indexes) |
| Q2 | 55.6 | 13.8 | Seq Scan -> Bitmap Index Scan (partial index) |
| Q3 | 839.5 | 222.0 | Seq Scan + Hash Joins (unchanged) |
| Q4 | 700.2 | 188.0 | Seq Scan + Hash Join (unchanged) |
| Q5 | 160.0 | 0.3 | Seq Scan -> Bitmap Index Scan |

**Q1 (262.5 ms -> 0.9 ms, about 277x faster):** Before indexing, PostgreSQL scanned all 200,000 rows to find account 123. After adding indexes on (from_account, created_at) and (to_account, created_at), it used a BitmapOr of two index scans and read only the matching rows.

**Q2 (55.6 ms -> 13.8 ms, about 4x faster):** The partial index on created_at (for successful transfers only) replaced the full scan with a Bitmap Index Scan.

**Q5 (160.0 ms -> 0.3 ms, about 490x faster):** The index on from_account let PostgreSQL jump straight to the account's rows.

**Q3 and Q4 (about 3.7x faster, plan unchanged):** Both queries aggregate over most of the table, so the plan still uses a Parallel Seq Scan and Hash Joins, and the new indexes were not used. The faster times are most likely due to caching, because the data was already in memory on the second run, so this is not an index improvement. Q4 is the case where an index does not help.

**Trade-off:** Each index uses disk space and slows INSERT and UPDATE operations, because every index must be updated too. Creating the four indexes took between 7 ms and 353 ms here.