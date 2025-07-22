/*
COUNT DISTINCT Review
Total customer per day in 2023
*/


SELECT
    orderdate,
    COUNT(DISTINCT customerkey) AS customer_count
FROM
    sales
WHERE
    orderdate::DATE BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY
    orderdate
ORDER BY
    orderdate;

/*
PIVOT with COUNT()
Daily Customers by Region
*/

SELECT
    s.orderdate,
    -- just to check totals COUNT(DISTINCT s.customerkey) AS customer_count,
    COUNT(DISTINCT CASE WHEN c.continent = 'Europe'
    THEN s.customerkey END) AS eu_customers,
    COUNT(DISTINCT CASE WHEN c.continent = 'North America'
    THEN s.customerkey END) AS au_customers,
    COUNT(DISTINCT CASE WHEN c.continent = 'Australia'
    THEN s.customerkey END) AS au_customers
FROM
    sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
WHERE
    orderdate::DATE BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY
    orderdate
ORDER BY
    orderdate;
    
/*
PIVOT with SUM()
Comparison 2022 x 2023 by category of itens sold.
*/

SELECT
    p.categoryname,
    ROUND(SUM(CASE WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' THEN s.quantity * s.netprice * s.exchangerate ELSE 0 END)::NUMERIC, 2) AS net_revenue_2022,
    ROUND(SUM(CASE WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' THEN s.quantity * s.netprice * s.exchangerate ELSE 0 END)::NUMERIC, 2) AS net_revenue_2023
FROM
    sales s
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY
    p.categoryname
ORDER BY
    net_revenue_2023 DESC;


/*
PIVOT with statistical functions (MIN, MAX, AVG)
*/


SELECT
    p.categoryname,
    ROUND(AVG(CASE WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' THEN s.quantity * s.netprice * s.exchangerate END)::NUMERIC, 2) AS avg_net_revenue_2022,
    ROUND(AVG(CASE WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' THEN s.quantity * s.netprice * s.exchangerate END)::NUMERIC, 2) AS avg_net_revenue_2023,
    ROUND(MIN(CASE WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' THEN s.quantity * s.netprice * s.exchangerate END)::NUMERIC, 2) AS min_net_revenue_2022,
    ROUND(MIN(CASE WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' THEN s.quantity * s.netprice * s.exchangerate END)::NUMERIC, 2) AS min_net_revenue_2023,
    ROUND(MAX(CASE WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' THEN s.quantity * s.netprice * s.exchangerate END)::NUMERIC, 2) AS max_net_revenue_2022,
    ROUND(MAX(CASE WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' THEN s.quantity * s.netprice * s.exchangerate END)::NUMERIC, 2) AS max_net_revenue_2023
FROM
    sales s
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY
    p.categoryname
ORDER BY
    avg_net_revenue_2023 DESC;


/*
PIVOT with the Median (PERCENTILE_COUNT(.50)) + WHITIN and ORDER BY
*/

-- Example
SELECT
    PERCENTILE_CONT(.50) WITHIN GROUP (ORDER BY netprice) AS median_price
FROM sales;

-- Complete example
SELECT
    p.categoryname,
    ROUND(PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY(CASE
    WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' THEN (s.quantity * s.netprice * s.exchangerate) 
    END))::NUMERIC,2) AS y2022_median_sales,
    
    ROUND(PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY(CASE
    WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' THEN (s.quantity * s.netprice * s.exchangerate) 
    END))::NUMERIC,2) AS y2022_median_sales
FROM
    sales s
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY
    p.categoryname
ORDER BY
    p.categoryname;
