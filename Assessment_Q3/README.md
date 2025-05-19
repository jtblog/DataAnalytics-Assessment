# ⏸️ Account Inactivity Alert

This report identifies all **active savings or investment accounts** that have had **no inflow or outflow transactions** in the last **365 days**. These accounts are considered **inactive**, helping operations teams drive re-engagement, compliance, and user retention initiatives.

---

## ✅ Approach Explanation

### 1. Identify Relevant Plans

We focus on:
- **Savings plans**: `is_regular_savings = 1`
- **Investment plans**: `is_a_fund = 1`

These are the only plan types of interest in this analysis.

---

### 2. Track All Transactions

We consider **both inflows and outflows** as indicators of account activity:
- `savings_savingsaccount`: inflow transactions
- `withdrawals_withdrawal`: outflow transactions

Each contains `plan_id` and `created_on` fields.

---

### 3. Combine Transactions

We use a `UNION ALL` to merge both inflow and outflow transactions into one list per `plan_id`, retaining `created_on` as the transaction timestamp.

---

### 4. Determine Last Activity per Plan

From the merged transaction data, we calculate the **most recent activity** (`MAX(created_on)`) for each `plan_id`.

---

### 5. Identify Inactive Accounts

We join all plans with their last transaction (if any), and flag plans as **inactive** if:
- They’ve had **no transaction in the past 365 days**, or
- They’ve had **no transaction ever** (`NULL`)

The inactivity duration is calculated as:

```sql
DATEDIFF(CURDATE(), COALESCE(last_transaction_date, p.created_on))
```


---

This gives the number of days since the last transaction (or since the plan was created).

---


```sql
-- Identify active savings/investment accounts with no transactions in the last 365 days
WITH all_transactions AS (
    -- Combine all inflows (deposits) and outflows (withdrawals) per plan
    SELECT plan_id, created_on FROM savings_savingsaccount
    UNION ALL
    SELECT plan_id, created_on FROM withdrawals_withdrawal
),
latest_txn_per_plan AS (
    -- Get the latest transaction date per plan
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
```


## 📤 Output Format

| plan_id | owner_id | type       | last_transaction_date | inactivity_days |
|---------|----------|------------|------------------------|------------------|
| 1001    | 305      | Savings    | 2023-08-10             | 400              |
| 1005    | 422      | Investment | NULL                   | 600              |

---

## 🗒️ Notes

- `LEFT JOIN` ensures we capture plans that **never transacted**.
- `COALESCE(..., created_on)` handles missing transaction dates gracefully.
- `GROUP BY` ensures per-plan uniqueness in the output.
- `DATEDIFF` is used for date arithmetic and is MySQL-specific.
- This query assumes all transaction timestamps are stored in `created_on`.

