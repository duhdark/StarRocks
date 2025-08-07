# StarRocks Single Node Deployment

Однодоступная конфигурация StarRocks для разработки и тестирования.

## 🚀 Быстрый старт

### Запуск
```powershell
docker-compose up -d
```

### Остановка
```powershell
docker-compose down
```

### Просмотр логов
```powershell
docker-compose logs -f
```

## 🔗 Подключение к StarRocks

### Через PowerShell скрипт (рекомендуется)
```powershell
.\connect.ps1
```

### Управление через PowerShell скрипт
```powershell
.\manage.ps1 start      # Запустить StarRocks
.\manage.ps1 stop       # Остановить StarRocks
.\manage.ps1 restart    # Перезапустить StarRocks
.\manage.ps1 status     # Показать статус
.\manage.ps1 logs       # Показать логи
.\manage.ps1 connect    # Подключиться к StarRocks
.\manage.ps1 clean      # Очистить все данные
.\manage.ps1 help       # Показать справку
```

### Через MySQL клиент напрямую
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -h localhost -P 9030 -u root
```

### Через Docker контейнер
```powershell
docker exec -it starrocks-fe mysql -h127.0.0.1 -P9030 -uroot
```

## 📊 Проверка статуса

### Проверка FE узлов
```sql
SHOW PROC '/frontends';
```

### Проверка BE узлов
```sql
SHOW PROC '/backends';
```

### Проверка таблиц
```sql
SHOW TABLES;
```

### Проверка баз данных
```sql
SHOW DATABASES;
```

## 🛠️ Управление

### Перезапуск контейнеров
```powershell
docker-compose restart
```

### Очистка данных
```powershell
docker-compose down -v
```

### Просмотр ресурсов
```powershell
docker stats
```

### Просмотр логов конкретного контейнера
```powershell
docker-compose logs starrocks-fe
docker-compose logs starrocks-be
```

### Подключение к контейнерам
```powershell
docker exec -it starrocks-fe bash
docker exec -it starrocks-be bash
```

## 📁 Структура проекта

```
starrocks-single-node/
├── docker-compose.yml    # Конфигурация Docker Compose
├── connect.ps1          # Скрипт подключения
├── manage.ps1           # Скрипт управления
├── examples.sql         # Примеры SQL запросов
├── README.md            # Документация
└── init.sql             # Скрипт инициализации БД
```

## 🔧 Конфигурация

### Порты
- **9030** - MySQL протокол (основной)
- **8030** - HTTP веб-интерфейс
- **9010** - Edit log порт
- **9020** - RPC порт
- **8040** - BE HTTP порт
- **8060** - BE BRPC порт
- **9050** - BE Heartbeat порт
- **9060** - BE порт

### Объемы данных
- `fe-data` - метаданные FE
- `fe-log` - логи FE
- `be-data` - данные BE
- `be-log` - логи BE

## 🐛 Troubleshooting

### Проблема: BE не регистрируется
```sql
-- Вручную зарегистрировать BE
ALTER SYSTEM ADD BACKEND '172.18.0.3:9050';
```

### Проблема: Контейнеры не запускаются
```powershell
# Очистить все контейнеры и сети
docker-compose down
docker system prune -f
docker-compose up -d
```

### Проблема: Нет доступа к MySQL
```powershell
# Проверить статус контейнеров
docker-compose ps

# Проверить логи
docker-compose logs starrocks-fe
```

### Проблема: Недостаточно памяти
```powershell
# Проверить использование ресурсов
docker stats

# Увеличить лимиты в docker-compose.yml
```

## 📚 Полезные команды

### Создание базы данных
```sql
CREATE DATABASE test_db;
USE test_db;
```

### Создание таблицы
```sql
CREATE TABLE users (
    id INT,
    name VARCHAR(100),
    email VARCHAR(100)
) DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 3;
```

### Вставка данных
```sql
INSERT INTO users VALUES (1, 'John Doe', 'john@example.com');
```

### Запрос данных
```sql
SELECT * FROM users;
```

### Удаление данных
```sql
DELETE FROM users WHERE id = 1;
```

### Обновление данных
```sql
UPDATE users SET name = 'Jane Doe' WHERE id = 1;
```

## 🔍 Мониторинг и диагностика

### Проверка производительности
```sql
SHOW PROC '/statistic';
```

### Проверка репликации
```sql
SHOW PROC '/tablets';
```

### Проверка нагрузки
```sql
SHOW PROC '/queries';
```

### Проверка ошибок
```sql
SHOW PROC '/errors';
```

## 🛡️ Безопасность

### Создание пользователя
```sql
CREATE USER 'admin'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';
FLUSH PRIVILEGES;
```

### Изменение пароля root
```sql
ALTER USER 'root'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

## 📈 Оптимизация

### Настройка памяти
```sql
SET GLOBAL query_mem_limit = '2G';
```

### Настройка параллелизма
```sql
SET GLOBAL parallel_fragment_exec_instance_num = 4;
```

### Настройка кэша
```sql
SET GLOBAL cache_enable_sql_mode = true;
```

## 🎯 Готово к использованию!

StarRocks полностью настроен и готов к работе. Используйте `.\connect.ps1` для быстрого подключения.

### Быстрые команды для начала работы:

1. **Запуск**: `.\manage.ps1 start`
2. **Подключение**: `.\connect.ps1`
3. **Проверка статуса**: `.\manage.ps1 status`
4. **Примеры SQL**: Запустите `.\connect.ps1` и выполните `source examples.sql;`
5. **Остановка**: `.\manage.ps1 stop`

### Примеры использования:

```powershell
# Запуск и подключение
.\manage.ps1 start
.\connect.ps1

# В MySQL клиенте выполните:
source examples.sql;
``` 