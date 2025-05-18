# 🔄 Transaction Frequency Analysis

This analysis helps segment customers based on how frequently they transact. The goal is to categorize users into **High**, **Medium**, or **Low Frequency** groups based on their monthly transaction behavior across both **savings** and **withdrawal** activities.

---

## ✅ Approach Explanation

### 1. Combine Transaction Sources

Both `savings_savingsaccount` and `withdrawals_withdrawal` tables represent customer transactions:

- Each row in either table represents a financial event (deposit or withdrawal).
- To get complete transaction data:
  - Use `UNION ALL` to merge both tables into a single transaction log.

---

### 2. Count Total Transactions per Customer

- After combining, group by `owner_id` to:
  - **Count total transactions** per customer.
  - **Find the earliest and latest transaction date**.

---

### 3. Calculate Account Activity Duration

- Compute the number of **months active** per customer:
  - Based on difference between the earliest and latest transaction dates.
  - Use `TIMESTAMPDIFF(MONTH, min_date, max_date)` to get active duration.
  - Use `GREATEST(..., 1)` to ensure at least 1 month (avoiding divide-by-zero).

---

### 4. Compute Average Transactions Per Month

- For each customer:
  - Divide `total_transactions / months_active`.

---

### 5. Categorize Customers by Frequency

Assign each customer into a frequency tier:

| Category          | Criteria                       |
|-------------------|--------------------------------|
| High Frequency     | Average ≥ 10 txns/month        |
| Medium Frequency   | Average 3 to 9 txns/month      |
| Low Frequency      | Average ≤ 2 txns/month         |

---

### 6. Aggregate by Category

- Group by the frequency category:
  - Count how many customers fall in each.
  - Optionally calculate the average transaction frequency per category.

---

## 🗒️ Key Points

- **`all_transactions` CTE**: Combines deposits and withdrawals using `UNION ALL`.
- **Aggregation**: Counts total transactions and calculates date range per customer.
- **`GREATEST(..., 1)`**: Ensures minimum 1 month active to prevent division errors.
- **Accurate categorization**: Based on real activity across both savings and withdrawals.
- **Scalable**: Can support segmentation for marketing, risk profiling, or product targeting.

---

## 📊 Expected Output Format

| frequency_category | customer_count | avg_transactions_per_month |
|--------------------|----------------|-----------------------------|
| High Frequency     | 250            | 15.2                        |
| Medium Frequency   | 1200           | 5.5                         |
| Low Frequency      | 3000           | 1.1                         |

---
