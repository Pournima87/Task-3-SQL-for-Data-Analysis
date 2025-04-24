
-- Create database and use it
CREATE DATABASE IF NOT EXISTS ecommerce_demo;
USE ecommerce_demo;

-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2)
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items table
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample data
INSERT INTO customers VALUES
(1, 'Pournima Sharma', 'pournima@example.com', 'Mumbai'),
(2, 'Ravi Kumar', 'ravi@example.com', 'Delhi'),
(3, 'Anita Mehta', 'anita@example.com', 'Bangalore');

INSERT INTO products VALUES
(1, 'Ice Cream Cone', 'Dessert', 30.00),
(2, 'Chocolate Shake', 'Beverage', 50.00),
(3, 'Vanilla Sundae', 'Dessert', 45.00);

INSERT INTO orders VALUES
(101, 1, '2024-04-01'),
(102, 2, '2024-04-03'),
(103, 3, '2024-04-05');

INSERT INTO order_items VALUES
(1, 101, 1, 2),
(2, 101, 2, 1),
(3, 102, 3, 1),
(4, 103, 1, 1),
(5, 103, 2, 2);
