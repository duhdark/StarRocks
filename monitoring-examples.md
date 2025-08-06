# StarRocks Monitoring Examples

Этот файл содержит примеры настройки мониторинга для StarRocks в различных конфигурациях.

## Prometheus + Grafana

### 1. Docker Compose с мониторингом

```yaml
version: '3.8'

services:
  # StarRocks services (existing)
  starrocks-fe:
    # ... existing configuration
    ports:
      - "9030:9030"
      - "9010:9010"
      - "9020:9020"

  starrocks-be:
    # ... existing configuration
    ports:
      - "9060:9060"
      - "8040:8040"
      - "8060:8060"
      - "9050:9050"

  # Prometheus
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'

  # Grafana
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

volumes:
  prometheus-data:
  grafana-data:
```

### 2. Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'starrocks-fe'
    static_configs:
      - targets: ['starrocks-fe:9030']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'starrocks-be'
    static_configs:
      - targets: ['starrocks-be:9060']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

### 3. Grafana Dashboard

```json
{
  "dashboard": {
    "id": null,
    "title": "StarRocks Dashboard",
    "tags": ["starrocks"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Query Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(starrocks_fe_query_total[5m])",
            "legendFormat": "Queries/sec"
          }
        ]
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "starrocks_fe_memory_used_bytes",
            "legendFormat": "Memory Used"
          }
        ]
      },
      {
        "id": 3,
        "title": "BE Node Status",
        "type": "stat",
        "targets": [
          {
            "expr": "starrocks_be_alive",
            "legendFormat": "BE Alive"
          }
        ]
      }
    ]
  }
}
```

## Alerting Rules

### 1. Prometheus Alert Rules

```yaml
# starrocks-alerts.yml
groups:
  - name: starrocks
    rules:
      - alert: StarRocksFEDown
        expr: up{job="starrocks-fe"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "StarRocks FE is down"
          description: "StarRocks Frontend has been down for more than 1 minute"

      - alert: StarRocksBEDown
        expr: up{job="starrocks-be"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "StarRocks BE is down"
          description: "StarRocks Backend has been down for more than 1 minute"

      - alert: HighMemoryUsage
        expr: starrocks_fe_memory_used_bytes / starrocks_fe_memory_total_bytes > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on StarRocks FE"
          description: "Memory usage is above 80% for more than 5 minutes"

      - alert: HighQueryLatency
        expr: histogram_quantile(0.95, rate(starrocks_fe_query_duration_seconds_bucket[5m])) > 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High query latency"
          description: "95th percentile query latency is above 10 seconds"
```

### 2. Alertmanager Configuration

```yaml
# alertmanager.yml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://127.0.0.1:5001/'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
```

## Custom Monitoring Scripts

### 1. Health Check Script

```bash
#!/bin/bash

# starrocks-health-check.sh

STARROCKS_HOST="localhost"
STARROCKS_PORT="9030"
STARROCKS_USER="root"

# Проверка подключения
check_connection() {
    if mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "SELECT 1;" > /dev/null 2>&1; then
        echo "OK: Connection successful"
        return 0
    else
        echo "ERROR: Cannot connect to StarRocks"
        return 1
    fi
}

# Проверка статуса FE
check_fe_status() {
    local result=$(mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "SHOW PROC '/frontends';" 2>/dev/null | grep -c "Alive")
    if [ "$result" -gt 0 ]; then
        echo "OK: FE nodes are alive"
        return 0
    else
        echo "ERROR: No alive FE nodes"
        return 1
    fi
}

# Проверка статуса BE
check_be_status() {
    local result=$(mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "SHOW PROC '/backends';" 2>/dev/null | grep -c "Alive")
    if [ "$result" -gt 0 ]; then
        echo "OK: BE nodes are alive"
        return 0
    else
        echo "ERROR: No alive BE nodes"
        return 1
    fi
}

# Проверка репликации (для кластера)
check_replication() {
    local result=$(mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "SHOW PROC '/tablets';" 2>/dev/null | grep -c "OK")
    if [ "$result" -gt 0 ]; then
        echo "OK: Tablets are healthy"
        return 0
    else
        echo "WARNING: Some tablets may be unhealthy"
        return 1
    fi
}

# Основная функция
main() {
    echo "=== StarRocks Health Check ==="
    
    local exit_code=0
    
    check_connection || exit_code=1
    check_fe_status || exit_code=1
    check_be_status || exit_code=1
    check_replication || exit_code=1
    
    if [ $exit_code -eq 0 ]; then
        echo "=== All checks passed ==="
    else
        echo "=== Some checks failed ==="
    fi
    
    exit $exit_code
}

main "$@"
```

### 2. Performance Monitoring Script

```bash
#!/bin/bash

# starrocks-performance.sh

STARROCKS_HOST="localhost"
STARROCKS_PORT="9030"
STARROCKS_USER="root"

# Получение метрик производительности
get_performance_metrics() {
    echo "=== StarRocks Performance Metrics ==="
    
    # Количество активных запросов
    local active_queries=$(mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "SHOW PROC '/queries';" 2>/dev/null | wc -l)
    echo "Active queries: $((active_queries - 1))"
    
    # Использование памяти
    local memory_usage=$(mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "SHOW PROC '/metrics';" 2>/dev/null | grep "Memory" | awk '{print $2}')
    echo "Memory usage: $memory_usage"
    
    # Количество таблиц
    local table_count=$(mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "SHOW TABLES;" 2>/dev/null | wc -l)
    echo "Table count: $((table_count - 1))"
    
    # Размер данных
    local data_size=$(mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "SELECT SUM(DataSize) FROM information_schema.tables;" 2>/dev/null)
    echo "Data size: $data_size bytes"
}

# Тест производительности
run_performance_test() {
    echo "=== Performance Test ==="
    
    # Создание тестовой таблицы
    mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "
        CREATE DATABASE IF NOT EXISTS perf_test;
        USE perf_test;
        CREATE TABLE IF NOT EXISTS test_table (
            id INT,
            name VARCHAR(50),
            value DECIMAL(10,2)
        ) DUPLICATE KEY(id)
        DISTRIBUTED BY HASH(id) BUCKETS 3
        PROPERTIES('replication_num' = '1');
    " 2>/dev/null
    
    # Вставка тестовых данных
    echo "Inserting test data..."
    for i in {1..1000}; do
        mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "
            USE perf_test;
            INSERT INTO test_table VALUES ($i, 'test$i', $i.50);
        " 2>/dev/null
    done
    
    # Тест запроса
    echo "Running performance test..."
    time mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "
        USE perf_test;
        SELECT COUNT(*), AVG(value) FROM test_table;
    " 2>/dev/null
    
    # Очистка
    mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "
        DROP DATABASE IF EXISTS perf_test;
    " 2>/dev/null
}

main() {
    get_performance_metrics
    echo
    run_performance_test
}

main "$@"
```

## Log Monitoring

### 1. Log Aggregation with ELK Stack

```yaml
# docker-compose-monitoring.yml
version: '3.8'

services:
  # StarRocks (existing)
  starrocks-fe:
    # ... existing configuration
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  starrocks-be:
    # ... existing configuration
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # Elasticsearch
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data

  # Logstash
  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.0
    container_name: logstash
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5044:5044"
    depends_on:
      - elasticsearch

  # Kibana
  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  elasticsearch-data:
```

### 2. Logstash Configuration

```ruby
# logstash.conf
input {
  file {
    path => "/var/lib/docker/containers/*/logs/*.log"
    type => "docker"
    start_position => "beginning"
  }
}

filter {
  if [type] == "docker" {
    json {
      source => "message"
    }
    
    if [log] =~ /starrocks/ {
      grok {
        match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}" }
      }
      
      date {
        match => [ "timestamp", "yyyy-MM-dd HH:mm:ss" ]
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "starrocks-logs-%{+YYYY.MM.dd}"
  }
}
```

## Integration Examples

### 1. Slack Notifications

```python
# slack_notifier.py
import requests
import json
import subprocess
import sys

def check_starrocks_health():
    """Проверка здоровья StarRocks"""
    try:
        result = subprocess.run([
            'mysql', '-h', 'localhost', '-P', '9030', '-u', 'root', 
            '-e', 'SELECT 1;'
        ], capture_output=True, text=True)
        return result.returncode == 0
    except Exception as e:
        return False

def send_slack_notification(message, webhook_url):
    """Отправка уведомления в Slack"""
    payload = {
        "text": f"🚨 StarRocks Alert: {message}"
    }
    
    try:
        response = requests.post(webhook_url, json=payload)
        response.raise_for_status()
        print(f"Notification sent: {message}")
    except Exception as e:
        print(f"Failed to send notification: {e}")

def main():
    webhook_url = "YOUR_SLACK_WEBHOOK_URL"
    
    if not check_starrocks_health():
        send_slack_notification("StarRocks is down!", webhook_url)
        sys.exit(1)
    else:
        print("StarRocks is healthy")

if __name__ == "__main__":
    main()
```

### 2. Email Notifications

```bash
#!/bin/bash

# email_notifier.sh

STARROCKS_HOST="localhost"
STARROCKS_PORT="9030"
STARROCKS_USER="root"

# Конфигурация email
EMAIL_TO="admin@company.com"
EMAIL_FROM="starrocks@company.com"
SMTP_SERVER="smtp.company.com"

# Проверка здоровья
check_health() {
    mysql -h $STARROCKS_HOST -P $STARROCKS_PORT -u $STARROCKS_USER -e "SELECT 1;" > /dev/null 2>&1
    return $?
}

# Отправка email
send_email() {
    local subject="$1"
    local message="$2"
    
    echo "$message" | mail -s "$subject" -r "$EMAIL_FROM" "$EMAIL_TO"
}

# Основная логика
main() {
    if ! check_health; then
        send_email "StarRocks Alert" "StarRocks is down! Please check immediately."
        exit 1
    fi
    
    echo "StarRocks is healthy"
}

main "$@"
```

## Dashboard Templates

### 1. Grafana Dashboard JSON

```json
{
  "dashboard": {
    "id": null,
    "title": "StarRocks Cluster Overview",
    "tags": ["starrocks", "database"],
    "timezone": "browser",
    "refresh": "10s",
    "panels": [
      {
        "id": 1,
        "title": "Query Rate",
        "type": "graph",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "targets": [
          {
            "expr": "rate(starrocks_fe_query_total[5m])",
            "legendFormat": "Queries/sec"
          }
        ]
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "graph",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "targets": [
          {
            "expr": "starrocks_fe_memory_used_bytes / starrocks_fe_memory_total_bytes * 100",
            "legendFormat": "Memory %"
          }
        ]
      },
      {
        "id": 3,
        "title": "BE Node Status",
        "type": "stat",
        "gridPos": {"h": 4, "w": 6, "x": 0, "y": 8},
        "targets": [
          {
            "expr": "starrocks_be_alive",
            "legendFormat": "BE Alive"
          }
        ]
      },
      {
        "id": 4,
        "title": "FE Node Status",
        "type": "stat",
        "gridPos": {"h": 4, "w": 6, "x": 6, "y": 8},
        "targets": [
          {
            "expr": "starrocks_fe_alive",
            "legendFormat": "FE Alive"
          }
        ]
      }
    ]
  }
}
```

Эти примеры помогут настроить комплексный мониторинг для StarRocks в различных сценариях использования. 