# WPA Stack Management Script para PowerShell
# Uso: .\stack.ps1 [comando] [opciones]

param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1)]
    [string]$Option,
    
    [switch]$Follow,
    [switch]$Detach,
    [string]$Service
)

$ComposeFile = "docker-compose.prod.yml"
$ProjectName = "wpa"

function Write-Log {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
    exit 1
}

function Test-Docker {
    try {
        docker info | Out-Null
    }
    catch {
        Write-Error "Docker no está corriendo. Por favor inicia Docker Desktop."
    }
}

function Test-EnvFile {
    if (-not (Test-Path .env)) {
        Write-Warning "Archivo .env no encontrado."
        if (Test-Path .env.example) {
            Write-Warning "Creando .env desde .env.example..."
            Copy-Item .env.example .env
            Write-Warning "Por favor edita el archivo .env con tus configuraciones antes de continuar."
            exit 1
        } else {
            Write-Error "No se encontró .env.example. Crea un archivo .env manualmente."
        }
    }
}

function Start-Stack {
    Write-Log "Iniciando WPA Stack..."
    Test-Docker
    Test-EnvFile
    
    docker-compose -f $ComposeFile -p $ProjectName up -d
    
    Write-Log "Esperando que los servicios estén listos..."
    Start-Sleep -Seconds 30
    
    Write-Success "Stack iniciado exitosamente!"
    Show-Urls
}

function Stop-Stack {
    Write-Log "Deteniendo WPA Stack..."
    docker-compose -f $ComposeFile -p $ProjectName down
    Write-Success "Stack detenido."
}

function Restart-Stack {
    Write-Log "Reiniciando WPA Stack..."
    Stop-Stack
    Start-Stack
}

function Build-Stack {
    Write-Log "Construyendo imágenes..."
    docker-compose -f $ComposeFile -p $ProjectName build --no-cache
    Write-Success "Imágenes construidas."
}

function Show-Logs {
    $logArgs = @()
    if ($Follow) { $logArgs += "-f" }
    if ($Service) { $logArgs += $Service }
    
    docker-compose -f $ComposeFile -p $ProjectName logs @logArgs
}

function Show-Status {
    Write-Log "Estado de los servicios:"
    docker-compose -f $ComposeFile -p $ProjectName ps
    
    Write-Host ""
    Write-Log "Uso de recursos:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

function New-Backup {
    Write-Log "Creando backup de la base de datos..."
    $backupFile = "backup-$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
    
    if (-not (Test-Path backups)) {
        New-Item -ItemType Directory -Path backups | Out-Null
    }
    
    docker-compose -f $ComposeFile -p $ProjectName exec -T postgres pg_dump -U wpa_user wpa_db | Out-File -FilePath "backups\$backupFile" -Encoding UTF8
    
    Write-Success "Backup creado: backups\$backupFile"
}

function Update-Stack {
    Write-Log "Actualizando servicios..."
    
    docker-compose -f $ComposeFile -p $ProjectName pull
    docker-compose -f $ComposeFile -p $ProjectName up -d --remove-orphans
    docker image prune -f
    
    Write-Success "Servicios actualizados."
}

function Clear-System {
    $response = Read-Host "Esto eliminará imágenes y volúmenes no utilizados. Continuar? (s/N)"
    if ($response -eq "s" -or $response -eq "S") {
        Write-Log "Limpiando sistema Docker..."
        docker system prune -f
        docker volume prune -f
        Write-Success "Sistema limpiado."
    } else {
        Write-Log "Operación cancelada."
    }
}

function Enter-Shell {
    docker-compose -f $ComposeFile -p $ProjectName exec wpa bash
}

function Invoke-Migrations {
    Write-Log "Ejecutando migraciones..."
    docker-compose -f $ComposeFile -p $ProjectName exec wpa python manage.py migrate
    Write-Success "Migraciones completadas."
}

function Invoke-CollectStatic {
    Write-Log "Recolectando archivos estáticos..."
    docker-compose -f $ComposeFile -p $ProjectName exec wpa python manage.py collectstatic --noinput
    Write-Success "Archivos estáticos recolectados."
}

function New-SuperUser {
    docker-compose -f $ComposeFile -p $ProjectName exec wpa python manage.py createsuperuser
}

function Show-Urls {
    Write-Host ""
    Write-Host "🌐 URLs de acceso:" -ForegroundColor Cyan
    Write-Host "  Aplicación principal: http://localhost"
    Write-Host "  Portainer (monitoring): http://localhost:9000"
    Write-Host "  Grafana (dashboards): http://localhost:3000"
    Write-Host "  Prometheus (metrics): http://localhost:9090"
    Write-Host ""
    Write-Host "📊 Credenciales por defecto:" -ForegroundColor Cyan
    Write-Host "  Portainer: admin / admin123456789"
    Write-Host "  Grafana: admin / admin123"
    Write-Host ""
}

function Show-Help {
    Write-Host "WPA Stack Management Script" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso: .\stack.ps1 [comando] [opciones]"
    Write-Host ""
    Write-Host "Comandos disponibles:"
    Write-Host "  start         Iniciar todo el stack"
    Write-Host "  stop          Detener todo el stack"
    Write-Host "  restart       Reiniciar todo el stack"
    Write-Host "  build         Construir las imágenes"
    Write-Host "  logs          Ver logs de todos los servicios"
    Write-Host "  status        Ver estado de los servicios"
    Write-Host "  backup        Crear backup de la base de datos"
    Write-Host "  update        Actualizar y reiniciar servicios"
    Write-Host "  clean         Limpiar imágenes y volúmenes no utilizados"
    Write-Host "  shell         Acceder al shell de la aplicación"
    Write-Host "  migrate       Ejecutar migraciones de Django"
    Write-Host "  collectstatic Recolectar archivos estáticos"
    Write-Host "  createsuperuser Crear usuario administrador"
    Write-Host "  urls          Mostrar URLs de acceso"
    Write-Host ""
    Write-Host "Opciones:"
    Write-Host "  -Follow       Seguir logs en tiempo real"
    Write-Host "  -Service      Especificar servicio específico"
    Write-Host ""
    Write-Host "Ejemplos:"
    Write-Host "  .\stack.ps1 start"
    Write-Host "  .\stack.ps1 logs -Follow"
    Write-Host "  .\stack.ps1 logs -Service wpa"
    Write-Host "  .\stack.ps1 backup"
    Write-Host "  .\stack.ps1 shell"
}

# Crear directorio de backups si no existe
if (-not (Test-Path backups)) {
    New-Item -ItemType Directory -Path backups | Out-Null
}

# Procesar comandos
switch ($Command) {
    "start" { Start-Stack }
    "stop" { Stop-Stack }
    "restart" { Restart-Stack }
    "build" { Build-Stack }
    "logs" { Show-Logs }
    "status" { Show-Status }
    "backup" { New-Backup }
    "update" { Update-Stack }
    "clean" { Clear-System }
    "shell" { Enter-Shell }
    "migrate" { Invoke-Migrations }
    "collectstatic" { Invoke-CollectStatic }
    "createsuperuser" { New-SuperUser }
    "urls" { Show-Urls }
    "help" { Show-Help }
    default {
        if ([string]::IsNullOrEmpty($Command)) {
            Show-Help
        } else {
            Write-Host "Comando no reconocido: $Command" -ForegroundColor Red
            Write-Host "Usa '.\stack.ps1 help' para ver comandos disponibles."
        }
    }
}
