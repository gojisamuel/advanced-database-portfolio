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

## Suitability explanation
- **Why document:** events are written once and read whole; embedding avoids joins; flexible schema absorbs new channels/fraud fields without migrations.
- **Why not for balances:** multi-document ACID is possible but costly; the relational model with row locks is simpler and safer for the ledger.
- **Trade-offs:** data duplication (account ids are references, not enforced FKs), eventual sync between systems, no cross-collection constraints.
- **Alternatives considered:** Redis (fast balance/session cache or rate limiting), Neo4j (graph of transfers to detect money-mule rings), Cassandra (time-series scale).


## Evidence (screenshots in the screenshot folder)
1. 01-seed-loaded: 50,000 events loaded into MongoDB
2. 02-sample-document: one event with nested device, geo, fraud_flags and metadata
3. 03-aggregation: volume and count by city and channel
4. 04-index-explain: 23 documents examined out of 50,000, 2 ms
5. 05-ixscan: winning plan uses IXSCAN on from_account_1_created_at_-1

## Analysis
I used a document database (MongoDB) for transaction events and customer profiles. Each event is stored as one self-contained document with nested device, geo, fraud_flags and metadata fields, so reading an event needs no joins. The aggregation grouped successful events by geo.city and device.channel directly on nested fields. For the account history query, the compound index on (from_account, created_at) let MongoDB examine only 23 documents out of 50,000 (IXSCAN) in 2 ms, instead of scanning the whole collection. I kept balances and transfers in PostgreSQL because money movement needs ACID transactions, row locks and constraints, which the earlier portfolios demonstrated.