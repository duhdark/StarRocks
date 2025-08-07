# StarRocks Cluster Connection Script
# Подключение к StarRocks кластеру через MySQL клиент

$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"

Write-Host "🔗 Подключение к StarRocks кластеру..." -ForegroundColor Green
Write-Host "📍 Хост: localhost" -ForegroundColor Yellow
Write-Host "🔌 Порт: 9030 (FE-1), 9031 (FE-2), 9032 (FE-3)" -ForegroundColor Yellow
Write-Host "👤 Пользователь: root" -ForegroundColor Yellow
Write-Host ""

# Проверяем, что MySQL клиент установлен
if (-not (Test-Path $mysqlPath)) {
    Write-Host "❌ MySQL клиент не найден по пути: $mysqlPath" -ForegroundColor Red
    Write-Host "💡 Установите MySQL клиент или проверьте путь" -ForegroundColor Yellow
    exit 1
}

# Проверяем статус контейнеров
Write-Host "🔍 Проверка статуса кластера..." -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "🚀 Выбор узла для подключения:" -ForegroundColor Green
Write-Host "1. FE-1 (основной узел) - порт 9030" -ForegroundColor White
Write-Host "2. FE-2 (реплика) - порт 9031" -ForegroundColor White
Write-Host "3. FE-3 (реплика) - порт 9032" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Выберите узел (1-3, по умолчанию 1)"

$port = switch ($choice) {
    "2" { "9031" }
    "3" { "9032" }
    default { "9030" }
}

Write-Host "🔗 Подключение к FE-$choice на порту $port..." -ForegroundColor Green
Write-Host "💡 Для выхода используйте: exit" -ForegroundColor Yellow
Write-Host ""

# Запускаем MySQL клиент
& $mysqlPath -h localhost -P $port -u root 