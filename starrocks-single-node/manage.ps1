# StarRocks Management Script
# Управление StarRocks кластером

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "connect", "clean", "help")]
    [string]$Action = "status"
)

function Show-Header {
    Write-Host "🚀 StarRocks Management Script" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
}

function Start-StarRocks {
    Write-Host "🔄 Запуск StarRocks..." -ForegroundColor Yellow
    docker-compose up -d
    Write-Host "✅ StarRocks запущен!" -ForegroundColor Green
}

function Stop-StarRocks {
    Write-Host "🛑 Остановка StarRocks..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "✅ StarRocks остановлен!" -ForegroundColor Green
}

function Restart-StarRocks {
    Write-Host "🔄 Перезапуск StarRocks..." -ForegroundColor Yellow
    docker-compose restart
    Write-Host "✅ StarRocks перезапущен!" -ForegroundColor Green
}

function Show-Status {
    Write-Host "📊 Статус контейнеров:" -ForegroundColor Cyan
    docker-compose ps
    
    Write-Host "`n🔍 Проверка сетевых соединений:" -ForegroundColor Cyan
    docker network ls | Select-String "starrocks"
}

function Show-Logs {
    Write-Host "📋 Логи StarRocks:" -ForegroundColor Cyan
    Write-Host "1. Логи FE (Frontend)"
    Write-Host "2. Логи BE (Backend)"
    Write-Host "3. Все логи"
    
    $choice = Read-Host "`nВыберите опцию (1-3)"
    
    switch ($choice) {
        "1" { docker-compose logs starrocks-fe }
        "2" { docker-compose logs starrocks-be }
        "3" { docker-compose logs }
        default { Write-Host "❌ Неверный выбор" -ForegroundColor Red }
    }
}

function Connect-StarRocks {
    Write-Host "🔗 Подключение к StarRocks..." -ForegroundColor Green
    & ".\connect.ps1"
}

function Clean-StarRocks {
    Write-Host "🧹 Очистка StarRocks..." -ForegroundColor Yellow
    Write-Host "⚠️  ВНИМАНИЕ: Это удалит все данные!" -ForegroundColor Red
    
    $confirm = Read-Host "Продолжить? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        docker-compose down -v
        docker system prune -f
        Write-Host "✅ StarRocks очищен!" -ForegroundColor Green
    } else {
        Write-Host "❌ Операция отменена" -ForegroundColor Yellow
    }
}

function Show-Help {
    Write-Host "📖 Доступные команды:" -ForegroundColor Cyan
    Write-Host "  start   - Запустить StarRocks" -ForegroundColor White
    Write-Host "  stop    - Остановить StarRocks" -ForegroundColor White
    Write-Host "  restart - Перезапустить StarRocks" -ForegroundColor White
    Write-Host "  status  - Показать статус" -ForegroundColor White
    Write-Host "  logs    - Показать логи" -ForegroundColor White
    Write-Host "  connect - Подключиться к StarRocks" -ForegroundColor White
    Write-Host "  clean   - Очистить все данные" -ForegroundColor White
    Write-Host "  help    - Показать эту справку" -ForegroundColor White
}

# Основная логика
Show-Header

switch ($Action) {
    "start" { Start-StarRocks }
    "stop" { Stop-StarRocks }
    "restart" { Restart-StarRocks }
    "status" { Show-Status }
    "logs" { Show-Logs }
    "connect" { Connect-StarRocks }
    "clean" { Clean-StarRocks }
    "help" { Show-Help }
    default { 
        Write-Host "❌ Неизвестная команда: $Action" -ForegroundColor Red
        Show-Help
    }
} 