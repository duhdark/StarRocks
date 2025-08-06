-- StarRocks Single Node Initialization Script
-- Этот скрипт создает тестовую базу данных и таблицы

-- Создание тестовой базы данных
CREATE DATABASE IF NOT EXISTS test_db;
USE test_db;

-- Создание таблицы пользователей
CREATE TABLE IF NOT EXISTS users (
    user_id INT,
    username VARCHAR(50),
    email VARCHAR(100),
    created_at DATETIME,
    is_active BOOLEAN
) DUPLICATE KEY(user_id)
DISTRIBUTED BY HASH(user_id) BUCKETS 3
PROPERTIES("replication_num" = "1");

-- Создание таблицы заказов
CREATE TABLE IF NOT EXISTS orders (
    order_id INT,
    user_id INT,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    order_date DATETIME
) DUPLICATE KEY(order_id)
DISTRIBUTED BY HASH(order_id) BUCKETS 3
PROPERTIES("replication_num" = "1");

-- Создание таблицы продуктов
CREATE TABLE IF NOT EXISTS products (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
) DUPLICATE KEY(product_id)
DISTRIBUTED BY HASH(product_id) BUCKETS 3
PROPERTIES("replication_num" = "1");

-- Вставка тестовых данных в таблицу пользователей
INSERT INTO users VALUES 
(1, 'john_doe', 'john@example.com', NOW(), true),
(2, 'jane_smith', 'jane@example.com', NOW(), true),
(3, 'bob_wilson', 'bob@example.com', NOW(), false),
(4, 'alice_brown', 'alice@example.com', NOW(), true),
(5, 'charlie_davis', 'charlie@example.com', NOW(), true);

-- Вставка тестовых данных в таблицу продуктов
INSERT INTO products VALUES 
(1, 'Laptop', 'Electronics', 999.99, 50),
(2, 'Smartphone', 'Electronics', 599.99, 100),
(3, 'Book', 'Books', 19.99, 200),
(4, 'Coffee Mug', 'Home', 9.99, 150),
(5, 'T-Shirt', 'Clothing', 24.99, 75);

-- Вставка тестовых данных в таблицу заказов
INSERT INTO orders VALUES 
(1, 1, 'Laptop', 1, 999.99, NOW()),
(2, 2, 'Smartphone', 2, 1199.98, NOW()),
(3, 3, 'Book', 3, 59.97, NOW()),
(4, 4, 'Coffee Mug', 5, 49.95, NOW()),
(5, 5, 'T-Shirt', 2, 49.98, NOW());

-- Создание представления для аналитики
CREATE VIEW user_order_summary AS
SELECT 
    u.user_id,
    u.username,
    COUNT(o.order_id) as total_orders,
    SUM(o.price * o.quantity) as total_spent,
    MAX(o.order_date) as last_order_date
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username;

-- Проверка созданных данных
SELECT 'Users count:' as info, COUNT(*) as count FROM users
UNION ALL
SELECT 'Products count:', COUNT(*) FROM products
UNION ALL
SELECT 'Orders count:', COUNT(*) FROM orders;

-- Пример аналитического запроса
SELECT 
    p.category,
    COUNT(o.order_id) as orders_count,
    SUM(o.price * o.quantity) as total_revenue,
    AVG(o.price * o.quantity) as avg_order_value
FROM products p
LEFT JOIN orders o ON p.product_name = o.product_name
GROUP BY p.category
ORDER BY total_revenue DESC; 