SELECT 
    u.id AS owner_id,
    COALESCE(u.name, CONCAT_WS(' ', u.first_name, u.last_name)) AS name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.id END) AS investment_count,
    ROUND(SUM(CASE WHEN p.is_regular_savings = 1 OR p.is_a_fund = 1 THEN s.confirmed_amount ELSE 0 END) / 100, 2) AS total_deposits
FROM users_customuser u
INNER JOIN savings_savingsaccount s ON s.owner_id = u.id
INNER JOIN plans_plan p ON p.id = s.plan_id
WHERE s.confirmed_amount > 0
GROUP BY u.id, name
HAVING savings_count > 0 AND investment_count > 0
ORDER BY total_deposits DESC;
