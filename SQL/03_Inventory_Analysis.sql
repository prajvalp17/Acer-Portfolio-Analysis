-- Acer Portfolio - Inventory Analysis
-- SQL analysis layer for inventory, stock distribution, and inventory value
-- Database: acer_portfolio

-- 1. Overall inventory summary

SELECT
    SUM(acer_stock) AS acer_stock,
    SUM(flipkart_stock) AS flipkart_stock,
    SUM(amazon_stock) AS amazon_stock,
    SUM(myntra_stock) AS myntra_stock,
    SUM(total_inventory) AS total_inventory,
    SUM(inventory_value) AS total_inventory_value
FROM inventory_sales;

-- 2. Inventory by series

SELECT
    p.series,
    SUM(i.total_inventory) AS total_inventory,
    SUM(i.inventory_value) AS inventory_value
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
ORDER BY total_inventory DESC;

-- 3. Inventory value by series

SELECT
    p.series,
    SUM(i.inventory_value) AS inventory_value
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
ORDER BY inventory_value DESC;

-- 4. Marketplace stock distribution

SELECT
    'Flipkart' AS marketplace,
    SUM(flipkart_stock) AS stock
FROM inventory_sales

UNION ALL

SELECT
    'Amazon',
    SUM(amazon_stock)
FROM inventory_sales

UNION ALL

SELECT
    'Myntra',
    SUM(myntra_stock)
FROM inventory_sales

ORDER BY stock DESC;

-- 5. Marketplace stock contribution

WITH marketplace_stock AS (
    SELECT
        'Flipkart' AS marketplace,
        SUM(flipkart_stock) AS stock
    FROM inventory_sales

    UNION ALL

    SELECT
        'Amazon',
        SUM(amazon_stock)
    FROM inventory_sales

    UNION ALL

    SELECT
        'Myntra',
        SUM(myntra_stock)
    FROM inventory_sales
)
SELECT
    marketplace,
    stock,
    ROUND(
        stock * 100.0 /
        (SELECT SUM(stock) FROM marketplace_stock),
        2
    ) AS stock_percentage
FROM marketplace_stock
ORDER BY stock DESC;

-- 6. Sales-to-inventory ratio by series

SELECT
    p.series,
    SUM(i.total_sales) AS total_sales,
    SUM(i.total_inventory) AS total_inventory,
    ROUND(
        SUM(i.total_sales) * 100.0 /
        NULLIF(SUM(i.total_inventory), 0),
        2
    ) AS sales_inventory_ratio
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
ORDER BY sales_inventory_ratio DESC;

-- 7. Products with low inventory

SELECT
    p.part_number,
    p.series,
    i.total_inventory,
    i.total_sales
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
WHERE i.total_inventory < 50
ORDER BY i.total_inventory ASC;

-- 8. Products with high inventory

SELECT
    p.part_number,
    p.series,
    i.total_inventory,
    i.total_sales,
    i.inventory_value
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
WHERE i.total_inventory > 150
ORDER BY i.total_inventory DESC;

-- 9. Stock-risk classification

SELECT
    p.part_number,
    p.series,
    i.total_sales,
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

-- 10. Inventory contribution by series

WITH series_inventory AS (
    SELECT
        p.series,
        SUM(i.total_inventory) AS total_inventory
    FROM products p
    JOIN inventory_sales i
        ON p.part_number = i.part_number
    GROUP BY p.series
)
SELECT
    series,
    total_inventory,
    ROUND(
        total_inventory * 100.0 /
        (SELECT SUM(total_inventory) FROM series_inventory),
        2
    ) AS inventory_percentage
FROM series_inventory
ORDER BY total_inventory DESC;

-- 11. Highest inventory value series

SELECT
    p.series,
    SUM(i.inventory_value) AS inventory_value
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
ORDER BY inventory_value DESC
LIMIT 1;

-- 12. Top products by inventory value

SELECT
    p.part_number,
    p.series,
    i.total_inventory,
    i.inventory_value
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
ORDER BY i.inventory_value DESC
LIMIT 10;

-- 13. Inventory versus sales performance by series

SELECT
    p.series,
    SUM(i.total_sales) AS total_sales,
    SUM(i.total_inventory) AS total_inventory,
    SUM(i.inventory_value) AS inventory_value,
    ROUND(
        SUM(i.total_sales) * 100.0 /
        NULLIF(SUM(i.total_inventory), 0),
        2
    ) AS sales_inventory_ratio
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
ORDER BY sales_inventory_ratio DESC;

-- 14. Inventory risk based on sales-to-stock ratio

SELECT
    p.part_number,
    p.series,
    i.total_sales,
    i.total_inventory,
    ROUND(
        i.total_sales * 100.0 /
        NULLIF(i.total_inventory, 0),
        2
    ) AS sales_inventory_ratio,
    CASE
        WHEN i.total_inventory < 50
             AND i.total_sales > 0
            THEN 'Replenishment Risk'
        WHEN i.total_inventory > 150
             AND i.total_sales < 5
            THEN 'Potential Excess Stock'
        ELSE 'Normal'
    END AS inventory_risk
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
ORDER BY sales_inventory_ratio DESC;

