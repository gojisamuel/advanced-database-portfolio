# Portfolio 3: Transactions and Concurrency

Run order: load `transfer_funds.sql`, then `01_commit_rollback.sql`, then the two-session scripts (`02`, `03`) in two terminals.

## ACID mapping
- **Atomicity:** debit + credit + transfer row + ledger rows succeed or fail together (script 01, B).
- **Consistency:** CHECK (balance >= 0), FKs and the insufficient-funds check keep invariants.
- **Isolation:** lost update, non-repeatable read, deadlock demos (02, 03).
- **Durability:** WAL; committed data survives restart (optional: restart Postgres and re-query).

## Concurrency control used
Pessimistic row locking (`FOR UPDATE`) with deterministic lock ordering; REPEATABLE READ plus retry as an alternative.

## Evidence to add (your own screenshots)
1. Balances before/after COMMIT. 2. Rollback leaving balances unchanged. 3. Lost update result (800 instead of 500). 4. Fixed result (500). 5. Deadlock error message. 6. Reconciliation query output.

## Short analysis (write in your own words)
Explain when you would choose locking versus snapshot isolation + retry for a banking workload, and the throughput cost of locking hot accounts.
