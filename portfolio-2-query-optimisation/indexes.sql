CREATE INDEX idx_transfers_from_created ON transfers(from_account, created_at DESC);
CREATE INDEX idx_transfers_to_created   ON transfers(to_account, created_at DESC);
CREATE INDEX idx_transfers_success_created ON transfers(created_at) WHERE status = 'SUCCESS';
CREATE INDEX idx_accounts_customer ON accounts(customer_id);
ANALYZE;
