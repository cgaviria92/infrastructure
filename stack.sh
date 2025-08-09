#!/bin/bash

# WPA Stack Management Script
# Uso: ./stack.sh [comando] [opciones]

set -e

COMPOSE_FILE="docker-compose.prod.yml"
PROJECT_NAME="wpa"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Verificar que Docker está corriendo
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        error "Docker no está corriendo. Por favor inicia Docker Desktop."
    fi
}

# Verificar que existe el archivo .env
check_env() {
    if [ ! -f .env ]; then
        warning "Archivo .env no encontrado. Creando desde .env.example..."
        if [ -f .env.example ]; then
            cp .env.example .env
            warning "Por favor edita el archivo .env con tus configuraciones antes de continuar."
            exit 1
        else
            error "No se encontró .env.example. Crea un archivo .env manualmente."
        fi
    fi
}

# Mostrar ayuda
show_help() {
    echo "WPA Stack Management Script"
    echo ""
    echo "Uso: $0 [comando] [opciones]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start         Iniciar todo el stack"
    echo "  stop          Detener todo el stack"
    echo "  restart       Reiniciar todo el stack"
    echo "  build         Construir las imágenes"
    echo "  logs          Ver logs de todos los servicios"
    echo "  status        Ver estado de los servicios"
    echo "  backup        Crear backup de la base de datos"
    echo "  restore       Restaurar backup de la base de datos"
    echo "  update        Actualizar y reiniciar servicios"
    echo "  clean         Limpiar imágenes y volúmenes no utilizados"
    echo "  shell         Acceder al shell de la aplicación"
    echo "  migrate       Ejecutar migraciones de Django"
    echo "  collectstatic Recolectar archivos estáticos"
    echo "  createsuperuser Crear usuario administrador"
    echo ""
    echo "Opciones:"
    echo "  -f, --follow  Seguir logs en tiempo real"
    echo "  -d, --detach  Ejecutar en background"
    echo "  --service     Especificar servicio específico"
    echo ""
    echo "Ejemplos:"
    echo "  $0 start"
    echo "  $0 logs -f"
    echo "  $0 logs --service wpa"
    echo "  $0 backup"
    echo "  $0 shell"
}

# Iniciar stack
start_stack() {
    log "Iniciando WPA Stack..."
    check_docker
    check_env
    
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME up -d
    
    log "Esperando que los servicios estén listos..."
    sleep 30
    
    # Verificar health checks
    if docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME ps | grep -q "unhealthy"; then
        warning "Algunos servicios no están saludables. Verificando..."
        docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME ps
    else
        success "Stack iniciado exitosamente!"
        show_urls
    fi
}

# Detener stack
stop_stack() {
    log "Deteniendo WPA Stack..."
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME down
    success "Stack detenido."
}

# Reiniciar stack
restart_stack() {
    log "Reiniciando WPA Stack..."
    stop_stack
    start_stack
}

# Construir imágenes
build_stack() {
    log "Construyendo imágenes..."
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME build --no-cache
    success "Imágenes construidas."
}

# Ver logs
show_logs() {
    local follow=""
    local service=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--follow)
                follow="-f"
                shift
                ;;
            --service)
                service="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    if [ -n "$service" ]; then
        docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME logs $follow $service
    else
        docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME logs $follow
    fi
}

# Ver estado
show_status() {
    log "Estado de los servicios:"
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME ps
    
    echo ""
    log "Uso de recursos:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Crear backup
create_backup() {
    log "Creando backup de la base de datos..."
    local backup_file="backup-$(date +%Y%m%d_%H%M%S).sql"
    
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME exec -T postgres pg_dump -U wpa_user wpa_db > "backups/$backup_file"
    
    success "Backup creado: backups/$backup_file"
}

# Restaurar backup
restore_backup() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        error "Especifica el archivo de backup: $0 restore <archivo.sql>"
    fi
    
    if [ ! -f "$backup_file" ]; then
        error "Archivo de backup no encontrado: $backup_file"
    fi
    
    warning "Esto sobrescribirá la base de datos actual. ¿Continuar? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log "Operación cancelada."
        exit 0
    fi
    
    log "Restaurando backup: $backup_file"
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME exec -T postgres psql -U wpa_user -d wpa_db < "$backup_file"
    
    success "Backup restaurado exitosamente."
}

# Actualizar servicios
update_stack() {
    log "Actualizando servicios..."
    
    # Pull latest images
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME pull
    
    # Recreate containers
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME up -d --remove-orphans
    
    # Clean up
    docker image prune -f
    
    success "Servicios actualizados."
}

# Limpiar sistema
clean_system() {
    warning "Esto eliminará imágenes y volúmenes no utilizados. ¿Continuar? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log "Operación cancelada."
        exit 0
    fi
    
    log "Limpiando sistema Docker..."
    docker system prune -f
    docker volume prune -f
    
    success "Sistema limpiado."
}

# Acceder al shell
access_shell() {
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME exec wpa bash
}

# Ejecutar migraciones
run_migrations() {
    log "Ejecutando migraciones..."
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME exec wpa python manage.py migrate
    success "Migraciones completadas."
}

# Recolectar estáticos
collect_static() {
    log "Recolectando archivos estáticos..."
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME exec wpa python manage.py collectstatic --noinput
    success "Archivos estáticos recolectados."
}

# Crear superusuario
create_superuser() {
    docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME exec wpa python manage.py createsuperuser
}

# Mostrar URLs de acceso
show_urls() {
    echo ""
    echo "🌐 URLs de acceso:"
    echo "  Aplicación principal: http://localhost"
    echo "  Portainer (monitoring): http://localhost:9000"
    echo "  Grafana (dashboards): http://localhost:3000"
    echo "  Prometheus (metrics): http://localhost:9090"
    echo ""
    echo "📊 Credenciales por defecto:"
    echo "  Portainer: admin / admin123456789"
    echo "  Grafana: admin / admin123"
    echo ""
}

# Crear directorio de backups si no existe
mkdir -p backups

# Procesar comandos
case "$1" in
    start)
        start_stack
        ;;
    stop)
        stop_stack
        ;;
    restart)
        restart_stack
        ;;
    build)
        build_stack
        ;;
    logs)
        shift
        show_logs "$@"
        ;;
    status)
        show_status
        ;;
    backup)
        create_backup
        ;;
    restore)
        restore_backup "$2"
        ;;
    update)
        update_stack
        ;;
    clean)
        clean_system
        ;;
    shell)
        access_shell
        ;;
    migrate)
        run_migrations
        ;;
    collectstatic)
        collect_static
        ;;
    createsuperuser)
        create_superuser
        ;;
    urls)
        show_urls
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Comando no reconocido: $1"
        echo "Usa '$0 help' para ver comandos disponibles."
        exit 1
        ;;
esac
