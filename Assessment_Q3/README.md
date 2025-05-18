# 🛑 Account Inactivity Alert

This analysis identifies **active savings or investment accounts** with **no transactions in the past 365 days**. It's useful for detecting dormant or neglected plans for customer outreach, compliance checks, or retention campaigns.

---

## ✅ Approach Explanation

### Goal

Identify **active plans** that are either **savings** or **investments**, and:

- Have had **no inflow or outflow transactions** in the **last 365 days**, or
- Have **never had any transaction**.

---

## 🔍 Step-by-Step Strategy

### 1. Define "Active" Plans

- A plan is considered **active** if it's a **savings** or **investment** plan:
  - `is_regular_savings = 1` (Savings)
  - `is_a_fund = 1` (Investment)
- (Optional: If you have an `is_active` flag in `plans_plan`, use it to filter.)

---

### 2. Track Transaction Activity

- Use **both inflows** (`savings_savingsaccount`) and **outflows** (`withdrawals_withdrawal`) as indicators of activity.
- Each row in either table represents a transaction for a specific `plan_id`.

---

### 3. Combine Transactions Across Sources

- Use a `UNION` to merge all inflow and outflow transactions:
  - Retain only `plan_id` and `created_at` for date tracking.
- Aggregate to get the **latest transaction date** per `plan_id`.

---

### 4. Join with Active Plans

- Use a `LEFT JOIN` to associate each active plan with its most recent transaction (if any).
- This also captures plans that have **never had any transaction**.

---

### 5. Filter for Inactive Plans

- Identify plans where:
  - `last_transaction_date IS NULL`, or
  - `DATEDIFF(CURDATE(), last_transaction_date) > 365`.

---

### 6. Compute Inactivity Duration

- Calculate `inactivity_days` as:
  ```sql
  DATEDIFF(CURDATE(), last_transaction_date)
  ```

---

### 7. Enrich Output

- Add human-readable plan type:
  - `"Savings"` if `is_regular_savings = 1`
  - `"Investment"` if `is_a_fund = 1`
- Output fields:
  - `plan_id`, `owner_id`, `type`, `last_transaction_date`, `inactivity_days`

---

## 🗒️ Key Notes

- **`all_transactions` CTE**: Combines all transaction dates from savings and withdrawals.
- **LEFT JOIN**: Ensures inclusion of plans with **no transactions** (i.e., `NULL`).
- **Inactivity clock** is reset by **any transaction type**.
- Uses `CURDATE()` to determine inactivity relative to **today**.
- Ensures comprehensive coverage across all plan types and owners.

---

## 📊 Expected Output Format

| plan_id | owner_id | type       | last_transaction_date | inactivity_days |
|---------|----------|------------|------------------------|------------------|
| 1001    | 305      | Savings    | 2023-08-10             | 92               |
| 1005    | 422      | Investment | NULL                   | 460              |

---

## 💡 Use Cases

- Trigger re-engagement email campaigns for inactive customers.
- Identify dormant plans for possible deactivation.
- Feed into churn prediction or customer health models.