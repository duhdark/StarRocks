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

## 🚀 Быстрый старт

### Запуск кластера
```powershell
.\manage.ps1 start
```

### Остановка кластера
```powershell
.\manage.ps1 stop
```

### Просмотр статуса
```powershell
.\manage.ps1 status
```

### Просмотр логов
```powershell
.\manage.ps1 logs
```

## 🔗 Подключение к кластеру

### Через PowerShell скрипт (рекомендуется)
```powershell
.\connect.ps1
```

### Управление через PowerShell скрипт
```powershell
.\manage.ps1 start      # Запустить кластер
.\manage.ps1 stop       # Остановить кластер
.\manage.ps1 restart    # Перезапустить кластер
.\manage.ps1 status     # Показать статус
.\manage.ps1 logs       # Показать логи
.\manage.ps1 connect    # Подключиться к кластеру
.\manage.ps1 clean      # Очистить все данные
.\manage.ps1 help       # Показать справку
```

### Через MySQL клиент напрямую
```powershell
# Подключение к FE-1 (основной узел)
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -h localhost -P 9030 -u root

# Подключение к FE-2 (реплика)
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -h localhost -P 9031 -u root

# Подключение к FE-3 (реплика)
& "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -h localhost -P 9032 -u root
```

## 📊 Проверка статуса кластера

### Проверка FE узлов
```sql
SHOW PROC '/frontends';
```

### Проверка BE узлов
```sql
SHOW PROC '/backends';
```

### Проверка репликации
```sql
SHOW PROC '/tablets';
```

## 📁 Структура проекта

```
starrocks-cluster/
├── docker-compose.yml    # Конфигурация кластера
├── connect.ps1          # Скрипт подключения
├── manage.ps1           # Скрипт управления
├── examples.sql         # Примеры SQL запросов
├── init-cluster.sql     # Инициализация кластера
└── README.md            # Документация
```

## 🔧 Конфигурация кластера

### Порты
- **9030** - FE-1 (основной узел)
- **9031** - FE-2 (реплика)
- **9032** - FE-3 (реплика)
- **9060-9062** - BE узлы
- **9010-9012** - Edit log порты
- **9020-9022** - RPC порты

### Объемы данных
- `fe-1-data`, `fe-2-data`, `fe-3-data` - метаданные FE
- `fe-1-log`, `fe-2-log`, `fe-3-log` - логи FE
- `be-1-data`, `be-2-data`, `be-3-data` - данные BE
- `be-1-log`, `be-2-log`, `be-3-log` - логи BE

## 🛠️ Управление кластером

### Мониторинг узлов

```powershell
# Проверка статуса всех контейнеров
.\manage.ps1 status

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