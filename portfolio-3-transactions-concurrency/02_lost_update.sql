-- LOST UPDATE DEMO. Open TWO psql sessions (A and B). Run lines in the numbered order.
-- Setup (either session):  UPDATE accounts SET balance = 1000 WHERE account_id = 10;

-- ===== PART 1: the problem (no locking, READ COMMITTED) =====
-- 1 [A] BEGIN;
-- 2 [A] SELECT balance FROM accounts WHERE account_id = 10;          -- sees 1000
-- 3 [B] BEGIN;
-- 4 [B] SELECT balance FROM accounts WHERE account_id = 10;          -- sees 1000
-- 5 [A] UPDATE accounts SET balance = 1000 - 300 WHERE account_id = 10;   -- app computed 700
-- 6 [A] COMMIT;
-- 7 [B] UPDATE accounts SET balance = 1000 - 200 WHERE account_id = 10;   -- app computed 800 from stale read
-- 8 [B] COMMIT;
-- 9 SELECT balance FROM accounts WHERE account_id = 10;   -- 800, A's withdrawal of 300 is LOST (should be 500)

-- ===== PART 2: the fix with pessimistic locking =====
-- Reset: UPDATE accounts SET balance = 1000 WHERE account_id = 10;
-- 1 [A] BEGIN;
-- 2 [A] SELECT balance FROM accounts WHERE account_id = 10 FOR UPDATE;
-- 3 [B] BEGIN;
-- 4 [B] SELECT balance FROM accounts WHERE account_id = 10 FOR UPDATE;    -- BLOCKS
-- 5 [A] UPDATE accounts SET balance = balance - 300 WHERE account_id = 10;
-- 6 [A] COMMIT;                                                            -- B unblocks, sees 700
-- 7 [B] UPDATE accounts SET balance = balance - 200 WHERE account_id = 10;
-- 8 [B] COMMIT;
-- 9 SELECT balance ...  -- 500, correct

-- ===== PART 3: alternative fix, REPEATABLE READ =====
-- Both sessions: BEGIN ISOLATION LEVEL REPEATABLE READ; SELECT ...; UPDATE ... ;
-- The second committer gets: ERROR: could not serialize access due to concurrent update
-- Application must retry the transaction.
