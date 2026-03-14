-- ================================================
-- Olist E-commerce Analysis
-- ================================================

-- ------------------------------------------------
-- 1. Order count by status
-- ------------------------------------------------
SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset 
GROUP BY order_status;

-- ------------------------------------------------
-- 2. Monthly revenue (delivered orders only)
-- ------------------------------------------------
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(i.price), 2) AS monthly_revenue
FROM olist_order_items_dataset i
JOIN olist_orders_dataset o ON i.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY 1;

-- ------------------------------------------------
-- 3. Cancellation rate by month
-- ------------------------------------------------
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(order_status = 'canceled') * 100 / COUNT(*), 2) AS cancel_rate
FROM olist_orders_dataset
GROUP BY month
ORDER BY 2;

-- ------------------------------------------------
-- 4. Top 10 sellers by revenue
-- ------------------------------------------------
SELECT 
    i.seller_id AS seller,
    ROUND(SUM(i.price), 2) AS revenue
FROM olist_order_items_dataset i
JOIN olist_sellers_dataset s ON i.seller_id = s.seller_id
GROUP BY seller
ORDER BY revenue DESC
LIMIT 10;

-- ------------------------------------------------
-- 5. Repeat buyers
-- ------------------------------------------------
SELECT 
    c.customer_unique_id AS customer,
    COUNT(o.order_id) AS order_count
FROM olist_customers_dataset c
JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
GROUP BY customer
HAVING order_count > 1
ORDER BY order_count DESC;

-- ------------------------------------------------
-- 6. Revenue by product category
-- ------------------------------------------------
WITH translated_product AS (
    SELECT 
        COALESCE(p.product_category_name_english, 
                 o.product_category_name) AS prodname, 
        o.product_id AS product 
    FROM olist_products_dataset o
    LEFT JOIN product_category_name_translation p
        ON o.product_category_name = p.product_category_name
)
SELECT 
    t.prodname AS category,
    ROUND(SUM(o.price), 2) AS revenue
FROM olist_order_items_dataset o
JOIN translated_product t ON o.product_id = t.product
GROUP BY category
HAVING category IS NOT NULL
ORDER BY revenue DESC;

-- ------------------------------------------------
-- 7. Delivery time: actual vs estimated (monthly)
-- ------------------------------------------------
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, 
                       order_purchase_timestamp)), 1) AS actual_days,
    ROUND(AVG(DATEDIFF(order_estimated_delivery_date, 
                       order_purchase_timestamp)), 1) AS estimated_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;