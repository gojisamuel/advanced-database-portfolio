# Portfolio 5: Distributed and Cloud Database Exercise

## Setup (hands-on): 3-node MongoDB replica set
Files: `docker-compose.yml`, `init-replica.sh`, `failover-test.md`. Provides replication, automatic failover, and write concern demonstration.

## Discussion for PayWise

### Replication
- **PostgreSQL ledger:** one primary + 1-2 streaming-replication standbys. Synchronous replication to one standby (`synchronous_commit = on` with a sync standby) so no committed transfer is lost on failover; additional async replicas serve read-only reporting queries.
- **MongoDB events:** 3-node replica set (shown above). Use `w: "majority"` for writes that matter, `readConcern: "majority"` where stale reads are unacceptable.

### Sharding
- **Candidate key for `transaction_events`:** `from_account` hashed. Spreads writes evenly and keeps one account's history on one shard for targeted reads. `created_at` alone would make a hot shard (monotonic key); a compound `{from_account: 1, created_at: 1}` supports statement queries.
- **Postgres:** shard by customer/account range with Citus or application-level routing if scale demands; cross-shard transfers then need two-phase commit or a saga, so keep the ledger on a single primary as long as possible.

### CAP / consistency choices
- **Ledger (balances):** CP. Prefer rejecting a transfer during a partition over risking double-spend. Strong consistency, synchronous replication.
- **Events/analytics/notifications:** AP-leaning. Eventual consistency is acceptable; availability and throughput matter more.
- PACELC angle: even without partitions, synchronous replication adds latency; accepted for money movement.

### Availability and cloud deployment
- Multi-AZ deployment: Amazon RDS PostgreSQL Multi-AZ (or Azure/GCP equivalent) + MongoDB Atlas 3-node replica set across zones. RPO ~0 for the ledger, RTO under ~2 minutes with automatic failover.
- Backups: PITR (WAL archiving) with daily snapshots; cross-region copy for disaster recovery.
- Security/compliance: encryption at rest and in transit, private networking, IAM roles, audit logging (fintech regulatory expectation).
- Cost/ops trade-off: managed services reduce operational burden; self-hosting offers control but needs DBAs.

### Deployment evidence (optional, strengthens marks)
Free-tier MongoDB Atlas cluster or Neon/Supabase Postgres: screenshot of cluster topology page and a connection test.
