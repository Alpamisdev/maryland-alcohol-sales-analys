--- We are looking for how many suppliers we have
--- 542 unique suppliers
SELECT COUNT(DISTINCT supplier) AS number_of_suppliers
FROM sales;

--- TOP 5 suplliers in retail_sales
WITH pct_suppliers AS (
SELECT supplier, SUM(retail_sales) AS cases_suppliers
FROM sales
WHERE supplier IS NOT NULL AND item_type IS DISTINCT FROM 'NON-ALCOHOL'
GROUP BY supplier
HAVING SUM(retail_sales) > 0
)
SELECT supplier, cases_suppliers, ROUND(cases_suppliers/SUM(cases_suppliers) OVER () * 100, 2) AS pct_total_cases
FROM pct_suppliers
ORDER BY 3 DESC
LIMIT 5;

--- HHI index is 315 | 474 suppliers right now | The number of eefective suppliers should be in this HHI are 31.7 ~ 32 not 474
WITH pct_suppliers AS (
SELECT supplier, SUM(retail_sales) AS cases_suppliers
FROM sales
WHERE supplier IS NOT NULL AND item_type IS DISTINCT FROM 'NON-ALCOHOL'
GROUP BY supplier
HAVING SUM(retail_sales) > 0
-- ORDER BY 2 DESC
), pct AS (
SELECT supplier, cases_suppliers, cases_suppliers/SUM(cases_suppliers) OVER () * 100 AS pct_total_cases
FROM pct_suppliers
-- ORDER BY 3 DESC
)
SELECT 
COUNT(*) AS suppliers,
ROUND(SUM(pct_total_cases * pct_total_cases), 0) AS hhi,
ROUND(10000 / SUM(pct_total_cases * pct_total_cases), 1) AS effective_suppliers
FROM pct;

--- Counting how many products gave 80% 15% and 5% of sales for 2026
--- 80% - 1277 items | 15% - 1549 | 5% 3664
WITH percent_from_total AS(
    SELECT item_description, SUM(retail_sales) AS sales_by_product
    FROM sales
    WHERE item_type IS DISTINCT FROM 'NON-ALCOHOL'
    AND calendar_year = 2026
    AND retail_sales > 0
    GROUP BY item_description
    -- ORDER BY 2 DESC;
), pct AS(
SELECT 
    item_description, 
    sales_by_product, 
    (sales_by_product/SUM(sales_by_product) OVER ())*100 AS pct_from_total, 
    100*SUM(sales_by_product) OVER (ORDER BY sales_by_product DESC, item_description ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(sales_by_product) OVER() AS cumulative_pct
FROM percent_from_total
), abc AS(
SELECT 
    item_description, 
    sales_by_product, 
    pct_from_total, 
    cumulative_pct, 
    CASE 
        WHEN cumulative_pct - pct_from_total <= 80 THEN 'A' 
        WHEN cumulative_pct - pct_from_total <= 95 THEN 'B' 
        WHEN cumulative_pct - pct_from_total <= 100 THEN 'C' 
    END AS abc_category
FROM pct
)
SELECT 
COUNT(abc_category) FILTER (WHERE abc_category = 'A') AS a_category,
COUNT(abc_category) FILTER (WHERE abc_category = 'B') AS b_category,
COUNT(abc_category) FILTER (WHERE abc_category = 'C') AS c_category,
COUNT(abc_category) AS total_products_number
FROM abc;

--- TOP 15 products in A category
--- Devideing product to ABC categories for 2026
WITH percent_from_total AS(
    SELECT item_description, SUM(retail_sales) AS sales_by_product
    FROM sales
    WHERE item_type IS DISTINCT FROM 'NON-ALCOHOL'
    AND calendar_year = 2026
    AND retail_sales > 0
    GROUP BY item_description
    -- ORDER BY 2 DESC;
), pct AS(
SELECT 
    item_description, 
    sales_by_product, 
    (sales_by_product/SUM(sales_by_product) OVER ())*100 AS pct_from_total, 
    100*SUM(sales_by_product) OVER (ORDER BY sales_by_product DESC, item_description ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(sales_by_product) OVER() AS cumulative_pct
FROM percent_from_total
), abc AS(
SELECT 
    item_description, 
    sales_by_product, 
    pct_from_total, 
    cumulative_pct, 
    CASE 
        WHEN cumulative_pct - pct_from_total <= 80 THEN 'A' 
        WHEN cumulative_pct - pct_from_total <= 95 THEN 'B' 
        WHEN cumulative_pct - pct_from_total <= 100 THEN 'C' 
    END AS abc_category
FROM pct
)
SELECT 
item_description, 
sales_by_product, 
pct_from_total,
abc_category
FROM abc
WHERE abc_category = 'A'
LIMIT 15;

--- TOP 15 products in B category
--- Devideing product to ABC categories for 2026
WITH percent_from_total AS(
    SELECT item_description, SUM(retail_sales) AS sales_by_product
    FROM sales
    WHERE item_type IS DISTINCT FROM 'NON-ALCOHOL'
    AND calendar_year = 2026
    AND retail_sales > 0
    GROUP BY item_description
    -- ORDER BY 2 DESC;
), pct AS(
SELECT 
    item_description, 
    sales_by_product, 
    (sales_by_product/SUM(sales_by_product) OVER ())*100 AS pct_from_total, 
    100*SUM(sales_by_product) OVER (ORDER BY sales_by_product DESC, item_description ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(sales_by_product) OVER() AS cumulative_pct
FROM percent_from_total
), abc AS(
SELECT 
    item_description, 
    sales_by_product, 
    pct_from_total, 
    cumulative_pct, 
    CASE 
        WHEN cumulative_pct - pct_from_total <= 80 THEN 'A' 
        WHEN cumulative_pct - pct_from_total <= 95 THEN 'B' 
        WHEN cumulative_pct - pct_from_total <= 100 THEN 'C' 
    END AS abc_category
FROM pct
)
SELECT 
item_description, 
sales_by_product, 
pct_from_total,
abc_category
FROM abc
WHERE abc_category = 'B'
LIMIT 15;

--- TOP 15 products in C category
--- Devideing product to ABC categories for 2026
WITH percent_from_total AS(
    SELECT item_description, SUM(retail_sales) AS sales_by_product
    FROM sales
    WHERE item_type IS DISTINCT FROM 'NON-ALCOHOL'
    AND calendar_year = 2026
    AND retail_sales > 0
    GROUP BY item_description
    -- ORDER BY 2 DESC;
), pct AS(
SELECT 
    item_description, 
    sales_by_product, 
    (sales_by_product/SUM(sales_by_product) OVER ())*100 AS pct_from_total, 
    100*SUM(sales_by_product) OVER (ORDER BY sales_by_product DESC, item_description ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(sales_by_product) OVER() AS cumulative_pct
FROM percent_from_total
), abc AS(
SELECT 
    item_description, 
    sales_by_product, 
    pct_from_total, 
    cumulative_pct, 
    CASE 
        WHEN cumulative_pct - pct_from_total <= 80 THEN 'A' 
        WHEN cumulative_pct - pct_from_total <= 95 THEN 'B' 
        WHEN cumulative_pct - pct_from_total <= 100 THEN 'C' 
    END AS abc_category
FROM pct
)
SELECT 
item_description, 
sales_by_product, 
pct_from_total,
abc_category
FROM abc
WHERE abc_category = 'C'
LIMIT 15;
