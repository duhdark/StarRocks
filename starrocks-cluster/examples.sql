-- StarRocks Cluster SQL Examples
-- Примеры SQL запросов для работы с StarRocks кластером

-- ===========================================
-- 1. ПРОВЕРКА КЛАСТЕРА
-- ===========================================

-- Проверка всех FE узлов
SHOW PROC '/frontends';

-- Проверка всех BE узлов
SHOW PROC '/backends';

-- Проверка статуса кластера
SHOW PROC '/statistic';

-- ===========================================
-- 2. СОЗДАНИЕ БАЗЫ ДАННЫХ И ТАБЛИЦ
-- ===========================================

-- Создание базы данных
CREATE DATABASE IF NOT EXISTS cluster_demo;
USE cluster_demo;

-- Создание таблицы пользователей с репликацией
CREATE TABLE users (
    id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    age INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 6
PROPERTIES("replication_num" = "3");

-- Создание таблицы заказов
CREATE TABLE orders (
    id INT,
    user_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    quantity INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP
) DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 6
PROPERTIES("replication_num" = "3");

-- Создание таблицы продуктов
CREATE TABLE products (
    id INT,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock INT
) DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 6
PROPERTIES("replication_num" = "3");

-- ===========================================
-- 3. ВСТАВКА ДАННЫХ
-- ===========================================

-- Вставка пользователей
INSERT INTO users VALUES 
(1, 'Иван Иванов', 'ivan@example.com', 25, '2024-01-01 10:00:00'),
(2, 'Мария Петрова', 'maria@example.com', 30, '2024-01-02 11:00:00'),
(3, 'Алексей Сидоров', 'alex@example.com', 28, '2024-01-03 12:00:00'),
(4, 'Елена Козлова', 'elena@example.com', 35, '2024-01-04 13:00:00'),
(5, 'Дмитрий Волков', 'dmitry@example.com', 27, '2024-01-05 14:00:00'),
(6, 'Анна Смирнова', 'anna@example.com', 32, '2024-01-06 15:00:00'),
(7, 'Сергей Козлов', 'sergey@example.com', 29, '2024-01-07 16:00:00'),
(8, 'Ольга Морозова', 'olga@example.com', 26, '2024-01-08 17:00:00');

-- Вставка продуктов
INSERT INTO products VALUES 
(1, 'Ноутбук Dell', 'Электроника', 45000.00, 10),
(2, 'Смартфон iPhone', 'Электроника', 65000.00, 15),
(3, 'Книга "SQL для начинающих"', 'Книги', 1200.00, 50),
(4, 'Кофемашина', 'Бытовая техника', 25000.00, 5),
(5, 'Наушники Sony', 'Электроника', 8000.00, 20),
(6, 'Планшет iPad', 'Электроника', 35000.00, 8),
(7, 'Принтер HP', 'Офисная техника', 15000.00, 12),
(8, 'Монитор LG', 'Электроника', 18000.00, 15);

-- Вставка заказов
INSERT INTO orders VALUES 
(1, 1, 'Ноутбук Dell', 45000.00, 1, '2024-01-10 09:00:00'),
(2, 2, 'Смартфон iPhone', 65000.00, 1, '2024-01-11 10:00:00'),
(3, 1, 'Книга "SQL для начинающих"', 1200.00, 2, '2024-01-12 11:00:00'),
(4, 3, 'Кофемашина', 25000.00, 1, '2024-01-13 12:00:00'),
(5, 4, 'Наушники Sony', 8000.00, 1, '2024-01-14 13:00:00'),
(6, 2, 'Наушники Sony', 8000.00, 1, '2024-01-15 14:00:00'),
(7, 5, 'Смартфон iPhone', 65000.00, 1, '2024-01-16 15:00:00'),
(8, 6, 'Планшет iPad', 35000.00, 1, '2024-01-17 16:00:00'),
(9, 7, 'Принтер HP', 15000.00, 1, '2024-01-18 17:00:00'),
(10, 8, 'Монитор LG', 18000.00, 1, '2024-01-19 18:00:00');

-- ===========================================
-- 4. ПРОВЕРКА КЛАСТЕРНОЙ РЕПЛИКАЦИИ
-- ===========================================

-- Проверка репликации таблиц
SHOW PROC '/tablets';

-- Проверка распределения данных
SHOW PROC '/tablets' WHERE TableName = 'users';

-- Проверка статуса репликации
SHOW PROC '/tablets' WHERE TableName = 'orders';

-- ===========================================
-- 5. КЛАСТЕРНЫЕ ЗАПРОСЫ
-- ===========================================

-- Анализ продаж по категориям
SELECT 
    p.category,
    COUNT(o.id) as orders_count,
    SUM(o.price * o.quantity) as total_revenue,
    AVG(o.price * o.quantity) as avg_order_value
FROM orders o
JOIN products p ON o.product_name = p.name
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Топ пользователей по покупкам
SELECT 
    u.name,
    COUNT(o.id) as order_count,
    SUM(o.price * o.quantity) as total_spent,
    AVG(o.price * o.quantity) as avg_order_value
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC
LIMIT 5;

-- Статистика по возрастным группам
SELECT 
    CASE 
        WHEN u.age < 25 THEN '18-24'
        WHEN u.age BETWEEN 25 AND 30 THEN '25-30'
        WHEN u.age BETWEEN 31 AND 40 THEN '31-40'
        ELSE '40+'
    END as age_group,
    COUNT(DISTINCT u.id) as user_count,
    COUNT(o.id) as order_count,
    SUM(o.price * o.quantity) as total_revenue
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY 
    CASE 
        WHEN u.age < 25 THEN '18-24'
        WHEN u.age BETWEEN 25 AND 30 THEN '25-30'
        WHEN u.age BETWEEN 31 AND 40 THEN '31-40'
        ELSE '40+'
    END
ORDER BY age_group;

-- ===========================================
-- 6. ПРОИЗВОДИТЕЛЬНОСТЬ КЛАСТЕРА
-- ===========================================

-- Проверка нагрузки на узлы
SHOW PROC '/queries';

-- Проверка статистики запросов
SHOW PROC '/statistic';

-- Проверка использования ресурсов
SHOW PROC '/backends';

-- ===========================================
-- 7. КЛАСТЕРНОЕ УПРАВЛЕНИЕ
-- ===========================================

-- Проверка всех узлов кластера
SHOW PROC '/frontends';
SHOW PROC '/backends';

-- Проверка метаданных
SHOW PROC '/meta';

-- Проверка журналов
SHOW PROC '/logs';

-- ===========================================
-- 8. ОПТИМИЗАЦИЯ КЛАСТЕРА
-- ===========================================

-- Создание индексов для ускорения
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_products_category ON products(category);

-- Проверка использования индексов
EXPLAIN SELECT * FROM users WHERE email = 'ivan@example.com';

-- Настройка параллелизма для кластера
SET GLOBAL parallel_fragment_exec_instance_num = 8;

-- Настройка памяти для кластера
SET GLOBAL query_mem_limit = '4G';

-- ===========================================
-- 9. МОНИТОРИНГ КЛАСТЕРА
-- ===========================================

-- Проверка ошибок кластера
SHOW PROC '/errors';

-- Проверка медленных запросов
SHOW PROC '/slow_queries';

-- Проверка статистики сети
SHOW PROC '/network';

-- ===========================================
-- 10. ТЕСТИРОВАНИЕ ОТКАЗОУСТОЙЧИВОСТИ
-- ===========================================

-- Проверка доступности данных при отказе узла
-- (выполняется вручную через остановку контейнера)

-- Проверка репликации данных
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_orders FROM orders;
SELECT COUNT(*) as total_products FROM products;

-- Проверка целостности данных
SELECT 
    'users' as table_name,
    COUNT(*) as record_count
FROM users
UNION ALL
SELECT 
    'orders' as table_name,
    COUNT(*) as record_count
FROM orders
UNION ALL
SELECT 
    'products' as table_name,
    COUNT(*) as record_count
FROM products;

-- ===========================================
-- 11. ОЧИСТКА
-- ===========================================

-- Удаление индексов (если нужно)
-- DROP INDEX idx_users_email ON users;
-- DROP INDEX idx_orders_date ON orders;
-- DROP INDEX idx_products_category ON products;

-- Удаление таблиц (если нужно)
-- DROP TABLE orders;
-- DROP TABLE users;
-- DROP TABLE products;

-- Удаление базы данных (если нужно)
-- DROP DATABASE cluster_demo; 