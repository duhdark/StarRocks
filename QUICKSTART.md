# 🚀 Quick Start Guide

## Быстрый старт с StarRocks

### 1. Выберите конфигурацию

**Для разработки и тестирования:**
```bash
cd starrocks-single-node
docker-compose up -d
```

**Для продакшена:**
```bash
cd starrocks-cluster
docker-compose up -d
```

### 2. Проверьте статус

```bash
# Проверка контейнеров
docker-compose ps

# Просмотр логов
docker-compose logs -f
```

### 3. Подключитесь к StarRocks

```bash
# Подключение через MySQL клиент
mysql -h localhost -P 9030 -u root

# Или через HTTP интерфейс
open http://localhost:9030
```

### 4. Запустите тестовые данные

```bash
# Для Single Node
mysql -h localhost -P 9030 -u root < init.sql

# Для Cluster
mysql -h localhost -P 9030 -u root < init-cluster.sql
```

### 5. Проверьте работу

```sql
-- Проверка статуса
SHOW PROC '/frontends'\G
SHOW PROC '/backends'\G

-- Тестовый запрос
SELECT * FROM test_db.users LIMIT 5;
```

## ⚡ Автоматическое тестирование

```bash
# Запуск автоматического тестирования
./test-deployment.sh
```

## 🛠️ Полезные команды

```bash
# Остановка
docker-compose down

# Перезапуск
docker-compose restart

# Очистка данных
docker-compose down -v

# Просмотр ресурсов
docker stats
```

## 📊 Мониторинг

- **HTTP интерфейс**: http://localhost:9030
- **Логи**: `docker-compose logs -f`
- **Метрики**: http://localhost:9060/metrics (BE)

## 🆘 Troubleshooting

### Контейнеры не запускаются
```bash
docker-compose logs
docker system prune -f
```

### Не удается подключиться
```bash
# Проверьте порты
netstat -an | grep 9030

# Проверьте логи
docker-compose logs starrocks-fe-1
```

### Проблемы с памятью
```bash
# Проверьте использование ресурсов
docker stats

# Увеличьте лимиты в docker-compose.yml
```

## 📚 Документация

- [Подробное руководство](README.md)
- [Single Node документация](starrocks-single-node/README.md)
- [Cluster документация](starrocks-cluster/README.md)
- [Примеры мониторинга](monitoring-examples.md)

## 🎯 Готово!

Теперь у вас есть полностью рабочий StarRocks кластер в Docker! 🎉 