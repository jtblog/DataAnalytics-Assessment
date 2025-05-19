# 💰 Customer Lifetime Value (CLV) Estimation

This analysis estimates the **Customer Lifetime Value (CLV)** using a simplified model based on account tenure and transaction behavior. CLV helps assess the long-term value of a customer for targeted marketing, retention strategy, and resource allocation.

---

## ✅ Approach Explanation

### 🎯 Objective

Estimate CLV per customer using:

- **Account Tenure** in months  
- **Total Transactions**  
- **Average Profit per Transaction** (given as 0.1% of average transaction value)

---

### 📐 CLV Formula

We use the following formula to annualize customer profitability:

```
CLV = (total_transactions / tenure_months) × 12 × avg_profit_per_transaction
```

Where:
- `avg_profit_per_transaction = 0.1% of avg transaction value`
- Transaction value comes from `confirmed_amount` (in **kobo**, converted to **Naira**)
- Tenure = Months between `date_joined` and today (at least 1 month)

---

## 🔍 Step-by-Step Strategy

### 1. Calculate Account Tenure

- Use `users_customuser.date_joined` as signup date.
- Compute months from signup to today using:
  ```sql
  TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())
  ```
- Use `GREATEST(..., 1)` to avoid division by zero for users with tenure < 1 month.

---

### 2. Calculate Transaction Metrics

- Use `savings_savingsaccount` for confirmed inflow transactions.
- Count total transactions per customer:
  ```sql
  COUNT(s.id)
  ```

- Convert and average transaction value from **kobo to naira**:
  ```sql
  AVG(s.confirmed_amount / 100)
  ```

- Estimate profit per transaction:
  ```sql
  avg_transaction_value × 0.001
  ```

---

### 3. Compute Estimated CLV

- Annualize transaction rate using tenure and multiply by estimated profit:
  ```sql
  (total_txn / tenure_months) × 12 × avg_profit_per_transaction
  ```

---

### 4. Final Output Fields

| customer_id | name     | tenure_months | total_transactions | estimated_clv |
|-------------|----------|----------------|---------------------|----------------|
| 1001        | John Doe | 24             | 120                 | 600.00         |

---

## 🗒️ Key Notes

- Only inflow transactions (`savings_savingsaccount.confirmed_amount`) are considered.
- Amounts are stored in **kobo**, so divide by **100** to get naira.
- CLV is **annualized** to reflect yearly profitability.
- `COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name))` ensures fallback for missing names.
- `GREATEST(..., 1)` ensures safe division if tenure is 0 months.

---


```sql
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
```

---
