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

### Deployment evidence
The hands-on evidence for this portfolio is the local 3-node MongoDB replica set run with Docker Compose (see the Evidence section below). Cloud deployment on MongoDB Atlas and Amazon RDS is discussed above as the production design, but was not deployed for this exercise.

## Evidence (screenshots in the screenshot folder)
1. 01-three-containers: three MongoDB containers running with Docker Compose
2. 02-replica-set-status: replica set rs0 with mongo1 PRIMARY, mongo2 and mongo3 SECONDARY
3. 03-failover-new-primary: after stopping mongo1, mongo2 was elected PRIMARY
4. 04-data-survived: the document written before failover was still readable
5. 05-node-rejoined: mongo1 restarted and rejoined the replica set

## Analysis of the hands-on test
I ran a 3-node MongoDB replica set with Docker Compose. I wrote a document with write concern "majority", so it was confirmed by most nodes before I stopped the primary (mongo1). The remaining nodes elected mongo2 as the new primary within seconds, and the document was still readable, so no acknowledged write was lost. When I restarted mongo1, it rejoined the set. Because mongo1 was configured with a higher priority (2), it took back the PRIMARY role. This shows high availability through replication and automatic failover, and it shows the consistency choice: a write is acknowledged only after a majority has it, which favours consistency over raw speed (a CP-style choice for important data).