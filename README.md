# 🍽️ Restaurant Orders Analysis using SQL (PostgreSQL)

An end-to-end SQL analysis of a restaurant's menu and customer orders for Q1 2023 (1 Jan – 31 Mar). Twelve business questions are answered with joins, aggregations, subqueries and string aggregation in PostgreSQL.

## 📌 Project Overview

A restaurant wants to understand what is on its menu, which dishes customers order the most (and the least), and which orders bring in the most money. This project loads two CSV files into PostgreSQL and answers those questions with SQL.

**Tools:** PostgreSQL 18, pgAdmin 4

## 🗂️ Dataset

| File | Rows | Description |
|---|---|---|
| `menu_items.csv` | 32 | One row per dish on the menu |
| `order_details.csv` | 12,234 | One row per item in an order |

**`restaurant_menu`**

| Column | Type | Description |
|---|---|---|
| menu_item_id | int (PK) | Unique dish ID |
| item_name | varchar(50) | Name of the dish |
| category | varchar(50) | American, Asian, Italian or Mexican |
| price | numeric(5,2) | Price of the dish |

**`orders`**

| Column | Type | Description |
|---|---|---|
| orders_details_id | int (PK) | Unique ID for each item line |
| order_id | int | Order the item belongs to (one order has many rows) |
| order_date | date | Date of the order |
| order_time | time | Time of the order |
| item_id | int | Links to `restaurant_menu.menu_item_id` |

> Each row in `orders` is one item inside an order, so "how many orders" and "how many items" are different questions. Orders are counted with `COUNT(DISTINCT order_id)`.

## ❓ Business Questions and Key Findings

| # | Question | Result |
|---|---|---|
| Q1 | Menu size, most and least expensive item | 32 items. Most expensive: Shrimp Scampi ($19.95). Least expensive: Edamame ($5.00) |
| Q2 | Dishes and average price per category | American: 6 dishes, $10.07 · Asian: 8, $13.48 · Italian: 9, $16.75 · Mexican: 9, $11.80 |
| Q3 | Italian dishes and price extremes | 9 Italian dishes. Most expensive: Shrimp Scampi ($19.95). Cheapest: $14.50 (Spaghetti and Fettuccine Alfredo tie) |
| Q4 | Date range of the orders table | 1 Jan 2023 to 31 Mar 2023 (89 days) |
| Q5 | Orders and items in that range | 5,370 orders and 12,097 items |
| Q6 | Total orders and items | 5,370 orders and 12,097 items |
| Q7 | Order with the most items | 14 items (several orders tie at 14) |
| Q8 | Orders with more than 12 items | 20 orders |
| Q9 | Most ordered item | Hamburger (American), 622 orders |
| Q10 | Least ordered item | Chicken Tacos (Mexican), 123 orders |
| Q11 | Top 5 orders by spend | $192.15, $191.05, $190.10, $189.70, $185.10 |
| Q12 | Highest spend order with its items | Order 440 on 8 Jan 2023: 14 items, $192.15 |

### 💡 Insights

- **Asian dishes are ordered most often** (3,470 items), ahead of Italian (2,948), Mexican (2,945) and American (2,734). Italian dishes have the highest average price, so they lift order value.
- **Every one of the 32 dishes was ordered at least once**, so no menu item is completely dead. The weakest, Chicken Tacos, has about a fifth of the Hamburger's orders.
- **The biggest orders are Italian-heavy.** The highest spend order (#440) includes Meat Lasagna, Chicken Parmesan, Eggplant Parmesan and two Spaghetti & Meatballs.
- **Large orders are rare.** Only 20 of 5,370 orders (0.4%) had more than 12 items.

## 🧠 SQL Concepts Used

- `CREATE TABLE`, primary keys, `COPY` for CSV import
- `JOIN` to link the menu with orders
- `GROUP BY` with `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- Subqueries with `HAVING`
- `COUNT(DISTINCT ...)` to count orders instead of rows
- `STRING_AGG(... ORDER BY ...)` to list all items of an order in one cell
- Date arithmetic to measure the data's time range

## 🔎 Sample Queries

**Top 5 orders by spend, with the items in each order (Q11)**

```sql
select o.order_id, sum(m.price) as total_spent,
       string_agg(m.item_name, ', ' order by m.item_name) as items_purchased
from orders o
join restaurant_menu m
on o.item_id = m.menu_item_id
group by o.order_id
order by total_spent desc
limit 5;
```

**Most ordered item with its category (Q9)**

```sql
select m.menu_item_id, m.item_name, m.category,
       count(o.item_id) as most_ordered_item
from restaurant_menu m
join orders o
on m.menu_item_id = o.item_id
group by m.menu_item_id
order by most_ordered_item desc
limit 1;
```

The full set of 12 queries is in [`restaurant_operations.sql`](restaurant_operations.sql).

## ⚠️ Data Notes and Limitations

- **137 order lines have no `item_id`** (loaded as NULL). Items are counted with `COUNT(item_id)`, which skips them: 12,097 items rather than 12,234 rows. Spend totals also exclude these lines because they cannot be joined to a price.
- **Ties:** `LIMIT 1` returns one row even when several tie (for example, Q7 and the cheapest Italian dish in Q3). `FETCH FIRST 1 ROWS WITH TIES` or `RANK()` would show all ties.
- **Inner joins:** Q9 and Q10 use `JOIN`, which is safe here because every menu item was ordered at least once. A `LEFT JOIN` is the safer choice if the data changes.

## 🚀 How to Run

1. Install PostgreSQL and pgAdmin.
2. Create a database and open the Query Tool.
3. Update the `COPY` file paths in `restaurant_operations.sql` to where you saved the CSV files.
4. Run the script from top to bottom.

```
├── data/
│   ├── menu_items.csv
│   └── order_details.csv
├── restaurant_operations.sql
└── README.md
```

## 👤 Author

**Balkrishna Tripathi**
Mechanical engineer with 7+ years in manufacturing, moving into data analytics.
Skills: Excel · SQL · Power BI · Python

- LinkedIn: [www.linkedin.com/in/balkrishna-tripathi-a6955a423]
- GitHub: [add your link]

⭐ Feedback on the queries is welcome.
