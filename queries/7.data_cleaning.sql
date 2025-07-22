-- Creating a table to practice
CREATE TABLE data_jobs (
    id INT,
    job_title VARCHAR(30),
    is_real_job VARCHAR(20),
    salary INT
);

INSERT INTO data_jobs VALUES
(1, 'Data Analyst', 'yes', NULL),
(2, 'Data Scientist', NULL, 140000),
(3, 'Data Engineer', 'kinda', 120000);

SELECT * FROM data_jobs;


/*
COALESCE()
- Replace NULL values with a default
*/

SELECT
    job_title,
    COALESCE(is_real_job, 'no') AS is_real_job,
    COALESCE(salary::TEXT, job_title) AS salary
FROM data_jobs;


/*
NULL()
- Returns NULL if two expressions are equal or returns the first expression
*/

SELECT
    job_title,
    NULLIF(is_real_job, 'kinda') AS is_real_job,
    salary
FROM data_jobs;

---------------------- Real World Exercises -------------------------


-- Using COALESCE
WITH sales_data AS (
    SELECT
        customerkey,
        SUM(quantity * netprice * exchangerate) AS net_revenue
    FROM sales
    GROUP BY
        customerkey
)
SELECT
    AVG(s.net_revenue) as spending_customers_avg_revenue,
    AVG(COALESCE(s.net_revenue, 0)) AS all_customers_avg_net_revenue
FROM customer c
LEFT JOIN sales_data s ON c.customerkey = s.customerkey;





/*

STRING FORMATING
- UPPER, LOWER, TRIM

*/

SELECT 
    LOWER('EXAMPLE number 2'),
    UPPER('example NUMBER 1'),
    TRIM(' Removing Spaces before and after strings ');




