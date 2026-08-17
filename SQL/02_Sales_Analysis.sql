-- Acer Portfolio - Sales Analysis
-- SQL analysis layer for the Acer internship project
-- Database: acer_portfolio

-- 1. Sales ranking by suitcase series

WITH series_summary AS (
    SELECT
        p.series,
        SUM(i.total_sales) AS total_sales,
        SUM(i.total_inventory) AS total_inventory
    FROM products p
    JOIN inventory_sales i
        ON p.part_number = i.part_number
    GROUP BY p.series
)
SELECT
    series,
    total_sales,
    total_inventory,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM series_summary
ORDER BY sales_rank;

-- 2. Total sales by marketplace

SELECT
    'Flipkart' AS marketplace,
    SUM(flipkart_sales) AS total_sales
FROM inventory_sales

UNION ALL

SELECT
    'Amazon' AS marketplace,
    SUM(amazon_sales) AS total_sales
FROM inventory_sales

UNION ALL

SELECT
    'Myntra' AS marketplace,
    SUM(myntra_sales) AS total_sales
FROM inventory_sales

ORDER BY total_sales DESC;

-- 3. Products with inventory above 50 units

SELECT
    p.part_number,
    p.series,
    i.total_inventory,
    i.total_sales
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
WHERE i.total_inventory > 50
ORDER BY i.total_inventory DESC;

-- 4. Average sales and inventory per product

SELECT
    COUNT(*) AS product_count,
    ROUND(AVG(total_sales), 2) AS avg_sales_per_product,
    ROUND(AVG(total_inventory), 2) AS avg_inventory_per_product
FROM inventory_sales;

-- 5. Classify products by inventory level

SELECT
    p.part_number,
    p.series,
    i.total_inventory,
    CASE
        WHEN i.total_inventory < 50 THEN 'Low Stock'
        WHEN i.total_inventory <= 150 THEN 'Moderate Stock'
        ELSE 'High Stock'
    END AS stock_status
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
ORDER BY i.total_inventory;

-- 6. Series with inventory above 500 units

SELECT
    p.series,
    SUM(i.total_inventory) AS total_inventory,
    SUM(i.total_sales) AS total_sales
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
HAVING SUM(i.total_inventory) > 500
ORDER BY total_inventory DESC;

-- 7. Series with sales above the average series sales

SELECT
    p.series,
    SUM(i.total_sales) AS total_sales
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
HAVING SUM(i.total_sales) > (
    SELECT AVG(series_sales)
    FROM (
        SELECT
            SUM(i2.total_sales) AS series_sales
        FROM products p2
        JOIN inventory_sales i2
            ON p2.part_number = i2.part_number
        GROUP BY p2.series
    ) AS series_totals
)
ORDER BY total_sales DESC;

-- 8. Series performance summary using a CTE

WITH series_summary AS (
    SELECT
        p.series,
        SUM(i.total_sales) AS total_sales,
        SUM(i.total_inventory) AS total_inventory
    FROM products p
    JOIN inventory_sales i
        ON p.part_number = i.part_number
    GROUP BY p.series
)
SELECT
    series,
    total_sales,
    total_inventory
FROM series_summary
ORDER BY total_sales DESC;

-- 9. Rank series by total sales

WITH series_summary AS (
    SELECT
        p.series,
        SUM(i.total_sales) AS total_sales,
        SUM(i.total_inventory) AS total_inventory
    FROM products p
    JOIN inventory_sales i
        ON p.part_number = i.part_number
    GROUP BY p.series
)
SELECT
    series,
    total_sales,
    total_inventory,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM series_summary
ORDER BY sales_rank;

-- 10. Rank products by sales within each series

SELECT
    p.part_number,
    p.series,
    i.total_sales,
    RANK() OVER (
        PARTITION BY p.series
        ORDER BY i.total_sales DESC
    ) AS product_sales_rank
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
ORDER BY p.series, product_sales_rank;

-- 11. Marketplace sales contribution

WITH marketplace_sales AS (
    SELECT
        'Flipkart' AS marketplace,
        SUM(flipkart_sales) AS total_sales
    FROM inventory_sales

    UNION ALL

    SELECT
        'Amazon',
        SUM(amazon_sales)
    FROM inventory_sales

    UNION ALL

    SELECT
        'Myntra',
        SUM(myntra_sales)
    FROM inventory_sales
)
SELECT
    marketplace,
    total_sales,
    ROUND(
        total_sales * 100.0 /
        (SELECT SUM(total_sales) FROM marketplace_sales),
        2
    ) AS sales_percentage
FROM marketplace_sales
ORDER BY total_sales DESC;

