#!/bin/bash

# StarRocks Deployment Test Script
# Этот скрипт автоматически тестирует развертывание StarRocks

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции для вывода
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка зависимостей
check_dependencies() {
    print_info "Проверка зависимостей..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker не установлен"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose не установлен"
        exit 1
    fi
    
    print_success "Все зависимости установлены"
}

# Проверка доступности портов
check_ports() {
    local ports=("9030" "9031" "9032" "9060" "9061" "9062")
    
    print_info "Проверка доступности портов..."
    
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            print_warning "Порт $port уже занят"
        else
            print_success "Порт $port свободен"
        fi
    done
}

# Тестирование Single Node
test_single_node() {
    print_info "Тестирование Single Node развертывания..."
    
    cd starrocks-single-node
    
    # Остановка существующих контейнеров
    print_info "Остановка существующих контейнеров..."
    docker-compose down -v 2>/dev/null || true
    
    # Запуск контейнеров
    print_info "Запуск Single Node кластера..."
    docker-compose up -d
    
    # Ожидание запуска
    print_info "Ожидание запуска сервисов..."
    sleep 60
    
    # Проверка статуса контейнеров
    print_info "Проверка статуса контейнеров..."
    if docker-compose ps | grep -q "Up"; then
        print_success "Контейнеры запущены"
    else
        print_error "Ошибка запуска контейнеров"
        docker-compose logs
        return 1
    fi
    
    # Проверка подключения к StarRocks
    print_info "Проверка подключения к StarRocks..."
    sleep 30
    
    if command -v mysql &> /dev/null; then
        if mysql -h localhost -P 9030 -u root -e "SELECT 1;" 2>/dev/null; then
            print_success "Подключение к StarRocks успешно"
        else
            print_warning "Не удалось подключиться к StarRocks (mysql клиент не найден или не работает)"
        fi
    else
        print_warning "MySQL клиент не установлен, пропускаем проверку подключения"
    fi
    
    # Проверка HTTP интерфейса
    print_info "Проверка HTTP интерфейса..."
    if curl -s http://localhost:9030 > /dev/null 2>&1; then
        print_success "HTTP интерфейс доступен"
    else
        print_warning "HTTP интерфейс недоступен"
    fi
    
    cd ..
}

# Тестирование Cluster
test_cluster() {
    print_info "Тестирование Cluster развертывания..."
    
    cd starrocks-cluster
    
    # Остановка существующих контейнеров
    print_info "Остановка существующих контейнеров..."
    docker-compose down -v 2>/dev/null || true
    
    # Запуск контейнеров
    print_info "Запуск Cluster..."
    docker-compose up -d
    
    # Ожидание запуска
    print_info "Ожидание запуска кластера..."
    sleep 120
    
    # Проверка статуса контейнеров
    print_info "Проверка статуса контейнеров..."
    if docker-compose ps | grep -q "Up"; then
        print_success "Контейнеры кластера запущены"
    else
        print_error "Ошибка запуска контейнеров кластера"
        docker-compose logs
        return 1
    fi
    
    # Проверка подключения к кластеру
    print_info "Проверка подключения к кластеру..."
    sleep 30
    
    if command -v mysql &> /dev/null; then
        if mysql -h localhost -P 9030 -u root -e "SELECT 1;" 2>/dev/null; then
            print_success "Подключение к кластеру успешно"
        else
            print_warning "Не удалось подключиться к кластеру"
        fi
    else
        print_warning "MySQL клиент не установлен, пропускаем проверку подключения"
    fi
    
    # Проверка HTTP интерфейсов
    print_info "Проверка HTTP интерфейсов кластера..."
    for port in 9030 9031 9032; do
        if curl -s http://localhost:$port > /dev/null 2>&1; then
            print_success "HTTP интерфейс на порту $port доступен"
        else
            print_warning "HTTP интерфейс на порту $port недоступен"
        fi
    done
    
    cd ..
}

# Очистка
cleanup() {
    print_info "Очистка тестовых окружений..."
    
    # Очистка Single Node
    cd starrocks-single-node
    docker-compose down -v 2>/dev/null || true
    cd ..
    
    # Очистка Cluster
    cd starrocks-cluster
    docker-compose down -v 2>/dev/null || true
    cd ..
    
    print_success "Очистка завершена"
}

# Основная функция
main() {
    print_info "Начало тестирования StarRocks развертывания..."
    
    # Проверка зависимостей
    check_dependencies
    
    # Проверка портов
    check_ports
    
    # Тестирование Single Node
    if test_single_node; then
        print_success "Single Node тест пройден"
    else
        print_error "Single Node тест провален"
    fi
    
    # Очистка Single Node
    cleanup
    
    # Тестирование Cluster
    if test_cluster; then
        print_success "Cluster тест пройден"
    else
        print_error "Cluster тест провален"
    fi
    
    # Финальная очистка
    cleanup
    
    print_success "Тестирование завершено!"
    print_info "Для запуска вручную используйте:"
    print_info "  cd starrocks-single-node && docker-compose up -d"
    print_info "  cd starrocks-cluster && docker-compose up -d"
}

# Обработка сигналов
trap cleanup EXIT

# Запуск основной функции
main "$@" 