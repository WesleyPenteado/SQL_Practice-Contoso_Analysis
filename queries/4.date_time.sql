/*
DATE_TRUNC()
Revenue & Customers by Month
*/

SELECT
    DATE_TRUNC('month', orderdate)::date AS order_month,
    SUM(quantity * netprice * exchangerate) AS net_revenue,
    COUNT(DISTINCT customerkey) AS total_unique_customers
FROM sales
GROUP BY
    order_month



/*
TO_CHAR()
Revenue & Customers by Month
*/

-- Practice 1
SELECT
    orderdate,
    TO_CHAR(orderdate, 'YYYY-MM')
FROM sales
ORDER BY RANDOM()
LIMIT 10;



-- Practice 2 (Improving the first query)
SELECT
    TO_CHAR(orderdate, 'YYYY-MM') AS order_month,
    SUM(quantity * netprice * exchangerate) AS net_revenue,
    COUNT(DISTINCT customerkey) AS total_unique_customers
FROM sales
GROUP BY
    order_month;




/*
Date & Time Filtering
DATE_PART() & EXTRACT()
Category net revenue per year
*/


-- DATE_PART()
SELECT
    orderdate,
    DATE_PART('year', orderdate) AS order_year,
    DATE_PART('month', orderdate) AS order_month,
    DATE_PART('day', orderdate) AS order_day
FROM
    sales
ORDER BY RANDOM()
LIMIT 10;

-- EXTRACT()
SELECT
    orderdate,
    EXTRACT(YEAR FROM orderdate) AS order_year,
    EXTRACT(MONTH FROM orderdate) AS order_month,
    EXTRACT(DAY FROM orderdate) AS order_day
FROM
    sales
ORDER BY RANDOM()
LIMIT 10;


-- Complete query

SELECT
    EXTRACT(YEAR FROM orderdate) AS order_year,
    EXTRACT(MONTH FROM orderdate) AS order_month,
    SUM(quantity * netprice * exchangerate) AS net_revenue,
    COUNT(DISTINCT customerkey) AS total_unique_customers
FROM sales
GROUP BY
    order_year,
    order_month;



/*
CURRENT_DATE & NOW()
Net Revenue Last 5 Years
*/

-- CURRENT_DATE(): show the day
SELECT CURRENT_DATE 

-- NOR(): show the day and hour
SELECT NOW()


-- Net revenue last five years
SELECT
    s.orderdate,
    p.categoryname,
    SUM(s.quantity * s.netprice * s.exchangerate) AS net_revenue    
FROM
    sales s
LEFT JOIN product p ON s.productkey = p.productkey
WHERE
    EXTRACT(YEAR FROM orderdate) >= EXTRACT(YEAR FROM CURRENT_DATE) -5 -- last 5 years
GROUP BY
    s.orderdate,
    p.categoryname
ORDER BY
    s.orderdate,
    p.categoryname;


/*
DATE & TIME Differences
INTERVAL
Net Revenue Last 5 Year (contd.)
*/

-- Interval
SELECT INTERVAL '5 centuries'

-- Practice
SELECT
    s.orderdate,
    p.categoryname,
    SUM(s.quantity * s.netprice * s.exchangerate) AS net_revenue    
FROM
    sales s
LEFT JOIN product p ON s.productkey = p.productkey
WHERE
    orderdate >= CURRENT_DATE - INTERVAL '5 years' -- more specific
GROUP BY
    s.orderdate,
    p.categoryname
ORDER BY
    s.orderdate,
    p.categoryname;


/*
DATE & TIME Differences
AGE() & EXTRACT()
Average Processing Time (Difference )
*/

-- AGE() Provide the end date and start date
SELECT AGE('2024-01-14', '2024-01-08')

-- Extracting integer from the code in order to operate differences
SELECT EXTRACT(DAY FROM AGE('2024-01-14', '2024-01-08')) - 5

-- Practicing average year

SELECT
    DATE_PART('year', orderdate) AS order_year,
    ROUND(AVG(EXTRACT(DAYS FROM AGE(deliverydate, orderdate))), 2) AS avg_processing_time,
    CAST(SUM(quantity * netprice * exchangerate) AS INTEGER) AS net_revenue
FROM
    sales
WHERE
    orderdate >= CURRENT_DATE - INTERVAL '5 years' -- more specific
GROUP BY
    order_year
ORDER BY
    order_year;


-- Practicing average month

SELECT
    EXTRACT(YEAR FROM orderdate) AS order_year,
    EXTRACT(MONTH FROM orderdate) AS order_month,
    ROUND(AVG(EXTRACT(DAYS FROM AGE(deliverydate, orderdate)))::NUMERIC, 2) AS avg_processing_time,
    CAST(SUM(quantity * netprice * exchangerate) AS INTEGER) AS net_revenue
FROM sales
WHERE
    orderdate >= CURRENT_DATE - INTERVAL '5 years'
GROUP BY 
    order_year,
    order_month
ORDER BY
    order_year,
    order_month



