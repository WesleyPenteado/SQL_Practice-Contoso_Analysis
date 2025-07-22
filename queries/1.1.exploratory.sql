-- All tables view
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- Specific Tables

SELECT *
FROM currencyexchange
LIMIT 10

-- Structure and column type of each table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'currencyexchange';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'customer';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'sales';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'date';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'product';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'store';

-- Count lines for each tables
SELECT 'currencyexchange' AS tabela, COUNT(*) FROM currencyexchange
UNION ALL
SELECT 'customer', COUNT(*) FROM customer
UNION ALL
SELECT 'date', COUNT(*) FROM date
UNION ALL
SELECT 'product', COUNT(*) FROM product
UNION ALL
SELECT 'sales', COUNT(*) FROM sales
UNION ALL
SELECT 'store', COUNT(*) FROM store;