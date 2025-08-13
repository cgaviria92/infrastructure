# Script para levantar WPA con infraestructura simplificada
# Solo PostgreSQL, Nginx y la aplicación WPA

Write-Host "🚀 Iniciando WPA con infraestructura simplificada..." -ForegroundColor Green
Write-Host "📦 Componentes: PostgreSQL + Nginx + WPA" -ForegroundColor Cyan

# Verificar que existe el archivo .env
if (-not (Test-Path .env)) {
    Write-Host "⚠️  Archivo .env no encontrado. Copiando desde .env.example..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✅ Por favor, revisa y ajusta las variables en .env antes de continuar" -ForegroundColor Green
    Write-Host "📝 Especialmente: POSTGRES_PASSWORD y DJANGO_SECRET_KEY" -ForegroundColor Yellow
}

# Construir y levantar los servicios
Write-Host "🔨 Construyendo y levantando servicios..." -ForegroundColor Blue
docker-compose up -d --build

# Verificar el estado de los servicios
Write-Host "⏳ Esperando que los servicios estén listos..." -ForegroundColor Yellow
Start-Sleep 10

Write-Host "🔍 Verificando estado de los servicios..." -ForegroundColor Blue
docker-compose ps

Write-Host ""
Write-Host "✅ WPA está disponible en:" -ForegroundColor Green
Write-Host "   🌐 Aplicación: http://localhost" -ForegroundColor White
Write-Host "   🐘 PostgreSQL: localhost:5432" -ForegroundColor White
Write-Host "   📊 Nginx logs: docker-compose logs nginx" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Comandos útiles:" -ForegroundColor Yellow
Write-Host "   Ver logs: docker-compose logs -f" -ForegroundColor White
Write-Host "   Parar: docker-compose down" -ForegroundColor White
Write-Host "   Reiniciar: docker-compose restart" -ForegroundColor White
