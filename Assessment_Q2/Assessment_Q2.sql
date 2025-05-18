WITH all_transactions AS (
    -- Combine transaction dates and owners from both savings and withdrawals
    SELECT owner_id, transaction_date FROM savings_savingsaccount
    UNION ALL
    SELECT owner_id, transaction_date FROM withdrawals_withdrawal
),
customer_transactions AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,
        MIN(transaction_date) AS first_txn_date,
        MAX(transaction_date) AS last_txn_date
    FROM
        all_transactions
    GROUP BY
        owner_id
),
customer_txn_stats AS (
    SELECT
        owner_id,
        total_transactions,
        -- Calculate months active, at least 1 to avoid division by zero
        GREATEST(
            TIMESTAMPDIFF(MONTH, first_txn_date, last_txn_date),
            1
        ) AS months_active,
        -- Average transactions per month
        total_transactions / GREATEST(
            TIMESTAMPDIFF(MONTH, first_txn_date, last_txn_date),
            1
        ) AS avg_txn_per_month
    FROM
        customer_transactions
),
categorized_customers AS (
    SELECT
        owner_id,
        avg_txn_per_month,
        -- Categorize customers based on average transaction frequency
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM
        customer_txn_stats
)
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month
FROM
    categorized_customers
GROUP BY
    frequency_category
ORDER BY
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
        ELSE 4
    END;
