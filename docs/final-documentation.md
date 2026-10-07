# MIT 8103 Advanced Database Systems: Portfolio Summary

**Student:** [Name] | **Matric No:** [ ] | **GitHub:** [link] (private, assessor invited)

## Selected organisation
PayWise, a simulated digital bank. Users: customers, support staff, auditors, fraud analysts. Data: customers, accounts, transfers, ledger entries, audit logs, transaction events. Operations: open account, transfer funds, reverse failed transfers, statements, audit balances, fraud review.

## Portfolio 1: Design (summary)
[3-4 sentences: ER design choices, 5 tables, keys/constraints, normalised to 3NF/BCNF, deliberate denormalisation of balance. Include ER screenshot.]

## Portfolio 2: Query optimisation
[3-4 sentences with YOUR numbers: e.g. "Q1 dropped from X ms (Seq Scan) to Y ms (Index Scan) after composite indexes." Mention one case where indexing did not help.]

## Portfolio 3: Transactions and concurrency
[3-4 sentences: transfer_funds as atomic unit, rollback on insufficient funds, lost update reproduced and fixed with FOR UPDATE, deadlock avoided by lock ordering. Include screenshots.]

## Portfolio 4: NoSQL
[3-4 sentences: MongoDB document model for events/profiles, why it fits, why balances remain relational. Include explain output.]

## Portfolio 5: Distributed/cloud
[3-4 sentences: 3-node replica set and failover test, sharding key reasoning, CP for ledger vs AP for events, multi-AZ cloud design.]

## Individual technical reflection (write this yourself, about 150-200 words)
Cover: one design choice you made and why; one real problem you hit while running the scripts and how you fixed it; one thing you would do differently; what you learned about trade-offs. Be specific, since this is what protects you in a verification discussion.

## AI Use Declaration
- **Tool used:** Claude (Anthropic).
- **Used for:** drafting initial schema, SQL/Mongo scripts, test scenarios and documentation templates.
- **Verification by me:** [edit to match what you REALLY did: ran every script on my own PostgreSQL/MongoDB instance, generated my own execution plans and screenshots, fixed errors X and Y, rewrote analysis and reflection in my own words.]

## References
PostgreSQL Documentation (v16): EXPLAIN, Transaction Isolation, Explicit Locking. MongoDB Manual: Replication, Sharding, Aggregation. Kleppmann, M. (2017) Designing Data-Intensive Applications. O'Reilly.
