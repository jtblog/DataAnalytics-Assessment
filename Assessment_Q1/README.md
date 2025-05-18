# 🧮 High-Value Customers with Multiple Products

This report identifies customers who have both **funded savings** and **funded investment** plans—enabling cross-selling opportunities. It includes the number of each plan type and their total deposits, sorted in descending order of deposits.

---

## ✅ Approach Explanation

### 1. Identify Savings and Investment Plans
Use the `plans_plan` table to distinguish:
- **Savings plans**: `is_regular_savings = 1`
- **Investment plans**: `is_a_fund = 1`

---

### 2. Link Plans with Savings Accounts
- Use the `savings_savingsaccount` table to join plans (`plan_id`) to customers (`owner_id`).
- Only consider **funded plans**: the existence of a transaction in `savings_savingsaccount` implies the plan is funded.

---

### 3. Aggregate per Customer
- **Count distinct** savings and investment plans for each customer.
- **Sum** `confirmed_amount` values to get total deposits (converted from kobo to Naira by dividing by 100).

---

### 4. Filter for Customers with Both Plan Types
- Only include customers with **at least one savings plan** *and* **at least one investment plan**.

---

### 5. Join with Users Table
- Use the `users_customuser` table to get the customer’s name.
- If `name` is `NULL`, fall back to `first_name + last_name`.

---

## 🗒️ Notes

- `COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name))` provides a fallback name if `name` is `NULL`.
- `confirmed_amount` is stored in **kobo**, so divide by 100 to convert to **Naira**.
- `COUNT(DISTINCT ...)` ensures each plan is counted only once per customer.
- `INNER JOIN` ensures only customers with valid savings account records are included.
- A record in `savings_savingsaccount` implies that the plan is funded.

---

## 📤 Expected Output

| owner_id | name      | savings_count | investment_count | total_deposits |
|----------|-----------|----------------|------------------|----------------|
| 1001     | John Doe  | 2              | 1                | 15000.00       |

---
