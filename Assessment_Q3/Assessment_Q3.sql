WITH all_transactions AS (
    -- Combine all transaction dates from savings and withdrawals per plan
    SELECT
        plan_id,
        transaction_date
    FROM
        savings_savingsaccount
    UNION ALL
    SELECT
        plan_id,
        transaction_date
    FROM
        withdrawals_withdrawal
),
last_txn AS (
    -- Find the latest transaction date per plan
    SELECT
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM
        all_transactions
    GROUP BY
        plan_id
),
active_plans AS (
    -- Filter active savings and investment plans
    SELECT
        id AS plan_id,
        owner_id,
        CASE
            WHEN is_regular_savings = 1 THEN 'Savings'
            WHEN is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type
    FROM
        plans_plan
    WHERE
        is_deleted = 0
        AND is_archived = 0
        AND (is_regular_savings = 1 OR is_a_fund = 1)
)
SELECT
    p.plan_id,
    p.owner_id,
    p.type,
    lt.last_transaction_date,
    DATEDIFF(CURDATE(), lt.last_transaction_date) AS inactivity_days
FROM
    active_plans p
LEFT JOIN
    last_txn lt ON p.plan_id = lt.plan_id
WHERE
    lt.last_transaction_date IS NULL
    OR lt.last_transaction_date <= DATE_SUB(CURDATE(), INTERVAL 365 DAY)
ORDER BY
    inactivity_days DESC;
