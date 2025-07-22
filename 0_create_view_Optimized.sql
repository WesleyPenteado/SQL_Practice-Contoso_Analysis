EXPLAIN ANALYSE -- 699.289 ms

CREATE VIEW cohort_analysis AS
WITH customer_revenue AS (
      SELECT s.customerkey,
         s.orderdate,
         round(sum(s.quantity::double precision * s.netprice * s.exchangerate)::numeric, 2) AS total_net_revenue,
         count(s.orderkey) AS num_orders,
         MAX(c.countryfull) AS countryfull, -- Reduced from groupby using MAX (This values doesn't change)
         MAX(c.age) AS age,
         MAX(c.givenname) AS givenname,
         MAX(c.surname) AS surname
         FROM sales s
            INNER JOIN customer c ON c.customerkey = s.customerkey -- changed to INNER JOIN
         GROUP BY s.customerkey, s.orderdate
      )
SELECT customerkey,
   orderdate,
   total_net_revenue,
   num_orders,
   countryfull,
   age,
   concat(TRIM(BOTH FROM givenname), ' ', TRIM(BOTH FROM surname)) AS cleaned_name,
   min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
   EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM customer_revenue cr;