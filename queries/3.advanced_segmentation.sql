/*
PIVOTING WITH CASE

1) Using AND & Multiple WHEN Clauses
Segmenting Orders
*/
 

-- Example 1 - just one clause
SELECT
    orderdate,
    quantity,
    netprice,
    CASE
        WHEN quantity >= 2 AND netprice >= 100 THEN 'High Value Order'
        ELSE 'Standard Order'
        END
FROM sales
LIMIT 10;

-- Example 2 - multiples clauses
SELECT
    orderdate,
    quantity,
    netprice,
    CASE
        WHEN quantity >= 2 AND netprice >= 100 THEN 'Multiple High Value Order'
        WHEN netprice >= 100 THEN 'Single High Value Item'
        WHEN quantity >= 2 THEN 'Multiple Standard Items'
        ELSE 'Single Standard Item'
        END
FROM sales
LIMIT 10;

-- Example 3 - multiples clauses using 'AND'
SELECT
    p.categoryname AS catgegory,
    ROUND(SUM(CASE WHEN (s.quantity * s.netprice * s.exchangerate) < 398
                AND s.orderdate BETWEEN '2022-01-01' AND '2022-12-31'
        THEN (s.quantity * s.netprice * s.exchangerate) END )::NUMERIC,2) AS low_net_rev_2022,
    
     ROUND(SUM(CASE WHEN (s.quantity * s.netprice * s.exchangerate) >= 398
                AND s.orderdate BETWEEN '2022-01-01' AND '2022-12-31'
        THEN (s.quantity * s.netprice * s.exchangerate) END )::NUMERIC,2) AS high_net_rev_2022,

    ROUND(SUM(CASE WHEN (s.quantity * s.netprice * s.exchangerate) < 398
                AND s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
        THEN (s.quantity * s.netprice * s.exchangerate) END )::NUMERIC,2) AS low_net_rev_2023,
    
     ROUND(SUM(CASE WHEN (s.quantity * s.netprice * s.exchangerate) >= 398
                AND s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
        THEN (s.quantity * s.netprice * s.exchangerate) END )::NUMERIC,2) AS high_net_rev_2023    
FROM
    sales s
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY
    p.categoryname
ORDER BY
    p.categoryname;

-- Improving the previous code adding CTE's (Automating the use of median)

WITH median_value AS (
    SELECT
        PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY s.quantity * s.netprice * s.exchangerate) AS median
    FROM 
        sales s
    WHERE
        orderdate BETWEEN '2022-01-01' AND '2023-12-31'
)

SELECT
    p.categoryname AS catgegory,
    ROUND(SUM(CASE WHEN (s.quantity * s.netprice * s.exchangerate) < mv.median
                AND s.orderdate BETWEEN '2022-01-01' AND '2022-12-31'
        THEN (s.quantity * s.netprice * s.exchangerate) END )::NUMERIC,2) AS low_net_rev_2022,
    
    ROUND(SUM(CASE WHEN (s.quantity * s.netprice * s.exchangerate) >= mv.median
                AND s.orderdate BETWEEN '2022-01-01' AND '2022-12-31'
        THEN (s.quantity * s.netprice * s.exchangerate) END )::NUMERIC,2) AS high_net_rev_2022,

    ROUND(SUM(CASE WHEN (s.quantity * s.netprice * s.exchangerate) < mv.median
                AND s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
        THEN (s.quantity * s.netprice * s.exchangerate) END )::NUMERIC,2) AS low_net_rev_2023,
    
    ROUND(SUM(CASE WHEN (s.quantity * s.netprice * s.exchangerate) >= mv.median
                AND s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
        THEN (s.quantity * s.netprice * s.exchangerate) END )::NUMERIC,2) AS high_net_rev_2023    
FROM
    sales s
    LEFT JOIN product p ON s.productkey = p.productkey,
    median_value mv
GROUP BY
    p.categoryname
ORDER BY
    p.categoryname;


/*
Categorize each sale using a CASE statement:
    - "Low" for revenue below the 25th percentile
    - "Medium" for revenue between the 25th and 75th percentiles
    - "High" for revenue above the 75th percentile
Aggregate total net revenue for each category and tier using SUM(quantity * netprice * exchangerate).
Group the results by categoryname and revenue_tier for meaningful segmentation
*/

WITH percentiles AS (
    SELECT
        PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY s.quantity * s.netprice * s.exchangerate) AS revenue_25th_percentile,
        PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY s.quantity * s.netprice * s.exchangerate) AS revenue_75th_percentile

    FROM 
        sales s
    WHERE
        orderdate BETWEEN '2022-01-01' AND '2023-12-31'
)
SELECT
    p.categoryname AS catgegory,
    CASE
        WHEN (s.quantity * s.netprice * s.exchangerate) <= pctl.revenue_25th_percentile THEN '3 - LOW'
        WHEN (s.quantity * s.netprice * s.exchangerate) >= pctl.revenue_75th_percentile THEN '1 - HIGH'
        ELSE '2 - MEDIUM'
    END AS revenue_tier,
    SUM(s.quantity * s.netprice * s.exchangerate) AS total_revenue
FROM
    sales s
    LEFT JOIN product p ON s.productkey = p.productkey,
    percentiles pctl
GROUP BY
    p.categoryname,
    revenue_tier
ORDER BY
    p.categoryname,
    revenue_tier;









