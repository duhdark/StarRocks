# StarRocks Connection Script
# Connect to StarRocks via MySQL client

$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"

Write-Host "🔗 Connecting to StarRocks..." -ForegroundColor Green
Write-Host "📍 Host: localhost" -ForegroundColor Yellow
Write-Host "🔌 Port: 9030" -ForegroundColor Yellow
Write-Host "👤 User: root" -ForegroundColor Yellow
Write-Host ""

# Check if MySQL client is installed
if (-not (Test-Path $mysqlPath)) {
    Write-Host "❌ MySQL client not found at: $mysqlPath" -ForegroundColor Red
    Write-Host "💡 Install MySQL client or check the path" -ForegroundColor Yellow
    exit 1
}

# Check container status
Write-Host "🔍 Checking container status..." -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "🚀 Starting MySQL client..." -ForegroundColor Green
Write-Host "💡 Use 'exit' to quit" -ForegroundColor Yellow
Write-Host ""

# Start MySQL client
& $mysqlPath -h localhost -P 9030 -u root 