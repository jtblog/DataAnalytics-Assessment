SELECT
    u.id AS owner_id,
    COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name)) AS name,
    
    -- Count of distinct savings plans per user (is_regular_savings = 1)
    COUNT(DISTINCT CASE 
        WHEN p.is_regular_savings = 1 THEN p.id
        ELSE NULL
    END) AS savings_count,
    
    -- Count of distinct investment plans per user (is_a_fund = 1)
    COUNT(DISTINCT CASE 
        WHEN p.is_a_fund = 1 THEN p.id
        ELSE NULL
    END) AS investment_count,
    
    -- Sum of all confirmed deposits (in kobo) converted to main currency unit (assuming kobo to naira, divide by 100)
    SUM(s.confirmed_amount) / 100.0 AS total_deposits
    
FROM
    users_customuser u
    
    -- Join savings accounts with users
    INNER JOIN savings_savingsaccount s ON s.owner_id = u.id
    
    -- Join plans to identify plan types for each savings account
    INNER JOIN plans_plan p ON s.plan_id = p.id
    
GROUP BY
    u.id, u.name, u.first_name, u.last_name

-- Only users with at least one savings AND one investment plan
HAVING
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id ELSE NULL END) > 0
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id ELSE NULL END) > 0

ORDER BY
    total_deposits DESC;