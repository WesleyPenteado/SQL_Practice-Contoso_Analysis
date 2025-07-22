/*

Active Customer: customer who made a purchase within the last 6 months
Churned Customer: Customer who hasn't made a purchase in over 6 months


Minimum: 01-01-2015
Maximum: 20-04-2024
*/

WITH customer_orders AS (
    SELECT
        customerkey,
        orderdate,
        SUM(quantity * netprice * exchangerate)::NUMERIC AS net_revenue
    FROM sales
    GROUP BY
        customerkey,
        orderdate
    ORDER BY
        customerkey
), last_orders AS (
    SELECT
        customerkey,
        MAX(orderdate) AS last_order
    FROM customer_orders
    GROUP BY 
        customerkey 
), date_bounds AS (
    SELECT
        MAX(orderdate) AS last_order,
        (MAX(orderdate) - INTERVAL '6 months') AS six_months
    FROM customer_orders
), status_table AS (
SELECT
    lo.customerkey,
    lo.last_order,
    CASE
        WHEN lo.last_order BETWEEN db.six_months AND db.last_order THEN 'Active Customer'
        ELSE 'Churned Customer'
    END AS customer_status
FROM last_orders lo
CROSS JOIN date_bounds db
)
SELECT
    customer_status,
    COUNT(*) AS count_status,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS percent_status
FROM status_table
GROUP BY
    customer_status