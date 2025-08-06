-- StarRocks Cluster Initialization Script
-- Этот скрипт создает тестовую базу данных и таблицы для кластерной конфигурации

-- Создание тестовой базы данных
CREATE DATABASE IF NOT EXISTS cluster_test;
USE cluster_test;

-- Создание таблицы пользователей с репликацией
CREATE TABLE IF NOT EXISTS users (
    user_id INT,
    username VARCHAR(50),
    email VARCHAR(100),
    created_at DATETIME,
    is_active BOOLEAN,
    last_login DATETIME
) DUPLICATE KEY(user_id)
DISTRIBUTED BY HASH(user_id) BUCKETS 6
PROPERTIES("replication_num" = "3");

-- Создание таблицы заказов с репликацией
CREATE TABLE IF NOT EXISTS orders (
    order_id INT,
    user_id INT,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    order_date DATETIME,
    status VARCHAR(20)
) DUPLICATE KEY(order_id)
DISTRIBUTED BY HASH(order_id) BUCKETS 6
PROPERTIES("replication_num" = "3");

-- Создание таблицы продуктов с репликацией
CREATE TABLE IF NOT EXISTS products (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT,
    created_at DATETIME
) DUPLICATE KEY(product_id)
DISTRIBUTED BY HASH(product_id) BUCKETS 6
PROPERTIES("replication_num" = "3");

-- Создание таблицы логов с репликацией
CREATE TABLE IF NOT EXISTS user_logs (
    log_id INT,
    user_id INT,
    action VARCHAR(50),
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at DATETIME
) DUPLICATE KEY(log_id)
DISTRIBUTED BY HASH(log_id) BUCKETS 6
PROPERTIES("replication_num" = "3");

-- Вставка тестовых данных в таблицу пользователей
INSERT INTO users VALUES 
(1, 'john_doe', 'john@example.com', NOW(), true, NOW()),
(2, 'jane_smith', 'jane@example.com', NOW(), true, NOW()),
(3, 'bob_wilson', 'bob@example.com', NOW(), false, NOW()),
(4, 'alice_brown', 'alice@example.com', NOW(), true, NOW()),
(5, 'charlie_davis', 'charlie@example.com', NOW(), true, NOW()),
(6, 'diana_evans', 'diana@example.com', NOW(), true, NOW()),
(7, 'edward_frank', 'edward@example.com', NOW(), false, NOW()),
(8, 'fiona_garcia', 'fiona@example.com', NOW(), true, NOW()),
(9, 'george_harris', 'george@example.com', NOW(), true, NOW()),
(10, 'helen_ivanov', 'helen@example.com', NOW(), true, NOW());

-- Вставка тестовых данных в таблицу продуктов
INSERT INTO products VALUES 
(1, 'Laptop Dell XPS', 'Electronics', 1299.99, 50, NOW()),
(2, 'iPhone 15 Pro', 'Electronics', 999.99, 100, NOW()),
(3, 'Python Programming Book', 'Books', 29.99, 200, NOW()),
(4, 'Coffee Mug Premium', 'Home', 19.99, 150, NOW()),
(5, 'Cotton T-Shirt XL', 'Clothing', 24.99, 75, NOW()),
(6, 'Wireless Headphones', 'Electronics', 199.99, 80, NOW()),
(7, 'Yoga Mat', 'Sports', 39.99, 60, NOW()),
(8, 'Desk Lamp LED', 'Home', 49.99, 40, NOW()),
(9, 'Running Shoes', 'Sports', 89.99, 30, NOW()),
(10, 'Bluetooth Speaker', 'Electronics', 79.99, 45, NOW());

-- Вставка тестовых данных в таблицу заказов
INSERT INTO orders VALUES 
(1, 1, 'Laptop Dell XPS', 1, 1299.99, NOW(), 'completed'),
(2, 2, 'iPhone 15 Pro', 2, 1999.98, NOW(), 'completed'),
(3, 3, 'Python Programming Book', 3, 89.97, NOW(), 'completed'),
(4, 4, 'Coffee Mug Premium', 5, 99.95, NOW(), 'processing'),
(5, 5, 'Cotton T-Shirt XL', 2, 49.98, NOW(), 'completed'),
(6, 6, 'Wireless Headphones', 1, 199.99, NOW(), 'shipped'),
(7, 7, 'Yoga Mat', 1, 39.99, NOW(), 'completed'),
(8, 8, 'Desk Lamp LED', 1, 49.99, NOW(), 'processing'),
(9, 9, 'Running Shoes', 1, 89.99, NOW(), 'completed'),
(10, 10, 'Bluetooth Speaker', 2, 159.98, NOW(), 'shipped');

-- Вставка тестовых данных в таблицу логов
INSERT INTO user_logs VALUES 
(1, 1, 'login', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', NOW()),
(2, 1, 'purchase', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', NOW()),
(3, 2, 'login', '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)', NOW()),
(4, 2, 'purchase', '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)', NOW()),
(5, 3, 'login', '192.168.1.102', 'Mozilla/5.0 (X11; Linux x86_64)', NOW()),
(6, 4, 'login', '192.168.1.103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', NOW()),
(7, 4, 'purchase', '192.168.1.103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', NOW()),
(8, 5, 'login', '192.168.1.104', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)', NOW()),
(9, 5, 'purchase', '192.168.1.104', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)', NOW()),
(10, 6, 'login', '192.168.1.105', 'Mozilla/5.0 (X11; Linux x86_64)', NOW());

-- Создание представлений для аналитики
CREATE VIEW user_order_summary AS
SELECT 
    u.user_id,
    u.username,
    COUNT(o.order_id) as total_orders,
    SUM(o.price * o.quantity) as total_spent,
    MAX(o.order_date) as last_order_date,
    COUNT(CASE WHEN o.status = 'completed' THEN 1 END) as completed_orders
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username;

CREATE VIEW product_analytics AS
SELECT 
    p.category,
    COUNT(o.order_id) as orders_count,
    SUM(o.price * o.quantity) as total_revenue,
    AVG(o.price * o.quantity) as avg_order_value,
    COUNT(DISTINCT o.user_id) as unique_customers
FROM products p
LEFT JOIN orders o ON p.product_name = o.product_name
GROUP BY p.category
ORDER BY total_revenue DESC;

CREATE VIEW user_activity_summary AS
SELECT 
    u.user_id,
    u.username,
    COUNT(l.log_id) as total_actions,
    COUNT(CASE WHEN l.action = 'login' THEN 1 END) as login_count,
    COUNT(CASE WHEN l.action = 'purchase' THEN 1 END) as purchase_count,
    MAX(l.created_at) as last_activity
FROM users u
LEFT JOIN user_logs l ON u.user_id = l.user_id
GROUP BY u.user_id, u.username;

-- Проверка созданных данных
SELECT 'Users count:' as info, COUNT(*) as count FROM users
UNION ALL
SELECT 'Products count:', COUNT(*) FROM products
UNION ALL
SELECT 'Orders count:', COUNT(*) FROM orders
UNION ALL
SELECT 'Logs count:', COUNT(*) FROM user_logs;

-- Примеры аналитических запросов для кластера

-- 1. Анализ продаж по категориям
SELECT 
    p.category,
    COUNT(o.order_id) as orders_count,
    SUM(o.price * o.quantity) as total_revenue,
    AVG(o.price * o.quantity) as avg_order_value,
    COUNT(DISTINCT o.user_id) as unique_customers
FROM products p
LEFT JOIN orders o ON p.product_name = o.product_name
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 2. Активность пользователей
SELECT 
    DATE(l.created_at) as activity_date,
    COUNT(DISTINCT l.user_id) as active_users,
    COUNT(l.log_id) as total_actions,
    COUNT(CASE WHEN l.action = 'purchase' THEN 1 END) as purchases
FROM user_logs l
GROUP BY DATE(l.created_at)
ORDER BY activity_date DESC;

-- 3. Топ пользователей по тратам
SELECT 
    u.username,
    COUNT(o.order_id) as total_orders,
    SUM(o.price * o.quantity) as total_spent,
    AVG(o.price * o.quantity) as avg_order_value
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE o.order_id IS NOT NULL
GROUP BY u.user_id, u.username
ORDER BY total_spent DESC
LIMIT 10;

-- 4. Анализ статусов заказов
SELECT 
    status,
    COUNT(*) as order_count,
    SUM(price * quantity) as total_value,
    AVG(price * quantity) as avg_value
FROM orders
GROUP BY status
ORDER BY order_count DESC; 