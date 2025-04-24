
-- Task 3: SQL for Data Analysis - Internship Submission
-- Database: ecommerce_demo

-- 1. Customers from Mumbai
SELECT * FROM customers
WHERE city = 'Mumbai'
ORDER BY customer_name;

-- 2. Total quantity ordered for each product
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC;

-- 3. Customer Orders Summary
SELECT 
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date;

-- 4. Customers and their order IDs (including those with no orders)
SELECT 
    c.customer_name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- 5. Customers with more than one order
SELECT customer_name FROM customers
WHERE customer_id IN (
    SELECT customer_id FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
);

-- 6. Create view: Customer Order Summary
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT 
    c.customer_name,
    o.order_id,
    SUM(oi.quantity) AS total_items
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_name, o.order_id;

-- 7. Create index on product_id
CREATE INDEX idx_product_id ON order_items(product_id);

-- 8. Total spending per customer
SELECT 
    c.customer_name,
    SUM(p.price * oi.quantity) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

-- 9. Best-selling products by category rank
SELECT 
    category,
    product_name,
    SUM(quantity) AS total_sold,
    RANK() OVER (PARTITION BY category ORDER BY SUM(quantity) DESC) AS category_rank
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY category, product_name;

-- 10. Recent orders in last 7 days
SELECT 
    o.order_id, 
    c.customer_name,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= CURDATE() - INTERVAL 7 DAY
ORDER BY o.order_date DESC;

-- 11. Customer tier classification
SELECT 
    c.customer_name,
    SUM(p.price * oi.quantity) AS total_spent,
    CASE 
        WHEN SUM(p.price * oi.quantity) > 100 THEN 'Gold'
        WHEN SUM(p.price * oi.quantity) > 50 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_name;

-- 12. Most active customers (CTE)
WITH order_counts AS (
    SELECT customer_id, COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT 
    c.customer_name, 
    oc.total_orders
FROM order_counts oc
JOIN customers c ON c.customer_id = oc.customer_id
WHERE oc.total_orders = (
    SELECT MAX(total_orders) FROM order_counts
);

-- 13. Enhanced view for dashboard
CREATE OR REPLACE VIEW detailed_order_summary AS
SELECT 
    c.customer_name,
    p.category,
    p.product_name,
    oi.quantity,
    (p.price * oi.quantity) AS revenue,
    o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- 14. Stored procedure to get top N customers
DELIMITER //
CREATE PROCEDURE top_customers(IN n INT)
BEGIN
    SELECT 
        c.customer_name,
        SUM(p.price * oi.quantity) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_name
    ORDER BY total_spent DESC
    LIMIT n;
END //
DELIMITER ;
