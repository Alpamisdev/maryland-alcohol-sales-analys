--- Creating raw table to import to db

CREATE TABLE sales_raw (
    year TEXT,
    month TEXT,
    supplier TEXT,
    item_code TEXT,
    item_description TEXT,
    item_type TEXT,
    retail_sales TEXT,
    retail_transfers TEXT,
    warehouse_sales TEXT
);

-- \copy sales_raw FROM 'MarylandAlcoholSales.csv' WITH (FORMAT csv, HEADER true)

SELECT * FROM sales_raw;


--- We found a value that is not numeric like this (1.00) after this query 
--- invalid input syntax for type numeric: "(1.00)"
--- After cleaning retail_sales, retail_transfers, warehouse_sales we put to sales table their cleaned versions.
CREATE TABLE sales AS
SELECT
    year::SMALLINT AS calendar_year,
    month::SMALLINT AS calendar_month_num,
    MAKE_DATE(year::INT, month::INT, 1) AS period,
    NULLIF(TRIM(supplier), '') AS supplier,
    NULLIF(TRIM(item_code), '') AS item_code,
    NULLIF(TRIM(item_description), '') AS item_description,
    NULLIF(TRIM(item_type), '') AS item_type,
    NULLIF(TRIM(retail_sales_clean), '')::NUMERIC AS retail_sales,
    NULLIF(TRIM(retail_transfers_clean), '')::NUMERIC AS retail_transfers,
    NULLIF(TRIM(warehouse_sales_clean), '')::NUMERIC AS warehouse_sales
FROM sales_raw;


--- Looking for no normal numbers
SELECT 'retail_sales' AS col, retail_sales AS val, COUNT(*) AS n
FROM sales_raw
WHERE TRIM(retail_sales) <> '' AND TRIM(retail_sales) !~ '^-?[0-9]+(\.[0-9]+)?$'
GROUP BY 1, 2
ORDER BY n DESC;

SELECT 'retail_transfers' AS col, retail_transfers AS val, COUNT(*) AS n
FROM sales_raw
WHERE TRIM(retail_transfers) <> '' AND TRIM(retail_transfers) !~ '^-?[0-9]+(\.[0-9]+)?$'
GROUP BY 1, 2
ORDER BY n DESC;

SELECT 'warehouse_sales' AS col, warehouse_sales AS val, COUNT(*) AS n
FROM sales_raw
WHERE TRIM(warehouse_sales) <> '' AND TRIM(warehouse_sales) !~ '^-?[0-9]+(\.[0-9]+)?$'
GROUP BY 1, 2
ORDER BY n DESC;

SELECT *
FROM sales_raw
WHERE TRIM(retail_sales) <> ''
  AND TRIM(retail_sales) !~ '^-?[0-9]+(\.[0-9]+)?$'
LIMIT 50;

--- 1. Cleaning retail sales

SELECT retail_sales,
CASE WHEN NULLIF(TRIM(retail_sales), '') IS NULL THEN NULL
    WHEN TRIM(retail_sales) ~ '^\(.+\)$' THEN -1 * REGEXP_REPLACE(TRIM(retail_sales), '[(),]', '', 'g')::NUMERIC
    ELSE REPLACE(TRIM(retail_sales), ',', '')::NUMERIC
    END
FROM sales_raw
WHERE TRIM(retail_sales) <> ''
  AND TRIM(retail_sales) !~ '^-?[0-9]+(\.[0-9]+)?$';

ALTER TABLE sales_raw
ADD retail_sales_clean TEXT;

UPDATE sales_raw
SET retail_sales_clean = CASE WHEN NULLIF(TRIM(retail_sales), '') IS NULL THEN NULL
    WHEN TRIM(retail_sales) ~ '^\(.+\)$' THEN -1 * REGEXP_REPLACE(TRIM(retail_sales), '[(),]', '', 'g')::NUMERIC
    ELSE REPLACE(TRIM(retail_sales), ',', '')::NUMERIC
    END;

--- 2. Cleaning retail transfers

SELECT retail_transfers,
CASE WHEN NULLIF(TRIM(retail_transfers), '') IS NULL THEN NULL
    WHEN TRIM(retail_transfers) ~ '^\(.+\)$' THEN -1 * REGEXP_REPLACE(TRIM(retail_transfers), '[(),]', '', 'g')::NUMERIC
    ELSE REPLACE(TRIM(retail_transfers), ',', '')::NUMERIC
    END
FROM sales_raw
WHERE TRIM(retail_transfers) <> ''
  AND TRIM(retail_transfers) !~ '^-?[0-9]+(\.[0-9]+)?$';

ALTER TABLE sales_raw
ADD retail_transfers_clean TEXT;

UPDATE sales_raw
SET retail_transfers_clean = CASE WHEN NULLIF(TRIM(retail_transfers), '') IS NULL THEN NULL
    WHEN TRIM(retail_transfers) ~ '^\(.+\)$' THEN -1 * REGEXP_REPLACE(TRIM(retail_transfers), '[(),]', '', 'g')::NUMERIC
    ELSE REPLACE(TRIM(retail_transfers), ',', '')::NUMERIC
    END;

SELECT * FROM sales_raw LIMIT 50;

--- 3. Cleaning warehouse sales

SELECT warehouse_sales,
CASE WHEN NULLIF(TRIM(warehouse_sales), '') IS NULL THEN NULL
    WHEN TRIM(warehouse_sales) ~ '^\(.+\)$' THEN -1 * REGEXP_REPLACE(TRIM(warehouse_sales), '[(),]', '', 'g')::NUMERIC
    ELSE REPLACE(TRIM(warehouse_sales), ',', '')::NUMERIC
    END
FROM sales_raw
WHERE TRIM(warehouse_sales) <> ''
  AND TRIM(warehouse_sales) !~ '^-?[0-9]+(\.[0-9]+)?$';

ALTER TABLE sales_raw
ADD warehouse_sales_clean TEXT;

UPDATE sales_raw
SET warehouse_sales_clean = CASE WHEN NULLIF(TRIM(warehouse_sales), '') IS NULL THEN NULL
    WHEN TRIM(warehouse_sales) ~ '^\(.+\)$' THEN -1 * REGEXP_REPLACE(TRIM(warehouse_sales), '[(),]', '', 'g')::NUMERIC
    ELSE REPLACE(TRIM(warehouse_sales), ',', '')::NUMERIC
    END;

SELECT * FROM sales_raw LIMIT 1000;

