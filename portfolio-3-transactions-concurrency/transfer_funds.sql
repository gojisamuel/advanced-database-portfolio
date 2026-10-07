CREATE OR REPLACE FUNCTION transfer_funds(p_from INT, p_to INT, p_amount NUMERIC, p_ref TEXT)
RETURNS BIGINT LANGUAGE plpgsql AS $$
DECLARE
    v_balance NUMERIC;
    v_id      BIGINT;
BEGIN
    -- Lock both rows in a consistent order (lowest id first) to prevent deadlocks
    PERFORM 1 FROM accounts WHERE account_id IN (p_from, p_to) ORDER BY account_id FOR UPDATE;

    SELECT balance INTO v_balance FROM accounts WHERE account_id = p_from;
    IF v_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds: balance %, requested %', v_balance, p_amount;
    END IF;

    UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_from;
    UPDATE accounts SET balance = balance + p_amount WHERE account_id = p_to;

    INSERT INTO transfers(from_account, to_account, amount, status, reference)
    VALUES (p_from, p_to, p_amount, 'SUCCESS', p_ref) RETURNING transfer_id INTO v_id;

    INSERT INTO ledger_entries(transfer_id, account_id, direction, amount, balance_after)
    SELECT v_id, p_from, 'DEBIT',  p_amount, balance FROM accounts WHERE account_id = p_from;
    INSERT INTO ledger_entries(transfer_id, account_id, direction, amount, balance_after)
    SELECT v_id, p_to,   'CREDIT', p_amount, balance FROM accounts WHERE account_id = p_to;

    RETURN v_id;
END $$;
