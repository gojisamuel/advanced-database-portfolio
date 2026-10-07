DROP TABLE IF EXISTS audit_log, ledger_entries, transfers, accounts, customers CASCADE;

CREATE TABLE customers (
    customer_id  SERIAL PRIMARY KEY,
    full_name    TEXT NOT NULL,
    email        TEXT NOT NULL UNIQUE,
    phone        TEXT,
    kyc_status   TEXT NOT NULL DEFAULT 'PENDING'
                 CHECK (kyc_status IN ('PENDING','VERIFIED','REJECTED')),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE accounts (
    account_id     SERIAL PRIMARY KEY,
    customer_id    INT NOT NULL REFERENCES customers(customer_id),
    account_number CHAR(10) NOT NULL UNIQUE,
    account_type   TEXT NOT NULL CHECK (account_type IN ('SAVINGS','CURRENT','WALLET')),
    currency       CHAR(3) NOT NULL DEFAULT 'NGN',
    balance        NUMERIC(15,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    status         TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','FROZEN','CLOSED')),
    opened_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE transfers (
    transfer_id  BIGSERIAL PRIMARY KEY,
    from_account INT NOT NULL REFERENCES accounts(account_id),
    to_account   INT NOT NULL REFERENCES accounts(account_id),
    amount       NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    status       TEXT NOT NULL DEFAULT 'PENDING'
                 CHECK (status IN ('PENDING','SUCCESS','FAILED','REVERSED')),
    reference    TEXT NOT NULL UNIQUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (from_account <> to_account)
);

CREATE TABLE ledger_entries (
    entry_id      BIGSERIAL PRIMARY KEY,
    transfer_id   BIGINT NOT NULL REFERENCES transfers(transfer_id),
    account_id    INT NOT NULL REFERENCES accounts(account_id),
    direction     TEXT NOT NULL CHECK (direction IN ('DEBIT','CREDIT')),
    amount        NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    balance_after NUMERIC(15,2) NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE audit_log (
    audit_id   BIGSERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    action     TEXT NOT NULL,
    record_id  INT,
    old_data   JSONB,
    new_data   JSONB,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Audit trigger: record every balance change
CREATE OR REPLACE FUNCTION log_balance_change() RETURNS trigger AS $$
BEGIN
    IF NEW.balance IS DISTINCT FROM OLD.balance THEN
        INSERT INTO audit_log(table_name, action, record_id, old_data, new_data)
        VALUES ('accounts','BALANCE_UPDATE', OLD.account_id,
                jsonb_build_object('balance', OLD.balance),
                jsonb_build_object('balance', NEW.balance));
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_balance_audit
AFTER UPDATE ON accounts
FOR EACH ROW EXECUTE FUNCTION log_balance_change();
