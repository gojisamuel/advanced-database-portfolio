-- ===== Non-repeatable read (READ COMMITTED, the default) =====
-- 1 [A] BEGIN;  SELECT balance FROM accounts WHERE account_id = 20;     -- e.g. 5000
-- 2 [B] UPDATE accounts SET balance = balance + 1000 WHERE account_id = 20;  (autocommit)
-- 3 [A] SELECT balance FROM accounts WHERE account_id = 20;             -- now 6000: same query, different result
-- 4 [A] COMMIT;

-- ===== Same test with REPEATABLE READ =====
-- 1 [A] BEGIN ISOLATION LEVEL REPEATABLE READ;  SELECT balance ... WHERE account_id = 20;   -- 6000
-- 2 [B] UPDATE accounts SET balance = balance + 1000 WHERE account_id = 20;
-- 3 [A] SELECT balance ... ;     -- still 6000 (snapshot)
-- 4 [A] COMMIT;  SELECT balance ... ;   -- now 7000

-- ===== Deadlock =====
-- 1 [A] BEGIN; UPDATE accounts SET balance = balance - 10 WHERE account_id = 30;
-- 2 [B] BEGIN; UPDATE accounts SET balance = balance - 10 WHERE account_id = 31;
-- 3 [A] UPDATE accounts SET balance = balance + 10 WHERE account_id = 31;   -- waits for B
-- 4 [B] UPDATE accounts SET balance = balance + 10 WHERE account_id = 30;   -- ERROR: deadlock detected
-- PostgreSQL aborts one transaction; the other proceeds.
-- Prevention: always lock rows in a consistent order (what transfer_funds() does with ORDER BY account_id).

-- ===== Reconciliation (audit) after tests =====
SELECT a.account_id, a.balance AS stored,
       COALESCE(sum(CASE l.direction WHEN 'CREDIT' THEN l.amount ELSE -l.amount END),0) AS ledger_net
FROM accounts a LEFT JOIN ledger_entries l ON l.account_id = a.account_id
WHERE a.account_id IN (1,2)
GROUP BY a.account_id, a.balance;
