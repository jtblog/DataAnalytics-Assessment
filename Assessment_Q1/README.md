
---

# 🧮 High-Value Customers with Multiple Products

This report identifies customers who hold both **funded savings** and **funded investment** plans—indicating cross-selling success. For each qualifying customer, it shows the number of plan types and total deposits, **sorted by highest total deposits**.

---

## ✅ Approach Explanation

### 1. Identify Savings and Investment Plans

Use the `plans_plan` table to determine:

* **Savings plans** → `is_regular_savings = 1`
* **Investment plans** → `is_a_fund = 1`

### 2. Link Plans with Customers

Use the `savings_savingsaccount` table:

* Join with `plans_plan` via `plan_id`
* Join with `users_customuser` via `owner_id`

### 3. Apply Filters

* Only consider **funded plans** where `confirmed_amount > 0` (in kobo)
* Group data by `owner_id`

### 4. Aggregate Per Customer

* Use `COUNT(DISTINCT ...)` to avoid duplicate plan counts
* Use `SUM(...) / 100` to convert deposits from **kobo to Naira**
* Display the customer's full name, falling back to `first_name + last_name` if `name` is `NULL`

### 5. Final Filters and Sorting

* Include only customers with **at least one savings** and **one investment** plan
* Sort by `total_deposits DESC`

---

## 🧾 SQL QUERY

```sql
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
```

---

## 📤 Expected Output

| owner\_id | name     | savings\_count | investment\_count | total\_deposits |
| --------- | -------- | -------------- | ----------------- | --------------- |
| 1001      | John Doe | 2              | 1                 | 15000.00        |

---

## 🗒️ Notes

* `confirmed_amount` is stored in **kobo**; it is converted to **Naira** by dividing by `100`.
* The `HAVING` clause ensures we only include customers who have both savings and investment plans.
* `COALESCE(...)` ensures meaningful names even when `name` is NULL.


---

