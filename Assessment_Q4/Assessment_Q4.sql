SELECT
    u.id AS customer_id,
    u.name,
    -- Calculate tenure in months, minimum 1 month to avoid division by zero
    GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1) AS tenure_months,

    -- Total number of transactions (inflows)
    COUNT(s.id) AS total_transactions,

    -- Estimated CLV calculation
    ROUND(
        (COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1))  -- transactions per month
        * 12                                                                      -- annualized
        * (0.001 * AVG(s.confirmed_amount / 100))                                -- avg profit per transaction (0.1% of avg transaction value)
    , 2) AS estimated_clv

FROM
    users_customuser u

LEFT JOIN
    savings_savingsaccount s ON u.id = s.owner_id

GROUP BY
    u.id, u.name, u.date_joined

ORDER BY
    estimated_clv DESC;
