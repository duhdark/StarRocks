# StarRocks Cluster Deployment

Этот проект содержит конфигурацию для развертывания StarRocks в кластерной конфигурации с использованием Docker Compose.

## Архитектура кластера

### Frontend (FE) узлы
- **starrocks-fe-1**: Главный FE узел (Master)
- **starrocks-fe-2**: Вторичный FE узел (Follower)
- **starrocks-fe-3**: Третичный FE узел (Follower)

### Backend (BE) узлы
- **starrocks-be-1**: BE узел 1
- **starrocks-be-2**: BE узел 2
- **starrocks-be-3**: BE узел 3

## Преимущества кластерной конфигурации

1. **Высокая доступность**: Отказоустойчивость при выходе из строя узлов
2. **Масштабируемость**: Распределение нагрузки между узлами
3. **Производительность**: Параллельная обработка запросов
4. **Резервирование**: Репликация данных между узлами

## Быстрый старт

### 1. Запуск кластера

```bash
# Запуск всех сервисов
docker-compose up -d

# Просмотр логов всех сервисов
docker-compose logs -f

# Просмотр логов конкретного сервиса
docker-compose logs -f starrocks-fe-1
docker-compose logs -f starrocks-be-1

# Проверка статуса сервисов
docker-compose ps
```

### 2. Подключение к кластеру

После запуска кластера вы можете подключиться к любому FE узлу:

- **FE-1**: http://localhost:9030
- **FE-2**: http://localhost:9031
- **FE-3**: http://localhost:9032

### 3. Проверка статуса кластера

```bash
# Подключение к главному FE узлу
mysql -h localhost -P 9030 -u root

# Проверка статуса FE узлов
SHOW PROC '/frontends'\G

# Проверка статуса BE узлов
SHOW PROC '/backends'\G

# Проверка репликации
SHOW PROC '/tablets'\G
```

## Управление кластером

### Мониторинг узлов

```bash
# Проверка статуса всех контейнеров
docker-compose ps

# Просмотр использования ресурсов
docker stats

# Проверка сетевых соединений
docker network ls
docker network inspect starrocks-cluster_starrocks-network
```

### Масштабирование

```bash
# Добавление нового BE узла
docker-compose up -d starrocks-be-4

# Удаление BE узла
docker-compose stop starrocks-be-3
docker-compose rm starrocks-be-3
```

### Резервное копирование

```bash
# Создание резервной копии метаданных FE
docker exec starrocks-fe-1 /opt/starrocks/fe/bin/meta_tool --operation=backup --meta_dir=/opt/starrocks/fe/meta --backup_dir=/tmp/backup

# Создание резервной копии данных BE
docker exec starrocks-be-1 /opt/starrocks/be/bin/br_tool --operation=backup --storage_dir=/opt/starrocks/be/storage --backup_dir=/tmp/backup
```

## Конфигурация

### Порты

#### Frontend узлы
- **FE-1**: 9030 (HTTP), 9010 (Edit log), 9020 (RPC)
- **FE-2**: 9031 (HTTP), 9011 (Edit log), 9021 (RPC)
- **FE-3**: 9032 (HTTP), 9012 (Edit log), 9022 (RPC)

#### Backend узлы
- **BE-1**: 9060 (HTTP), 8040 (BE), 8060 (BRPC), 9050 (Heartbeat)
- **BE-2**: 9061 (HTTP), 8041 (BE), 8061 (BRPC), 9051 (Heartbeat)
- **BE-3**: 9062 (HTTP), 8042 (BE), 8062 (BRPC), 9052 (Heartbeat)

### Тома данных

Каждый узел имеет свои тома для данных и логов:
- `fe-1-data`, `fe-2-data`, `fe-3-data`: Метаданные FE узлов
- `fe-1-log`, `fe-2-log`, `fe-3-log`: Логи FE узлов
- `be-1-data`, `be-2-data`, `be-3-data`: Данные BE узлов
- `be-1-log`, `be-2-log`, `be-3-log`: Логи BE узлов

## Примеры использования

### Создание таблицы с репликацией

```sql
CREATE DATABASE cluster_test;
USE cluster_test;

CREATE TABLE distributed_table (
    id INT,
    name VARCHAR(50),
    value DECIMAL(10,2),
    created_at DATETIME
) DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 6
PROPERTIES("replication_num" = "3");
```

### Проверка распределения данных

```sql
-- Проверка распределения таблиц по узлам
SHOW PROC '/tablets'\G

-- Проверка статуса репликации
SHOW PROC '/tablets'\G

-- Проверка нагрузки на узлы
SHOW PROC '/backends'\G
```

### Аналитические запросы

```sql
-- Создание тестовых данных
INSERT INTO distributed_table VALUES 
(1, 'item1', 100.50, NOW()),
(2, 'item2', 200.75, NOW()),
(3, 'item3', 150.25, NOW());

-- Аналитический запрос с агрегацией
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total_items,
    SUM(value) as total_value,
    AVG(value) as avg_value
FROM distributed_table
GROUP BY DATE(created_at)
ORDER BY date;
```

## Troubleshooting

### Проблемы с запуском

1. **FE узлы не подключаются**: Проверьте логи `docker-compose logs starrocks-fe-2`
2. **BE узлы не регистрируются**: Убедитесь, что все FE узлы запущены
3. **Проблемы с сетью**: Проверьте настройки Docker network

### Диагностика

```bash
# Проверка логов конкретного узла
docker-compose logs starrocks-fe-1

# Подключение к контейнеру для диагностики
docker exec -it starrocks-fe-1 bash

# Проверка конфигурации
docker exec starrocks-fe-1 cat /opt/starrocks/fe/conf/fe.conf
```

### Восстановление после сбоя

```bash
# Перезапуск конкретного узла
docker-compose restart starrocks-fe-2

# Полная перезагрузка кластера
docker-compose down
docker-compose up -d

# Очистка и перезапуск
docker-compose down -v
docker system prune -f
docker-compose up -d
```

## Требования

- Docker 20.10+
- Docker Compose 2.0+
- Минимум 8GB RAM
- 20GB свободного места на диске
- Минимум 4 CPU ядра

## Мониторинг и алерты

### Рекомендуемые метрики для мониторинга

1. **Статус узлов**: Все FE и BE узлы должны быть в статусе "Alive"
2. **Использование ресурсов**: CPU, Memory, Disk I/O
3. **Производительность**: Query latency, Throughput
4. **Репликация**: Status of tablet replicas

### Интеграция с системами мониторинга

StarRocks предоставляет метрики в формате Prometheus на портах:
- FE: `/metrics` endpoint на HTTP порту
- BE: `/metrics` endpoint на HTTP порту 