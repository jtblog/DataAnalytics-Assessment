# 🔄 Transaction Frequency Analysis

This analysis categorizes customers based on their **average monthly transaction frequency**, combining both **deposits** and **withdrawals**.

---

## 🎯 Objective

To help finance and marketing teams segment users into:
- High Frequency (≥ 10 txns/month)
- Medium Frequency (3–9 txns/month)
- Low Frequency (≤ 2 txns/month)

---

## 🧠 Optimized Approach

### Step 1: Combine All Transactions
Merge `savings_savingsaccount` and `withdrawals_withdrawal` tables using `UNION ALL`, selecting `owner_id` and `created_on` for transaction date.

### Step 2: Calculate Activity Metrics per Customer
For each customer:
- Count total transactions
- Determine account activity period in **months**:
  - `TIMESTAMPDIFF(MONTH, MIN(date), MAX(date)) + 1`
  - Wrap with `GREATEST(..., 1)` to avoid division by zero

### Step 3: Compute Monthly Average and Categorize
Calculate:
- `avg_txn_per_month = total_txns / months_active`
- Classify frequency using a `CASE`:
  - **High Frequency**: ≥ 10
  - **Medium Frequency**: 3–9
  - **Low Frequency**: ≤ 2

### Step 4: Aggregate by Frequency Group
For each frequency category:
- Count how many customers fall into it
- Compute the average transactions per month (1 decimal precision)

---

## 🧾 SQL QUERY

```sql
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

```

## 📊 Expected Output

| frequency_category | customer_count | avg_transactions_per_month |
|--------------------|----------------|-----------------------------|
| High Frequency     | 250            | 15.2                        |
| Medium Frequency   | 1200           | 5.5                         |
| Low Frequency      | 3000           | 1.1                         |

---

## 💡 Highlights

- Uses `FIELD(...)` in `ORDER BY` to enforce custom sorting
- Prevents divide-by-zero with robust month calculation

---

