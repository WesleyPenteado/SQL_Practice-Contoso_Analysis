-- Calculating Net Revenue considering exchange rate

SELECT
    orderdate,
    quantity * netprice * exchangerate AS net_revenue
FROM sales
LIMIT 10

/*
Calculating Net Revenue considering exchange rate filtering
by 2021 or greater
*/

SELECT
    orderdate,
    quantity * netprice * exchangerate AS net_revenue
FROM sales
WHERE
    orderdate::date >= '2020-01-01' --specifie when it's date related
LIMIT 10

/*
Calculating Net Revenue considering exchange rate filtering
by 2021 or greater and including who order that and details
from product.
*/

SELECT
    s.orderdate,
    s.quantity * s.netprice * s.exchangerate AS net_revenue,
    c.givenname,
    c.surname,
    c.countryfull,
    c.continent,
    p.productkey,
    p.productname,
    p.categoryname,
    p.subcategoryname
FROM 
    sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
LEFT JOIN product p ON s.productkey = p.productkey
WHERE
    orderdate::date >= '2020-01-01' --specifie when it's date related
LIMIT 10


/*
Calculating Net Revenue considering exchange rate filtering
by 2021 or greater and including who order that and details
from product.
Bin sales by categories. Greater than 1k and less 1k.
*/

SELECT
    s.orderdate,
    s.quantity * s.netprice * s.exchangerate AS net_revenue,
    c.givenname,
    c.surname,
    c.countryfull,
    c.continent,
    p.productkey,
    p.productname,
    p.categoryname,
    p.subcategoryname,
    CASE WHEN s.quantity * s.netprice * s.exchangerate > 1000
    THEN 'HIGH' ELSE 'LOW' END AS high_low
FROM 
    sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
LEFT JOIN product p ON s.productkey = p.productkey
WHERE
    orderdate::date >= '2020-01-01'; --specifie when it's date related