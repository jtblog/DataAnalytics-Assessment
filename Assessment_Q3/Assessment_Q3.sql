-- Inactive savings/investment plans: no transactions in past 365 days
WITH all_transactions AS (
    -- Combine inflows (savings) and outflows (withdrawals)
    SELECT plan_id, created_on FROM savings_savingsaccount
    UNION ALL
    SELECT plan_id, created_on FROM withdrawals_withdrawal
),
latest_txn_per_plan AS (
    -- Get the latest transaction per plan
    SELECT 
        plan_id,
        MAX(created_on) AS last_transaction_date
    FROM all_transactions
    GROUP BY plan_id
)
SELECT 
    p.id AS plan_id,
    s.owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,
    DATE(l.last_transaction_date) AS last_transaction_date,
    -- Use today's date minus last activity, or whole plan age if never transacted
    DATEDIFF(CURDATE(), COALESCE(l.last_transaction_date, p.created_on)) AS inactivity_days
FROM plans_plan p
JOIN savings_savingsaccount s ON s.plan_id = p.id
LEFT JOIN latest_txn_per_plan l ON l.plan_id = p.id
WHERE 
    (p.is_regular_savings = 1 OR p.is_a_fund = 1)
    AND (
        l.last_transaction_date IS NULL OR 
        l.last_transaction_date < CURDATE() - INTERVAL 365 DAY
    )
GROUP BY p.id, s.owner_id, type, last_transaction_date
ORDER BY inactivity_days DESC;
