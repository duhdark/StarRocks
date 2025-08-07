-- StarRocks SQL Examples
-- Примеры SQL запросов для работы с StarRocks

-- ===========================================
-- 1. СОЗДАНИЕ БАЗЫ ДАННЫХ И ТАБЛИЦ
-- ===========================================

-- Создание базы данных
CREATE DATABASE IF NOT EXISTS demo_db;
USE demo_db;

-- Создание таблицы пользователей
CREATE TABLE users (
    id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    age INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 3;

-- Создание таблицы заказов
CREATE TABLE orders (
    id INT,
    user_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    quantity INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP
) DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 3;

-- Создание таблицы продуктов
CREATE TABLE products (
    id INT,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock INT
) DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 3;

-- ===========================================
-- 2. ВСТАВКА ДАННЫХ
-- ===========================================

-- Вставка пользователей
INSERT INTO users VALUES 
(1, 'Иван Иванов', 'ivan@example.com', 25, '2024-01-01 10:00:00'),
(2, 'Мария Петрова', 'maria@example.com', 30, '2024-01-02 11:00:00'),
(3, 'Алексей Сидоров', 'alex@example.com', 28, '2024-01-03 12:00:00'),
(4, 'Елена Козлова', 'elena@example.com', 35, '2024-01-04 13:00:00'),
(5, 'Дмитрий Волков', 'dmitry@example.com', 27, '2024-01-05 14:00:00');

-- Вставка продуктов
INSERT INTO products VALUES 
(1, 'Ноутбук Dell', 'Электроника', 45000.00, 10),
(2, 'Смартфон iPhone', 'Электроника', 65000.00, 15),
(3, 'Книга "SQL для начинающих"', 'Книги', 1200.00, 50),
(4, 'Кофемашина', 'Бытовая техника', 25000.00, 5),
(5, 'Наушники Sony', 'Электроника', 8000.00, 20);

-- Вставка заказов
INSERT INTO orders VALUES 
(1, 1, 'Ноутбук Dell', 45000.00, 1, '2024-01-10 09:00:00'),
(2, 2, 'Смартфон iPhone', 65000.00, 1, '2024-01-11 10:00:00'),
(3, 1, 'Книга "SQL для начинающих"', 1200.00, 2, '2024-01-12 11:00:00'),
(4, 3, 'Кофемашина', 25000.00, 1, '2024-01-13 12:00:00'),
(5, 4, 'Наушники Sony', 8000.00, 1, '2024-01-14 13:00:00'),
(6, 2, 'Наушники Sony', 8000.00, 1, '2024-01-15 14:00:00'),
(7, 5, 'Смартфон iPhone', 65000.00, 1, '2024-01-16 15:00:00');

-- ===========================================
-- 3. ПРОСТЫЕ ЗАПРОСЫ
-- ===========================================

-- Показать всех пользователей
SELECT * FROM users;

-- Показать всех пользователей старше 25 лет
SELECT * FROM users WHERE age > 25;

-- Показать пользователей с сортировкой по возрасту
SELECT * FROM users ORDER BY age DESC;

-- Подсчитать количество пользователей
SELECT COUNT(*) as total_users FROM users;

-- Средний возраст пользователей
SELECT AVG(age) as avg_age FROM users;

-- ===========================================
-- 4. СЛОЖНЫЕ ЗАПРОСЫ
-- ===========================================

-- Объединение таблиц: заказы с информацией о пользователях
SELECT 
    o.id as order_id,
    u.name as user_name,
    o.product_name,
    o.price,
    o.order_date
FROM orders o
JOIN users u ON o.user_id = u.id
ORDER BY o.order_date DESC;

-- Топ-3 пользователя по сумме заказов
SELECT 
    u.name,
    COUNT(o.id) as order_count,
    SUM(o.price * o.quantity) as total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC
LIMIT 3;

-- Статистика по категориям продуктов
SELECT 
    p.category,
    COUNT(*) as product_count,
    AVG(p.price) as avg_price,
    SUM(p.stock) as total_stock
FROM products p
GROUP BY p.category;

-- Заказы за последние 7 дней
SELECT 
    o.id,
    u.name as user_name,
    o.product_name,
    o.price,
    o.order_date
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY o.order_date DESC;

-- ===========================================
-- 5. АГРЕГАЦИЯ И АНАЛИТИКА
-- ===========================================

-- Ежемесячная статистика продаж
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') as month,
    COUNT(*) as orders_count,
    SUM(price * quantity) as total_revenue,
    AVG(price * quantity) as avg_order_value
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Возрастная статистика пользователей
SELECT 
    CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age BETWEEN 25 AND 30 THEN '25-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        ELSE '40+'
    END as age_group,
    COUNT(*) as user_count,
    AVG(age) as avg_age
FROM users
GROUP BY 
    CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age BETWEEN 25 AND 30 THEN '25-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        ELSE '40+'
    END
ORDER BY age_group;

-- ===========================================
-- 6. ОБНОВЛЕНИЕ И УДАЛЕНИЕ
-- ===========================================

-- Обновить возраст пользователя
UPDATE users SET age = 26 WHERE id = 1;

-- Удалить заказ
DELETE FROM orders WHERE id = 7;

-- Обновить цену продукта
UPDATE products SET price = 70000.00 WHERE id = 2;

-- ===========================================
-- 7. СИСТЕМНЫЕ ЗАПРОСЫ
-- ===========================================

-- Показать все базы данных
SHOW DATABASES;

-- Показать все таблицы в текущей базе данных
SHOW TABLES;

-- Показать структуру таблицы
DESCRIBE users;

-- Показать статус кластера
SHOW PROC '/frontends';
SHOW PROC '/backends';

-- ===========================================
-- 8. ОПТИМИЗАЦИЯ
-- ===========================================

-- Создание индекса для ускорения поиска
CREATE INDEX idx_users_email ON users(email);

-- Создание индекса для поиска по дате
CREATE INDEX idx_orders_date ON orders(order_date);

-- Проверка использования индексов
EXPLAIN SELECT * FROM users WHERE email = 'ivan@example.com';

-- ===========================================
-- 9. ОЧИСТКА
-- ===========================================

-- Удалить все данные из таблицы
-- TRUNCATE TABLE orders;

-- Удалить таблицу
-- DROP TABLE orders;

-- Удалить базу данных
-- DROP DATABASE demo_db; 