-- Estimate CLV based on tenure and transaction volume
SELECT 
    u.id AS customer_id,
    COALESCE(u.name, CONCAT_WS(' ', u.first_name, u.last_name)) AS name,
    
    -- Calculate tenure in months (from signup to today)
    GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1) AS tenure_months,
    
    -- Count total transactions (deposits only, from savings_savingsaccount)
    COUNT(s.id) AS total_transactions,
    
    -- Estimate CLV using simplified formula
    ROUND(
        (COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1)) 
        * 12 
        * 0.001 
        * AVG(s.confirmed_amount) / 100, -- convert from kobo to Naira
        2
    ) AS estimated_clv

FROM users_customuser u
LEFT JOIN savings_savingsaccount s ON s.owner_id = u.id

GROUP BY u.id, name
ORDER BY estimated_clv DESC;
