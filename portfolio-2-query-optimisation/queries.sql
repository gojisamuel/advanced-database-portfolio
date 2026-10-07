-- Q1: Recent activity for one account (account statement)
SELECT transfer_id, from_account, to_account, amount, status, created_at
FROM transfers
WHERE from_account = 123 OR to_account = 123
ORDER BY created_at DESC
LIMIT 20;

-- Q2: Daily successful transfer volume for the last 30 days
SELECT date_trunc('day', created_at) AS day, count(*) AS txns, sum(amount) AS volume
FROM transfers
WHERE status = 'SUCCESS' AND created_at >= now() - interval '30 days'
GROUP BY 1 ORDER BY 1;

-- Q3: Top 10 customers by outgoing transfer value (join + aggregate)
SELECT c.customer_id, c.full_name, sum(t.amount) AS total_sent
FROM transfers t
JOIN accounts a ON a.account_id = t.from_account
JOIN customers c ON c.customer_id = a.customer_id
WHERE t.status = 'SUCCESS'
GROUP BY c.customer_id, c.full_name
ORDER BY total_sent DESC
LIMIT 10;

-- Q4: Failure rate per account type (fraud/ops monitoring)
SELECT a.account_type,
       count(*) FILTER (WHERE t.status = 'FAILED')::numeric / count(*) AS failure_rate
FROM transfers t JOIN accounts a ON a.account_id = t.from_account
GROUP BY a.account_type;

-- Q5: Running total of an account's outgoing transfers (window function)
SELECT transfer_id, created_at, amount,
       sum(amount) OVER (ORDER BY created_at) AS running_total
FROM transfers
WHERE from_account = 123 AND status = 'SUCCESS'
ORDER BY created_at;
