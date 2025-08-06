# StarRocks Single Node Deployment

Этот проект содержит конфигурацию для развертывания StarRocks в однодоступной конфигурации с использованием Docker Compose.

## Архитектура

- **Frontend (FE)**: Управляет метаданными и координацией
- **Backend (BE)**: Хранит и обрабатывает данные
- Оба компонента размещены на одном узле

## Быстрый старт

### 1. Запуск кластера

```bash
# Запуск всех сервисов
docker-compose up -d

# Просмотр логов
docker-compose logs -f

# Проверка статуса сервисов
docker-compose ps
```

### 2. Подключение к StarRocks

После запуска кластера вы можете подключиться к StarRocks:

- **HTTP интерфейс**: http://localhost:9030
- **MySQL клиент**: localhost:9030
- **Пользователь по умолчанию**: root (без пароля)

### 3. Проверка статуса кластера

```bash
# Подключение к MySQL клиенту
mysql -h localhost -P 9030 -u root

# Проверка статуса FE
SHOW PROC '/frontends'\G

# Проверка статуса BE
SHOW PROC '/backends'\G
```

## Полезные команды

### Управление контейнерами

```bash
# Остановка кластера
docker-compose down

# Перезапуск с пересборкой
docker-compose up -d --build

# Очистка данных (ВНИМАНИЕ: удалит все данные!)
docker-compose down -v
```

### Мониторинг

```bash
# Просмотр логов FE
docker-compose logs starrocks-fe

# Просмотр логов BE
docker-compose logs starrocks-be

# Проверка использования ресурсов
docker stats
```

### Подключение к контейнерам

```bash
# Подключение к FE контейнеру
docker exec -it starrocks-fe bash

# Подключение к BE контейнеру
docker exec -it starrocks-be bash
```

## Конфигурация

### Порты

- **9030**: HTTP порт для подключения клиентов
- **9010**: Edit log порт для FE
- **9020**: RPC порт для FE
- **9060**: HTTP порт для BE
- **8040**: BE порт для обработки запросов
- **8060**: BRPC порт для внутренней коммуникации
- **9050**: Heartbeat порт для BE

### Тома данных

- `fe-data`: Метаданные FE
- `fe-log`: Логи FE
- `be-data`: Данные BE
- `be-log`: Логи BE

## Примеры использования

### Создание базы данных

```sql
CREATE DATABASE test_db;
USE test_db;
```

### Создание таблицы

```sql
CREATE TABLE test_table (
    id INT,
    name VARCHAR(50),
    created_at DATETIME
) DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 3
PROPERTIES("replication_num" = "1");
```

### Вставка данных

```sql
INSERT INTO test_table VALUES 
(1, 'test1', NOW()),
(2, 'test2', NOW()),
(3, 'test3', NOW());
```

## Troubleshooting

### Проблемы с запуском

1. **FE не запускается**: Проверьте логи `docker-compose logs starrocks-fe`
2. **BE не подключается к FE**: Убедитесь, что FE полностью запустился перед запуском BE
3. **Проблемы с сетью**: Проверьте настройки сети Docker

### Очистка при проблемах

```bash
# Полная очистка
docker-compose down -v
docker system prune -f
docker-compose up -d
```

## Требования

- Docker 20.10+
- Docker Compose 2.0+
- Минимум 4GB RAM
- 10GB свободного места на диске 