# StarRocks Cluster Management Script
# Управление StarRocks кластером

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "connect", "clean", "help")]
    [string]$Action = "status"
)

function Show-Header {
    Write-Host "🚀 StarRocks Cluster Management Script" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
}

function Start-StarRocksCluster {
    Write-Host "🔄 Запуск StarRocks кластера..." -ForegroundColor Yellow
    Write-Host "⚠️  Это может занять несколько минут..." -ForegroundColor Yellow
    docker-compose up -d
    Write-Host "✅ StarRocks кластер запущен!" -ForegroundColor Green
}

function Stop-StarRocksCluster {
    Write-Host "🛑 Остановка StarRocks кластера..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "✅ StarRocks кластер остановлен!" -ForegroundColor Green
}

function Restart-StarRocksCluster {
    Write-Host "🔄 Перезапуск StarRocks кластера..." -ForegroundColor Yellow
    docker-compose restart
    Write-Host "✅ StarRocks кластер перезапущен!" -ForegroundColor Green
}

function Show-Status {
    Write-Host "📊 Статус кластера:" -ForegroundColor Cyan
    docker-compose ps
    
    Write-Host "`n🔍 Проверка сетевых соединений:" -ForegroundColor Cyan
    docker network ls | Select-String "starrocks"
    
    Write-Host "`n📈 Информация о кластере:" -ForegroundColor Cyan
    Write-Host "FE узлы: 3 (starrocks-fe-1, starrocks-fe-2, starrocks-fe-3)" -ForegroundColor White
    Write-Host "BE узлы: 3 (starrocks-be-1, starrocks-be-2, starrocks-be-3)" -ForegroundColor White
    Write-Host "Порты: 9030-9032 (FE), 9060-9062 (BE)" -ForegroundColor White
}

function Show-Logs {
    Write-Host "📋 Логи StarRocks кластера:" -ForegroundColor Cyan
    Write-Host "1. Логи FE-1 (Frontend 1)"
    Write-Host "2. Логи FE-2 (Frontend 2)"
    Write-Host "3. Логи FE-3 (Frontend 3)"
    Write-Host "4. Логи BE-1 (Backend 1)"
    Write-Host "5. Логи BE-2 (Backend 2)"
    Write-Host "6. Логи BE-3 (Backend 3)"
    Write-Host "7. Все логи"
    
    $choice = Read-Host "`nВыберите опцию (1-7)"
    
    switch ($choice) {
        "1" { docker-compose logs starrocks-fe-1 }
        "2" { docker-compose logs starrocks-fe-2 }
        "3" { docker-compose logs starrocks-fe-3 }
        "4" { docker-compose logs starrocks-be-1 }
        "5" { docker-compose logs starrocks-be-2 }
        "6" { docker-compose logs starrocks-be-3 }
        "7" { docker-compose logs }
        default { Write-Host "❌ Неверный выбор" -ForegroundColor Red }
    }
}

function Connect-StarRocksCluster {
    Write-Host "🔗 Подключение к StarRocks кластеру..." -ForegroundColor Green
    & ".\connect.ps1"
}

function Clean-StarRocksCluster {
    Write-Host "🧹 Очистка StarRocks кластера..." -ForegroundColor Yellow
    Write-Host "⚠️  ВНИМАНИЕ: Это удалит все данные!" -ForegroundColor Red
    
    $confirm = Read-Host "Продолжить? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        docker-compose down -v
        docker system prune -f
        Write-Host "✅ StarRocks кластер очищен!" -ForegroundColor Green
    } else {
        Write-Host "❌ Операция отменена" -ForegroundColor Yellow
    }
}

function Show-Help {
    Write-Host "📖 Доступные команды:" -ForegroundColor Cyan
    Write-Host "  start   - Запустить StarRocks кластер" -ForegroundColor White
    Write-Host "  stop    - Остановить StarRocks кластер" -ForegroundColor White
    Write-Host "  restart - Перезапустить StarRocks кластер" -ForegroundColor White
    Write-Host "  status  - Показать статус кластера" -ForegroundColor White
    Write-Host "  logs    - Показать логи" -ForegroundColor White
    Write-Host "  connect - Подключиться к кластеру" -ForegroundColor White
    Write-Host "  clean   - Очистить все данные" -ForegroundColor White
    Write-Host "  help    - Показать эту справку" -ForegroundColor White
    
    Write-Host "`n📊 Архитектура кластера:" -ForegroundColor Cyan
    Write-Host "  FE-1: Основной узел (порт 9030)" -ForegroundColor White
    Write-Host "  FE-2: Реплика (порт 9031)" -ForegroundColor White
    Write-Host "  FE-3: Реплика (порт 9032)" -ForegroundColor White
    Write-Host "  BE-1: Backend узел (порт 9060)" -ForegroundColor White
    Write-Host "  BE-2: Backend узел (порт 9061)" -ForegroundColor White
    Write-Host "  BE-3: Backend узел (порт 9062)" -ForegroundColor White
}

# Основная логика
Show-Header

switch ($Action) {
    "start" { Start-StarRocksCluster }
    "stop" { Stop-StarRocksCluster }
    "restart" { Restart-StarRocksCluster }
    "status" { Show-Status }
    "logs" { Show-Logs }
    "connect" { Connect-StarRocksCluster }
    "clean" { Clean-StarRocksCluster }
    "help" { Show-Help }
    default { 
        Write-Host "❌ Неизвестная команда: $Action" -ForegroundColor Red
        Show-Help
    }
} 