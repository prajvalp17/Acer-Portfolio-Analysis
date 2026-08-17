-- Acer Portfolio - Business Insights
-- Final SQL analysis supporting business recommendations
-- Database: acer_portfolio

-- 1. Overall business KPIs

SELECT
    SUM(total_sales) AS total_sales,
    SUM(total_inventory) AS total_inventory,
    SUM(acer_stock) AS acer_stock,
    SUM(flipkart_stock) AS flipkart_stock,
    SUM(amazon_stock) AS amazon_stock,
    SUM(myntra_stock) AS myntra_stock,
    SUM(inventory_value) AS inventory_value
FROM inventory_sales;

-- 2. Best-selling series

SELECT
    p.series,
    SUM(i.total_sales) AS total_sales
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
ORDER BY total_sales DESC
LIMIT 1;

-- 3. Sales contribution of the top two series

WITH series_sales AS (
    SELECT
        p.series,
        SUM(i.total_sales) AS total_sales
    FROM products p
    JOIN inventory_sales i
        ON p.part_number = i.part_number
    GROUP BY p.series
),
ranked_series AS (
    SELECT
        series,
        total_sales,
        RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM series_sales
)
SELECT
    SUM(total_sales) AS top_two_sales,
    ROUND(
        SUM(total_sales) * 100.0 /
        (SELECT SUM(total_sales) FROM series_sales),
        2
    ) AS top_two_sales_percentage
FROM ranked_series
WHERE sales_rank <= 2;

-- 4. Series holding the highest inventory

SELECT
    p.series,
    SUM(i.total_inventory) AS total_inventory
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
ORDER BY total_inventory DESC
LIMIT 1;

-- 5. Series with the highest inventory value

SELECT
    p.series,
    SUM(i.inventory_value) AS inventory_value
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
ORDER BY inventory_value DESC
LIMIT 1;

-- 6. Marketplace sales leader

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
ORDER BY total_sales DESC
LIMIT 1;

-- 7. Products that may require replenishment

SELECT
    p.part_number,
    p.series,
    i.total_sales,
    i.total_inventory,
    ROUND(
        i.total_sales * 100.0 /
        NULLIF(i.total_inventory, 0),
        2
    ) AS sales_inventory_ratio
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
WHERE i.total_inventory < 100
  AND i.total_sales > 0
ORDER BY sales_inventory_ratio DESC;

-- 8. Potential excess-stock candidates

SELECT
    p.part_number,
    p.series,
    i.total_sales,
    i.total_inventory,
    i.inventory_value
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
WHERE i.total_inventory > 150
  AND i.total_sales < 5
ORDER BY i.total_inventory DESC;

-- 9. Final series performance summary

SELECT
    p.series,
    SUM(i.total_sales) AS total_sales,
    SUM(i.total_inventory) AS total_inventory,
    SUM(i.inventory_value) AS inventory_value,
    ROUND(
        SUM(i.total_sales) * 100.0 /
        NULLIF(SUM(i.total_inventory), 0),
        2
    ) AS sales_inventory_ratio,
    CASE
        WHEN SUM(i.total_inventory) > 1500
             THEN 'High Inventory'
        WHEN SUM(i.total_inventory) < 100
             THEN 'Low Inventory'
        ELSE 'Normal Inventory'
    END AS inventory_status
FROM products p
JOIN inventory_sales i
    ON p.part_number = i.part_number
GROUP BY p.series
ORDER BY total_sales DESC;

-- 10. Final data validation

SELECT
    COUNT(*) AS product_records,
    SUM(total_sales) AS total_sales,
    SUM(total_inventory) AS total_inventory,
    SUM(acer_stock) AS acer_stock,
    SUM(flipkart_stock) AS flipkart_stock,
    SUM(amazon_stock) AS amazon_stock,
    SUM(myntra_stock) AS myntra_stock,
    SUM(inventory_value) AS inventory_value
FROM inventory_sales;

