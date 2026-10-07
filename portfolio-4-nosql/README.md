# Portfolio 4: NoSQL and Advanced Data Models

**Model type:** Document (MongoDB), with a note on key-value (Redis) as an extension.

## What goes in NoSQL (same PayWise case study)
- `transaction_events`: an immutable, wide event record per transfer, with nested device, geo and fraud data. Schema varies by channel (USSD has no device OS; POS has terminal id).
- `customer_profiles`: nested preferences and an embedded `beneficiaries` array.

Money movement and balances stay in PostgreSQL (needs ACID, joins, constraints). MongoDB stores high-volume, semi-structured event/profile data for analytics and fraud review.

## Run
```bash
docker run -d --name mongo -p 27017:27017 mongo:7
mongosh paywise_nosql seed.js
mongosh paywise_nosql queries.js
```

## Suitability explanation (adapt in your own words)
- **Why document:** events are written once and read whole; embedding avoids joins; flexible schema absorbs new channels/fraud fields without migrations.
- **Why not for balances:** multi-document ACID is possible but costly; the relational model with row locks is simpler and safer for the ledger.
- **Trade-offs:** data duplication (account ids are references, not enforced FKs), eventual sync between systems, no cross-collection constraints.
- **Alternatives considered:** Redis (fast balance/session cache or rate limiting), Neo4j (graph of transfers to detect money-mule rings), Cassandra (time-series scale).

## Evidence to add
Screenshot of seed output, `explain("executionStats")` showing IXSCAN, and aggregation results.
