# StarRocks Docker Deployment

## 🚀 Быстрый старт

Этот проект содержит готовые конфигурации для развертывания StarRocks в Docker.

### Для разработки и тестирования:
```bash
cd starrocks-single-node
docker-compose up -d
```

### Для продакшена:
```bash
cd starrocks-cluster
docker-compose up -d
```

## 📊 Возможности

- **Single Node**: Идеально для разработки и тестирования
- **Cluster**: Готов для продакшена с высокой доступностью
- **Автоматическое тестирование**: Встроенные health checks
- **Мониторинг**: Примеры Prometheus + Grafana
- **Документация**: Полные руководства по развертыванию

## 🔧 Требования

- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM (Single Node) / 8GB RAM (Cluster)

## 📖 Документация

Полная документация доступна в репозитории:
- [Подробное руководство](https://github.com/duhdark/StarRocks/blob/main/README.md)
- [Краткое руководство](https://github.com/duhdark/StarRocks/blob/main/QUICKSTART.md)
- [Примеры мониторинга](https://github.com/duhdark/StarRocks/blob/main/monitoring-examples.md)

## 🤝 Вклад в проект

1. Fork репозитория
2. Создайте feature branch
3. Внесите изменения
4. Создайте Pull Request

## 📄 Лицензия

MIT License - см. [LICENSE](https://github.com/duhdark/StarRocks/blob/main/LICENSE) для подробностей. 