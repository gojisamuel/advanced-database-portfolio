# Portfolio 3: Transactions and Concurrency

Run order: load `transfer_funds.sql`, then `01_commit_rollback.sql`, then the two-session scripts (`02`, `03`) in two terminals.

## ACID mapping
- **Atomicity:** debit + credit + transfer row + ledger rows succeed or fail together (script 01, B).
- **Consistency:** CHECK (balance >= 0), FKs and the insufficient-funds check keep invariants.
- **Isolation:** lost update, non-repeatable read, deadlock demos (02, 03).
- **Durability:** WAL; committed data survives restart (optional: restart Postgres and re-query).

## Concurrency control used
Pessimistic row locking (`FOR UPDATE`) with deterministic lock ordering; REPEATABLE READ plus retry as an alternative.


## Evidence 
1. 01-commit-success: balances before and after a committed transfer
2. 02-rollback-failed: failed transfer rolled back, balances unchanged
3. 03-lost-update-problem: lost update (800 instead of 500)
4. 04-lost-update-fixed: fixed with SELECT ... FOR UPDATE (500)
5. 05-read-committed: balance changes inside one transaction (5000 then 6000)
6. 06-repeatable-read: balance stays 5000 inside the transaction
7. 07-deadlock: "deadlock detected" error

## Analysis
The transfer_funds function groups the debit, credit and ledger entries into one transaction, so either all of it happens or none of it does (atomicity). The lost update showed that two sessions working from the same old balance can overwrite each other. Locking the row with FOR UPDATE makes the second session wait and read the new balance. REPEATABLE READ gives a stable snapshot inside a transaction, which prevents the balance changing between two reads. The deadlock happened because the two sessions locked the accounts in opposite order. The transfer_funds function avoids this by always locking accounts in order of account_id.
