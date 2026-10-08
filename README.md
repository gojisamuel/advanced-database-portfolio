# MIT 8103 Advanced Database Systems Portfolio

**Case study:** PayWise (simulated fintech / digital bank)
**Stack:** PostgreSQL 16 (relational), MongoDB 7 (NoSQL), Docker (distributed exercise)

| Folder | Activity |
|---|---|
| portfolio-1-database-design | Case study, ER diagram, schema, normalisation |
| portfolio-2-query-optimisation | Queries, EXPLAIN plans, indexes, analysis |
| portfolio-3-transactions-concurrency | Commit/rollback, isolation, locking, deadlock |
| portfolio-4-nosql | MongoDB model, implementation, suitability |
| portfolio-5-distributed-cloud | Replica set, sharding, CAP discussion |
| docs | Final 2-3 page summary, reflection, AI declaration |

## How to run
```bash
createdb paywise
psql paywise -f portfolio-1-database-design/schema.sql
psql paywise -f portfolio-2-query-optimisation/seed.sql
```
Each portfolio folder has its own README explaining what was implemented and tested, plus a `screenshot` folder with the evidence (query plans, transaction tests, replica set status and so on).

## Notes
- All five portfolios use the same case study, PayWise, a simulated digital bank.
- Work was committed progressively throughout the project.
- The 2-3 page summary, individual reflection and AI Use Declaration are in the `docs` folder and in the LMS submission.
