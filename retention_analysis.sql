-- =====================================================
-- Customer Retention & Revenue Concentration Analysis
-- PostgreSQL Project
-- Author: Estevez Enzo
-- =====================================================

-- 1. Total Revenue
SELECT 
    SUM(price + freight_value) AS total_revenue
FROM order_items;


-- 2. Revenue per Customer
SELECT 
    c.customer_unique_id,
    SUM(oi.price + oi.freight_value) AS customer_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id;


-- 3. Top 10 Customers by Revenue
SELECT 
    c.customer_unique_id,
    SUM(oi.price + oi.freight_value) AS customer_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
ORDER BY customer_revenue DESC
LIMIT 10;


-- 4. Repeat vs One-Time Customers
SELECT 
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN order_count = 1 THEN 1 END) AS one_time_customers,
    COUNT(CASE WHEN order_count > 1 THEN 1 END) AS repeat_customers
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
) sub;


-- 5. Customers Generating 80% of Revenue (Pareto Analysis)

WITH customer_revenue AS (
    SELECT 
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),
ranked AS (
    SELECT 
        customer_unique_id,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM customer_revenue
)

SELECT 
    COUNT(*) FILTER (WHERE cumulative_revenue <= total_revenue * 0.8) 
        AS customers_generating_80_percent_revenue
FROM ranked;


-- 6. Top 10 Revenue-Generating Categories

SELECT 
    p.product_category_name,
    SUM(oi.price + oi.freight_value) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY category_revenue DESC
LIMIT 10;