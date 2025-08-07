# 🚀 StarRocks Docker Deployment

Полная инфраструктура для развертывания StarRocks в Docker с готовыми проектами для разработки и продакшена.

## 📋 Содержание

- [🚀 Быстрый старт](#-быстрый-старт)
- [📁 Структура проектов](#-структура-проектов)
- [📊 Сравнение конфигураций](#-сравнение-конфигураций)
- [🔧 Требования](#-требования)
- [🛠️ Управление](#️-управление)
- [🔍 Мониторинг](#-мониторинг)
- [📖 Документация](#-документация)
- [🐛 Troubleshooting](#-troubleshooting)
- [🔒 Безопасность](#-безопасность)
- [📈 Производительность](#-производительность)
- [📚 Полезные ссылки](#-полезные-ссылки)

## 🚀 Быстрый старт

### 1. Выберите конфигурацию

**Для разработки и тестирования:**
```powershell
cd starrocks-single-node
.\manage.ps1 start
```

**Для продакшена:**
```powershell
cd starrocks-cluster
.\manage.ps1 start
```

### 2. Проверьте статус

```powershell
# Проверка контейнеров
.\manage.ps1 status

# Просмотр логов
.\manage.ps1 logs
```

### 3. Подключитесь к StarRocks

```powershell
# Подключение через PowerShell скрипт
.\connect.ps1

# Или напрямую через MySQL
mysql -h localhost -P 9030 -u root
```

### 4. Запустите тестовые данные

```sql
-- Для Single Node
SOURCE init.sql;

-- Для Cluster
SOURCE init-cluster.sql;
```

### 5. Проверьте работу

```sql
-- Проверка статуса
SHOW PROC '/frontends'\G
SHOW PROC '/backends'\G

-- Тестовый запрос
SELECT * FROM test_db.users LIMIT 5;
```

## 📁 Структура проектов

```
StarRocks/
├── README.md                    # Основная документация
├── CHANGELOG.md                 # История изменений
├── LICENSE                      # MIT лицензия
├── .gitignore                   # Git ignore файл
├── monitoring-examples.md       # Примеры мониторинга
├── starrocks-single-node/       # Однодоступная конфигурация
│   ├── docker-compose.yml       # Docker Compose
│   ├── README.md                # Документация
│   ├── manage.ps1               # PowerShell скрипт управления
│   ├── connect.ps1              # Скрипт подключения
│   ├── examples.sql             # Примеры SQL запросов
│   ├── init.sql                 # SQL инициализация
│   └── CHANGELOG.md             # История изменений
└── starrocks-cluster/           # Кластерная конфигурация
    ├── docker-compose.yml       # Docker Compose кластера
    ├── README.md                # Документация кластера
    ├── manage.ps1               # PowerShell скрипт управления
    ├── connect.ps1              # Скрипт подключения
    ├── examples.sql             # Примеры SQL запросов
    ├── init-cluster.sql         # SQL инициализация кластера
    └── CHANGELOG.md             # История изменений
```

## 📊 Сравнение конфигураций

| Характеристика | Single Node | Cluster |
|----------------|-------------|---------|
| **Сложность развертывания** | Низкая | Средняя |
| **Ресурсы** | 4GB RAM, 10GB диска | 8GB RAM, 20GB диска |
| **Отказоустойчивость** | Нет | Высокая |
| **Масштабируемость** | Ограниченная | Высокая |
| **Производительность** | Средняя | Высокая |
| **Подходит для** | Dev/Test | Production |

## 🔧 Требования

### Минимальные требования
- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM (Single Node) / 8GB RAM (Cluster)
- 10GB диска (Single Node) / 20GB диска (Cluster)

### Рекомендуемые требования
- Docker 24.0+
- Docker Compose 2.20+
- 8GB RAM (Single Node) / 16GB RAM (Cluster)
- SSD диски
- Минимум 4 CPU ядра

## 🛠️ Управление

### PowerShell скрипты

```powershell
# Запуск
.\manage.ps1 start

# Остановка
.\manage.ps1 stop

# Перезапуск
.\manage.ps1 restart

# Статус
.\manage.ps1 status

# Логи
.\manage.ps1 logs

# Подключение
.\manage.ps1 connect

# Очистка данных
.\manage.ps1 clean

# Справка
.\manage.ps1 help
```

### Docker команды

```bash
# Запуск
docker-compose up -d

# Остановка
docker-compose down

# Просмотр логов
docker-compose logs -f

# Перезапуск
docker-compose restart

# Очистка данных
docker-compose down -v
```

## 🔍 Мониторинг

### Подключение к StarRocks

```powershell
# Single Node
.\connect.ps1

# Cluster (выбор узла)
.\connect.ps1
```

### Проверка статуса

```sql
-- Проверка FE узлов
SHOW PROC '/frontends'\G

-- Проверка BE узлов
SHOW PROC '/backends'\G

-- Проверка репликации (только для кластера)
SHOW PROC '/tablets'\G
```

### Полезные команды

```powershell
# Остановка
.\manage.ps1 stop

# Перезапуск
.\manage.ps1 restart

# Очистка данных
.\manage.ps1 clean

# Справка
.\manage.ps1 help
```

### Мониторинг

- **HTTP интерфейс**: http://localhost:9030
- **Логи**: `.\manage.ps1 logs`
- **Метрики**: http://localhost:9060/metrics (BE)

## 📖 Документация

### Single Node
- [Руководство по развертыванию](starrocks-single-node/README.md)
- [Примеры SQL запросов](starrocks-single-node/examples.sql)
- [История изменений](starrocks-single-node/CHANGELOG.md)

### Cluster
- [Руководство по развертыванию](starrocks-cluster/README.md)
- [Примеры SQL запросов](starrocks-cluster/examples.sql)
- [История изменений](starrocks-cluster/CHANGELOG.md)

## 🐛 Troubleshooting

### Контейнеры не запускаются
```powershell
.\manage.ps1 logs
docker system prune -f
```

### Не удается подключиться
```powershell
# Проверьте порты
netstat -an | findstr 9030

# Проверьте логи
.\manage.ps1 logs
```

### Проблемы с памятью
```powershell
# Проверьте использование ресурсов
docker stats

# Увеличьте лимиты в docker-compose.yml
```

### Частые проблемы

1. **Контейнеры не запускаются**
   ```bash
   docker-compose logs
   docker system prune -f
   ```

2. **BE узлы не подключаются к FE**
   ```bash
   docker-compose logs starrocks-fe-1
   docker-compose logs starrocks-be-1
   ```

3. **Проблемы с памятью**
   ```bash
   docker stats
   # Увеличьте лимиты памяти в docker-compose.yml
   ```

### Диагностика

```bash
# Проверка ресурсов
docker stats

# Проверка сетевых соединений
docker network ls
docker network inspect starrocks-network

# Проверка логов
docker-compose logs -f [service-name]
```

## 🔒 Безопасность

### Рекомендации для продакшена

1. **Изменение паролей по умолчанию**
2. **Настройка SSL/TLS**
3. **Ограничение доступа к портам**
4. **Регулярное резервное копирование**
5. **Мониторинг и алерты**

### Пример настройки безопасности

```sql
-- Создание пользователя с паролем
CREATE USER 'admin'@'%' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';
FLUSH PRIVILEGES;
```

## 📈 Производительность

### Оптимизация для Single Node

```sql
-- Настройка количества потоков
SET GLOBAL parallel_fragment_exec_instance_num = 4;

-- Настройка размера буфера
SET GLOBAL query_mem_limit = '2G';
```

### Оптимизация для Cluster

```sql
-- Настройка репликации
ALTER TABLE my_table SET ('replication_num' = '3');

-- Настройка распределения
ALTER TABLE my_table SET ('bucket_num' = '6');
```

## 📚 Полезные ссылки

- [Официальная документация StarRocks](https://docs.starrocks.io/)
- [Docker Hub StarRocks](https://hub.docker.com/r/starrocks)
- [GitHub StarRocks](https://github.com/StarRocks/starrocks)

## 🤝 Вклад в проект

1. Fork репозитория
2. Создайте feature branch
3. Внесите изменения
4. Создайте Pull Request

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл LICENSE для подробностей.

---

## 🎯 Что было создано

### ✅ Готовые проекты

1. **starrocks-single-node/**
   - Полностью настроенный Docker Compose для однодоступной конфигурации
   - 1 FE + 1 BE узел
   - PowerShell скрипты управления и подключения
   - Готовые примеры SQL запросов
   - Подробная документация

2. **starrocks-cluster/**
   - Полностью настроенный Docker Compose для кластерной конфигурации
   - 3 FE + 3 BE узла с репликацией
   - PowerShell скрипты управления и подключения
   - Высокая доступность и отказоустойчивость
   - Примеры аналитических запросов

### ✅ Дополнительные файлы

3. **monitoring-examples.md**
   - Примеры настройки Prometheus + Grafana
   - Конфигурации алертов
   - Скрипты мониторинга здоровья
   - Интеграция с Slack/Email
   - ELK Stack для логов

### ✅ Готовые SQL скрипты

4. **examples.sql** (Single Node)
   - Создание тестовых таблиц (users, orders, products)
   - Вставка тестовых данных
   - Примеры аналитических запросов
   - Представления для аналитики

5. **examples.sql** (Cluster)
   - Расширенные таблицы с репликацией
   - Больше тестовых данных
   - Сложные аналитические запросы
   - Мониторинг кластера

### 🚀 Готово к использованию

Все проекты полностью готовы к развертыванию:

```powershell
# Для разработки
cd starrocks-single-node && .\manage.ps1 start

# Для продакшена  
cd starrocks-cluster && .\manage.ps1 start
```

### 📊 Возможности

- **Single Node**: Идеально для разработки, тестирования и небольших проектов
- **Cluster**: Готов для продакшена с высокой доступностью
- **PowerShell скрипты**: Удобное управление через PowerShell
- **Мониторинг**: Полная экосистема для наблюдения за кластером
- **Безопасность**: Рекомендации и примеры настройки
- **Производительность**: Оптимизация для различных сценариев