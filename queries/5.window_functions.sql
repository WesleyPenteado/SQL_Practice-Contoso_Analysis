/*
Window Function Syntax
Average Revenue of Customers
*/

-- Example 1
SELECT
    customerkey,
    orderkey,
    linenumber,
    (quantity * netprice * exchangerate) AS net_revenue,
    AVG(quantity * netprice * exchangerate) OVER() as avg_all_orders,
    AVG(quantity * netprice * exchangerate) OVER(PARTITION BY customerkey) as avg_by_customer
FROM sales
ORDER BY customerkey
LIMIT 10;

-- Example 2
SELECT
    customerkey as customer,
    orderdate,
    (quantity * netprice * exchangerate) AS net_revenue,

    ROW_NUMBER() OVER(
        PARTITION BY customerkey
        ORDER BY quantity * netprice * exchangerate DESC
    ) AS order_rank,
    
    SUM(quantity * netprice * exchangerate) OVER(
        PARTITION BY customerkey
        ORDER BY orderdate
    ) AS customer_running_total, 
    
    SUM(quantity * netprice * exchangerate) OVER(
        PARTITION BY customerkey
    ) AS customer_net_revenue,

    (quantity * netprice * exchangerate) / 
        SUM(quantity * netprice * exchangerate) OVER(
        PARTITION BY customerkey
    ) AS pct_customer_revenue
FROM sales
WHERE
    customerkey = 387
ORDER BY customer, orderdate
LIMIT 10;

-- Example 3

SELECT
    orderdate,
    orderkey * 10 + linenumber AS order_line_number,
    (quantity * netprice * exchangerate) AS net_revenue, 
    SUM(quantity * netprice * exchangerate) OVER(PARTITION BY orderdate) AS daily_net_revenue,
    ROUND(((quantity * netprice * exchangerate) *100 /  SUM(quantity * netprice * exchangerate) OVER(PARTITION BY orderdate))::NUMERIC,2) AS pct_daily_revenue
FROM sales
ORDER BY
    orderdate,
    pct_daily_revenue DESC
LIMIT 10;

-- Example 4 (Using subquery to simplificate)

SELECT *,
    100 * net_revenue / daily_net_revenue AS pct_daily_revenue
FROM (
    SELECT
        orderdate,
        orderkey * 10 + linenumber AS order_line_number,
        (quantity * netprice * exchangerate) AS net_revenue,
        SUM(quantity * netprice * exchangerate) OVER(PARTITION BY orderdate) AS daily_net_revenue
    FROM sales
    ) AS revenue_by_day

/*
Cohort Analysis: Exanines the behavior of specif groups over time

*/

-- Using MIN() (Minimum)

WITH yearly_cohort AS (
    SELECT DISTINCT
        customerkey,
        EXTRACT(YEAR FROM MIN(orderdate) OVER(PARTITION BY customerkey)) AS cohort_year
    FROM sales
)
SELECT
    y.cohort_year,
    EXTRACT(YEAR FROM orderdate) AS purchase_year,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales s
LEFT JOIN yearly_cohort y ON s.customerkey = y.customerkey
GROUP BY
    cohort_year,
    purchase_year
ORDER BY
    cohort_year,
    purchase_year;



-- Using COUNT() (Minimum)

WITH yearly_cohort AS (
    SELECT DISTINCT
        customerkey,
        EXTRACT(YEAR FROM orderdate) AS purchase_year,
        EXTRACT(YEAR FROM MIN(orderdate) OVER(PARTITION BY customerkey)) AS cohort_year
    FROM sales
)
SELECT DISTINCT
    cohort_year,
    purchase_year,
    COUNT(customerkey) OVER (PARTITION BY purchase_year, cohort_year) AS num_customers
FROM yearly_cohort
ORDER BY
    cohort_year,
    purchase_year


-- Using AVG()

WITH yearly_cohort AS (
    SELECT DISTINCT
        customerkey,
        EXTRACT(YEAR FROM MIN(ORDERDATE)) AS cohort_year,
        ROUND(SUM(quantity * netprice * exchangerate)::NUMERIC,2) AS customer_ltv
    FROM sales
    GROUP BY customerkey
)
SELECT DISTINCT
    *,
    ROUND(AVG(customer_ltv) OVER (PARTITION BY cohort_year)::NUMERIC,2) AS avg_cohort_ltv
FROM yearly_cohort
ORDER BY
    cohort_year,
    customerkey;





/*
Windows Functions & Group BYs
Best Practices: Don't Combine

Windows functions runs after GROUP BY, what causes error on information
*/


-- Example of error | It's counting just one order for each customer.

SELECT
    customerkey,
    AVG(quantity * netprice * exchangerate) AS net_revenue,
    COUNT(*) OVER(PARTITION BY customerkey) AS total_orders
FROM sales
GROUP BY customerkey;

-- Correcting using CTE

WITH customer_orders AS(
    SELECT
        customerkey,
        (quantity * netprice * exchangerate) AS order_value,
        COUNT(*) OVER(PARTITION BY customerkey) AS total_orders
    FROM sales
)
SELECT
    customerkey,
    AVG(order_value) AS net_revenue,
    total_orders
FROM 
    customer_orders
GROUP BY
    customerkey,
    total_orders   



/*
Windows Functions & Where statements
Best Practices: you can combine before the window function

*/

-- Example directly

SELECT
    customerkey,
    EXTRACT(YEAR FROM MIN(ORDERDATE) OVER (PARTITION BY customerkey)) AS cohort_year
FROM sales
WHERE orderdate >= '2020-01-01'


-- Example with a CTE

WITH cohort AS (
SELECT
    customerkey,
    EXTRACT(YEAR FROM MIN(ORDERDATE) OVER (PARTITION BY customerkey)) AS cohort_year
FROM sales
)
SELECT *
FROM cohort
WHERE cohort_year >= '2020'


/*
---------------------------- RANKING -------------------------------
*/


-- Running order count + running average revenue

SELECT
    customerkey,
    orderdate,
    ROUND((quantity * netprice * exchangerate)::NUMERIC,2) AS net_revenue,
    COUNT(*) OVER (
        PARTITION BY customerkey 
        ORDER BY ORDERDATE
        ) running_order_count,
    
    ROUND(AVG((quantity * netprice * exchangerate)::NUMERIC) OVER (
        PARTITION BY customerkey 
        ORDER BY ORDERDATE
        )::NUMERIC,2) running_avg_revenue
FROM sales
LIMIT 30;


-- Using ROW_NUMBER() | recommended is always to use ORDER BY

SELECT
    ROW_NUMBER() OVER(
        PARTITION BY
        orderdate
        ORDER BY 
        orderdate,
        orderkey,
        linenumber
    ) AS row_numb,
    *
FROM sales
WHERE orderdate > '2015-01-01'


-- Checking if the row_number is running acordingly

WITH row_number AS (
SELECT
    ROW_NUMBER() OVER(
        PARTITION BY
        orderdate
        ORDER BY 
        orderdate,
        orderkey,
        linenumber
    ) AS row_numb,
    *
FROM sales
)
SELECT *
FROM row_number
WHERE orderdate > '2015-01-01'
LIMIT 10



/*
ROW_NUMBER(), RANK(), DENSE_RANK()
Ranking Customer Order Quantity
*/


SELECT
    customerkey,
    COUNT(*) AS total_orders,
    
    ROW_NUMBER()  OVER(
        ORDER BY COUNT(*) DESC
    ) AS total_orders_row_num, -- Ranking by orders count desc

    RANK()  OVER(
        ORDER BY COUNT(*) DESC
    ) AS total_orders_rank, -- consider iqual numbers in rank but skip the sequence

    DENSE_RANK()  OVER(
        ORDER BY COUNT(*) DESC
    ) AS total_orders_dense_rank -- Ranking by orders count desc
FROM sales
GROUP BY
    customerkey
LIMIT 10;



/*
---------------------------- LAG & LEAD -------------------------------
LAG()
LEAD()
FIRST_VALUE()
LAST_VALUE()
NTH_VALUE()

Month_Over_Month Revenue Growth

*/


-- First, Last and Nth values

WITH monthly_revenue AS (
SELECT
    TO_CHAR(orderdate, 'YYYY-MM') AS month,
    SUM(netprice * quantity * exchangerate) AS net_revenue
FROM sales
WHERE EXTRACT(YEAR FROM orderdate) = 2023
GROUP BY month
ORDER BY month
)
SELECT *,
    FIRST_VALUE(net_revenue) OVER(ORDER BY month) AS first_revenue,
    LAST_VALUE(net_revenue) OVER(ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_revenue,
    NTH_VALUE(net_revenue, 3) OVER(ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_revenue

FROM monthly_revenue;



-- Lag and Lead

WITH monthly_revenue AS (
SELECT
    TO_CHAR(orderdate, 'YYYY-MM') AS month,
    SUM(netprice * quantity * exchangerate) AS net_revenue
FROM sales
WHERE EXTRACT(YEAR FROM orderdate) = 2023
GROUP BY month
ORDER BY month
)
SELECT *,
    ROUND(LAG(net_revenue) OVER(ORDER BY month)::NUMERIC,2) AS previous_month_revenue,
    
    ROUND(((net_revenue - LAG(net_revenue) OVER(ORDER BY month)) / 
    LAG(net_revenue) OVER(ORDER BY month)*100)::NUMERIC,2)
     AS monthly_rev_growth

FROM monthly_revenue;


/*
    Lag and Lead
LTV Change from Cohort-to-Cohort

LTV = lifetime value for customers
*/


WITH yearly_cohort AS (
    SELECT
        customerkey,
        EXTRACT(YEAR FROM MIN(ORDERDATE)) AS cohort_year,
        ROUND(SUM(quantity * netprice * exchangerate)::NUMERIC,2) AS customer_ltv
    FROM sales
    GROUP BY customerkey
), cohort_summary AS(
    SELECT
        cohort_year,
        customerkey,
        customer_ltv,
        AVG(customer_ltv) OVER (PARTITION BY cohort_year) AS avg_cohort
FROM yearly_cohort
), cohort_final AS (
SELECT DISTINCT
    cohort_year,
    ROUND(avg_cohort,2) AS avg_cohort_ltv
FROM cohort_summary
ORDER BY
    cohort_year
)
SELECT *,
    LAG(avg_cohort_ltv) OVER (ORDER BY cohort_year) AS prev_cohort_ltv,
    ROUND(100 * (avg_cohort_ltv - LAG(avg_cohort_ltv) OVER (ORDER BY cohort_year)) /
    LAG(avg_cohort_ltv) OVER (ORDER BY cohort_year),2)  AS ltv_change
FROM cohort_final;




---------------------------- FRAME CLAUSES -------------------------------


-- ROWS & CURRENT ROW (2023 Monthly Net Revenue)
-- used to make seasonal data smoother



-- N Preceding and N Following

WITH monthly_sales AS (
SELECT
    TO_CHAR(orderdate, 'YYYY-MM') as month,
    ROUND(SUM(netprice * quantity * exchangerate)::NUMERIC,2) as net_revenue
FROM sales
WHERE EXTRACT(YEAR FROM orderdate) = 2023
GROUP BY month
ORDER BY month
)
SELECT
    month,
    net_revenue,
    AVG(net_revenue) OVER(
        ORDER BY month
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING -- average of actual row, 1 before and 1 after
    ) AS net_revenue_current
FROM monthly_Sales
    


-- UNBOUNDED

WITH monthly_sales AS (
SELECT
    TO_CHAR(orderdate, 'YYYY-MM') as month,
    ROUND(SUM(netprice * quantity * exchangerate)::NUMERIC,2) as net_revenue
FROM sales
WHERE EXTRACT(YEAR FROM orderdate) = 2023
GROUP BY month
ORDER BY month
)
SELECT
    month,
    net_revenue,
    AVG(net_revenue) OVER(
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- considers all preceed numbers
    ) AS net_revenue_current
FROM monthly_Sales


-- UNBOUNDED (Tipically used)

WITH monthly_sales AS (
SELECT
    TO_CHAR(orderdate, 'YYYY-MM') as month,
    ROUND(SUM(netprice * quantity * exchangerate)::NUMERIC,2) as net_revenue
FROM sales
WHERE EXTRACT(YEAR FROM orderdate) = 2023
GROUP BY month
ORDER BY month
)
SELECT
    month,
    net_revenue,

    FIRST_VALUE(net_revenue) OVER(ORDER BY month) AS first_revenue,
   
    LAST_VALUE(net_revenue) OVER(
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_month_revenue,

    NTH_VALUE(net_revenue, 3) OVER(
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS third_month_revenue_unbound

FROM monthly_Sales



