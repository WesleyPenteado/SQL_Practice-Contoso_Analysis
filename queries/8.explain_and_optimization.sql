/*
EXPLAIN
    Displays the execution plan of a SQL query, showing how PostgresSQL will execute it


EXPLAIN ANALYSE
    Executes the query and provides actual execution times, row estimates, and other runtime details

*/

EXPLAIN ANALYSE
SELECT *
FROM SALES;


EXPLAIN ANALYSE
SELECT
    customerkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM SALES
WHERE orderdate >= '2024-01-01'
GROUP BY
    customerkey;



/*
----------------BEGINNER

- Avoid SELECT *
- Use of LIMIT
- Use WHERE vs. HAVING

*/




/*
LIMIT for large datasets

*/

EXPLAIN ANALYSE
SELECT *
FROM SALES;

EXPLAIN ANALYSE
SELECT *
FROM SALES
LIMIT 10;


/*
WHERE instead of HAVING

*/

EXPLAIN ANALYSE
SELECT
    customerkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM SALES
WHERE customerkey = '1'
GROUP BY
    customerkey
HAVING SUM(quantity * netprice * exchangerate) > 1000;  



EXPLAIN ANALYSE
SELECT
    customerkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM SALES
WHERE customerkey = '1'
GROUP BY
    customerkey;   


/*
----------------INTERMEDIATE

- Use Query Execution Plans
- Minimize GROUP BY Usage
- Reduce Joins When Possible
- Optimize ORDER BY

*/


-- Minimize GROUP BY Usage

EXPLAIN ANALYSE -- 281.108 ms
SELECT
    customerkey,
    orderdate,
    orderkey,
    linenumber,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales 
GROUP BY
customerkey,
    orderdate,
    orderkey,
    linenumber;


EXPLAIN ANALYSE -- 152.876 ms
SELECT
    customerkey,
    orderdate,
    orderkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales 
GROUP BY
customerkey,
    orderdate,
    orderkey;



-- Reduce Joins When Possible

EXPLAIN ANALYSE -- 391.706 ms
SELECT
    c.customerkey,
    c.givenname,
    c.surname,
    p.productname,
    s.orderdate,
    s.orderkey,
    d.year
FROM sales s
INNER JOIN customer c on s.customerkey = c.customerkey
INNER JOIN product p ON p.productkey = s.productkey
INNER JOIN date d ON d.date = s.orderdate


EXPLAIN ANALYSE -- 274.661 ms
SELECT
    c.customerkey,
    c.givenname,
    c.surname,
    p.productname,
    s.orderdate,
    s.orderkey,
    EXTRACT(YEAR FROM s.orderdate) AS year --Extracting instead of JOIN's
FROM sales s
INNER JOIN customer c on s.customerkey = c.customerkey
INNER JOIN product p ON p.productkey = s.productkey;


/*
-- Optimize ORDER BY
1) Limit number of columns in order by
2) Avoid sorting on computed columns or function calls
3) Columns that filter out more rows should come first
4) Use indexed columns for sorting to leverage existing database indexes (If you can)

*/

EXPLAIN ANALYSE -- 233.380 ms
SELECT
    customerkey,
    orderdate,
    orderkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales 
GROUP BY
    customerkey,
    orderdate,
    orderkey
ORDER BY
    net_revenue DESC,
    customerkey,
    orderdate,
    orderkey;


EXPLAIN ANALYSE -- 156.280 ms
SELECT
    customerkey,
    orderdate,
    orderkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales 
GROUP BY
    customerkey,
    orderdate,
    orderkey
ORDER BY
    customerkey,
    orderdate,
    orderkey;
