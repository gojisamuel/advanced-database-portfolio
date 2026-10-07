-- 1,000 customers, 2,000 accounts, 200,000 transfers
INSERT INTO customers(full_name, email, phone, kyc_status)
SELECT 'Customer ' || g, 'user' || g || '@paywise.test', '080' || lpad(g::text, 8, '0'),
       (ARRAY['PENDING','VERIFIED','VERIFIED','VERIFIED'])[1 + floor(random()*4)::int]
FROM generate_series(1,1000) g;

INSERT INTO accounts(customer_id, account_number, account_type, balance)
SELECT 1 + (g % 1000), lpad(g::text, 10, '0'),
       (ARRAY['SAVINGS','CURRENT','WALLET'])[1 + floor(random()*3)::int],
       round((1000 + random()*99000)::numeric, 2)
FROM generate_series(1,2000) g;

INSERT INTO transfers(from_account, to_account, amount, status, reference, created_at)
SELECT f, 1 + ((f - 1 + 1 + floor(random()*1999)::int) % 2000),
       round((100 + random()*50000)::numeric, 2),
       (ARRAY['SUCCESS','SUCCESS','SUCCESS','SUCCESS','FAILED','REVERSED'])[1 + floor(random()*6)::int],
       'REF-' || g,
       now() - (random() * interval '365 days')
FROM (SELECT g, 1 + floor(random()*2000)::int AS f FROM generate_series(1,200000) g) s;

ANALYZE;
