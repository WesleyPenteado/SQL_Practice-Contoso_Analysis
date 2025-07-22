-- Daily Revenue

CREATE VIEW daily_revenue AS
SELECT
    orderdate,
    SUM(quantity * netprice * exchangerate) AS total_revenue
FROM sales
GROUP BY orderdate
ORDER BY orderdate DESC

-- Possibility to use as a table
SELECT *
FROM daily_revenue

-- Delete the view
DROP VIEW daily_revenue

-- Altering a view
ALTER VIEW cohort_analysis RENAME COLUMN count TO num_orders

