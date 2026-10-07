-- A. Successful transfer (COMMIT)
SELECT account_id, balance FROM accounts WHERE account_id IN (1,2);
BEGIN;
SELECT transfer_funds(1, 2, 500.00, 'DEMO-COMMIT-1');
COMMIT;
SELECT account_id, balance FROM accounts WHERE account_id IN (1,2);   -- balances moved
SELECT * FROM ledger_entries WHERE transfer_id = (SELECT max(transfer_id) FROM transfers);
SELECT * FROM audit_log ORDER BY audit_id DESC LIMIT 2;

-- B. Failed transfer (automatic ROLLBACK): insufficient funds
BEGIN;
SELECT transfer_funds(1, 2, 999999999.00, 'DEMO-FAIL-1');   -- raises exception
ROLLBACK;
SELECT account_id, balance FROM accounts WHERE account_id IN (1,2);   -- unchanged

-- C. Manual rollback with SAVEPOINT
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
SAVEPOINT before_credit;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
ROLLBACK TO SAVEPOINT before_credit;   -- credit undone, debit still pending
ROLLBACK;                              -- everything undone
SELECT account_id, balance FROM accounts WHERE account_id IN (1,2);
