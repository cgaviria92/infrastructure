@echo off
REM WPA Stack Management Script para Windows
REM Uso: stack.bat [comando] [opciones]

setlocal enabledelayedexpansion

set COMPOSE_FILE=docker-compose.prod.yml
set PROJECT_NAME=wpa

REM Verificar que Docker está corriendo
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker no está corriendo. Por favor inicia Docker Desktop.
    exit /b 1
)

REM Verificar que existe el archivo .env
if not exist .env (
    echo ⚠️ Archivo .env no encontrado.
    if exist .env.example (
        echo Creando .env desde .env.example...
        copy .env.example .env
        echo ⚠️ Por favor edita el archivo .env con tus configuraciones antes de continuar.
        exit /b 1
    ) else (
        echo ❌ No se encontró .env.example. Crea un archivo .env manualmente.
        exit /b 1
    )
)

REM Crear directorio de backups si no existe
if not exist backups mkdir backups

if "%1"=="start" goto start_stack
if "%1"=="stop" goto stop_stack
if "%1"=="restart" goto restart_stack
if "%1"=="build" goto build_stack
if "%1"=="logs" goto show_logs
if "%1"=="status" goto show_status
if "%1"=="backup" goto create_backup
if "%1"=="update" goto update_stack
if "%1"=="clean" goto clean_system
if "%1"=="shell" goto access_shell
if "%1"=="migrate" goto run_migrations
if "%1"=="collectstatic" goto collect_static
if "%1"=="createsuperuser" goto create_superuser
if "%1"=="urls" goto show_urls
if "%1"=="help" goto show_help
if "%1"=="-h" goto show_help
if "%1"=="--help" goto show_help

echo Comando no reconocido: %1
echo Usa 'stack.bat help' para ver comandos disponibles.
exit /b 1

:start_stack
echo 🚀 Iniciando WPA Stack...
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% up -d
if errorlevel 1 (
    echo ❌ Error al iniciar el stack.
    exit /b 1
)
echo ⏳ Esperando que los servicios estén listos...
timeout /t 30 /nobreak >nul
echo ✅ Stack iniciado exitosamente!
goto show_urls

:stop_stack
echo 🛑 Deteniendo WPA Stack...
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% down
echo ✅ Stack detenido.
goto :eof

:restart_stack
echo 🔄 Reiniciando WPA Stack...
call :stop_stack
call :start_stack
goto :eof

:build_stack
echo 🔨 Construyendo imágenes...
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% build --no-cache
echo ✅ Imágenes construidas.
goto :eof

:show_logs
if "%2"=="-f" (
    docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% logs -f
) else (
    docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% logs
)
goto :eof

:show_status
echo 📊 Estado de los servicios:
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% ps
echo.
echo 💻 Uso de recursos:
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
goto :eof

:create_backup
echo 💾 Creando backup de la base de datos...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "backup_file=backup-%YYYY%%MM%%DD%_%HH%%Min%%Sec%.sql"

docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% exec -T postgres pg_dump -U wpa_user wpa_db > backups\%backup_file%
echo ✅ Backup creado: backups\%backup_file%
goto :eof

:update_stack
echo 🔄 Actualizando servicios...
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% pull
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% up -d --remove-orphans
docker image prune -f
echo ✅ Servicios actualizados.
goto :eof

:clean_system
echo ⚠️ Esto eliminará imágenes y volúmenes no utilizados. ¿Continuar? (s/N)
set /p response=
if /i "!response!"=="s" (
    echo 🧹 Limpiando sistema Docker...
    docker system prune -f
    docker volume prune -f
    echo ✅ Sistema limpiado.
) else (
    echo Operación cancelada.
)
goto :eof

:access_shell
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% exec wpa bash
goto :eof

:run_migrations
echo 🔄 Ejecutando migraciones...
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% exec wpa python manage.py migrate
echo ✅ Migraciones completadas.
goto :eof

:collect_static
echo 📦 Recolectando archivos estáticos...
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% exec wpa python manage.py collectstatic --noinput
echo ✅ Archivos estáticos recolectados.
goto :eof

:create_superuser
docker-compose -f %COMPOSE_FILE% -p %PROJECT_NAME% exec wpa python manage.py createsuperuser
goto :eof

:show_urls
echo.
echo 🌐 URLs de acceso:
echo   Aplicación principal: http://localhost
echo   Portainer (monitoring): http://localhost:9000
echo   Grafana (dashboards): http://localhost:3000
echo   Prometheus (metrics): http://localhost:9090
echo.
echo 📊 Credenciales por defecto:
echo   Portainer: admin / admin123456789
echo   Grafana: admin / admin123
echo.
goto :eof

:show_help
echo WPA Stack Management Script
echo.
echo Uso: %0 [comando] [opciones]
echo.
echo Comandos disponibles:
echo   start         Iniciar todo el stack
echo   stop          Detener todo el stack
echo   restart       Reiniciar todo el stack
echo   build         Construir las imágenes
echo   logs          Ver logs de todos los servicios
echo   status        Ver estado de los servicios
echo   backup        Crear backup de la base de datos
echo   update        Actualizar y reiniciar servicios
echo   clean         Limpiar imágenes y volúmenes no utilizados
echo   shell         Acceder al shell de la aplicación
echo   migrate       Ejecutar migraciones de Django
echo   collectstatic Recolectar archivos estáticos
echo   createsuperuser Crear usuario administrador
echo   urls          Mostrar URLs de acceso
echo.
echo Ejemplos:
echo   %0 start
echo   %0 logs -f
echo   %0 backup
echo   %0 shell
goto :eof
