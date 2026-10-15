SELECT *
FROM sales
LIMIT 50;


--- 6 NULL in Reail Sales
--- All of them non-alcohol items
SELECT *
FROM sales
WHERE retail_sales IS NULL;

--- 0 Null
SELECT *
FROM sales
WHERE retail_transfers IS NULL;

--- 0 Null
SELECT *
FROM sales
WHERE warehouse_sales IS NULL;


--- 204 NULL
SELECT *, COUNT(*) OVER() AS null_supllier
FROM sales
WHERE supplier IS NULL;

--- All rows where suppliers are null are not alcohol drinks
SELECT DISTINCT(item_code), item_description
FROM sales
WHERE supplier IS NULL
ORDER BY item_code DESC;


--- Looking for Duplicates
SELECT period, supplier, item_code, COUNT(*) AS row_count
FROM sales
GROUP BY period, supplier, item_code
HAVING COUNT(*) > 1
ORDER BY row_count DESC;


