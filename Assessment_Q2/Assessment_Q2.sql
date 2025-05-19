-- Categorize customers based on average transactions per month
WITH all_transactions AS (
    -- Merge savings and withdrawal transactions
    SELECT owner_id, created_on FROM savings_savingsaccount
    UNION ALL
    SELECT owner_id, created_on FROM withdrawals_withdrawal
),
user_activity AS (
    -- Calculate total transactions and active months per user
    SELECT
        owner_id,
        COUNT(*) AS total_txns,
        -- Compute active duration in months; ensure at least 1
        GREATEST(TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1, 1) AS months_active
    FROM all_transactions
    GROUP BY owner_id
),
user_frequency AS (
    -- Compute avg monthly transaction rate and categorize
    SELECT
        owner_id,
        total_txns / months_active AS avg_txn_per_month,
        CASE
            WHEN total_txns / months_active >= 10 THEN 'High Frequency'
            WHEN total_txns / months_active BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM user_activity
)
-- Final aggregation by category
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM user_frequency
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
