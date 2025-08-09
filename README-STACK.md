# WPA - Web Platform Application Stack Completo

Una plataforma web empresarial desarrollada con Django para la gestión de formularios dinámicos, organizaciones y automatización de procesos de negocio.

## 🚀 Stack Tecnológico

### Backend
- **Django 5.2.5** - Framework web principal
- **PostgreSQL 15** - Base de datos principal
- **Redis 7** - Cache y sesiones
- **Python 3.12** - Lenguaje de programación

### Frontend
- **Bootstrap 5** - Framework CSS
- **JavaScript vanilla** - Interactividad del cliente
- **Font Awesome** - Iconografía

### DevOps & Infraestructura
- **Docker & Docker Compose** - Containerización
- **Nginx** - Proxy reverso y servidor web
- **GitHub Actions** - CI/CD automático
- **Portainer** - Gestión visual de contenedores
- **Grafana + Prometheus** - Monitoreo y métricas

## 📋 Características Principales

- ✅ **Formularios Dinámicos**: Creación y gestión de formularios personalizables
- ✅ **Plantillas Predefinidas**: Templates listos para usar por categoría de negocio
- ✅ **Gestión de Organizaciones**: Sistema multi-tenant con roles y permisos
- ✅ **Automatización de Procesos**: Lógica de negocio personalizable
- ✅ **Sistema de Monedas**: Gamificación y control de recursos
- ✅ **API REST**: Endpoints para integración externa
- ✅ **Dashboard Analítico**: Métricas y reportes en tiempo real
- ✅ **Gestión de Inventario**: Control de stock y transacciones
- ✅ **Sistema de Actividades**: Auditoría y trazabilidad completa

## 🛠️ Inicio Rápido

### Prerequisitos
- Docker Desktop
- Git
- 4GB RAM disponible
- 10GB espacio en disco

### Instalación de Desarrollo

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/cgaviria92/WPA.git
   cd WPA
   ```

2. **Configurar variables de entorno**
   ```bash
   cp .env.example .env
   # Editar .env con tus configuraciones
   ```

3. **Iniciar en modo desarrollo**
   ```bash
   # Linux/Mac
   ./stack.sh start
   
   # Windows (PowerShell)
   .\stack.ps1 start
   
   # Windows (CMD)
   stack.bat start
   ```

4. **Acceder a la aplicación**
   - Aplicación: http://localhost
   - Admin: admin / admin1234

### Instalación de Producción

1. **Preparar servidor**
   ```bash
   # Instalar Docker y Docker Compose
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   
   # Clonar repositorio
   git clone https://github.com/cgaviria92/WPA.git /opt/wpa
   cd /opt/wpa
   ```

2. **Configurar producción**
   ```bash
   cp .env.example .env
   # Configurar variables de producción
   
   # Generar secretos seguros
   openssl rand -base64 32  # Para DJANGO_SECRET_KEY
   openssl rand -base64 16  # Para POSTGRES_PASSWORD
   ```

3. **Desplegar stack completo**
   ```bash
   ./stack.sh start
   ```

## 🌐 URLs de Acceso

### Aplicación Principal
- **Frontend**: http://localhost
- **Admin Django**: http://localhost/admin/

### Herramientas de Monitoreo
- **Portainer**: http://localhost:9000 (admin / admin123456789)
- **Grafana**: http://localhost:3000 (admin / admin123)
- **Prometheus**: http://localhost:9090

## 🔧 Comandos de Gestión

El proyecto incluye scripts multiplataforma para gestión fácil:

### Linux/Mac
```bash
./stack.sh [comando]
```

### Windows PowerShell
```powershell
.\stack.ps1 [comando]
```

### Windows CMD
```cmd
stack.bat [comando]
```

### Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `start` | Iniciar todo el stack |
| `stop` | Detener todo el stack |
| `restart` | Reiniciar servicios |
| `build` | Construir imágenes |
| `logs` | Ver logs (-Follow para seguir) |
| `status` | Estado de servicios |
| `backup` | Crear backup de BD |
| `update` | Actualizar servicios |
| `shell` | Acceder al contenedor |
| `migrate` | Ejecutar migraciones |
| `urls` | Mostrar URLs de acceso |

### Ejemplos de Uso

```bash
# Iniciar stack completo
./stack.sh start

# Ver logs en tiempo real
./stack.sh logs -f

# Crear backup
./stack.sh backup

# Acceder al shell de Django
./stack.sh shell

# Ver estado de servicios
./stack.sh status
```

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Nginx       │    │   Portainer     │    │    Grafana      │
│  (Proxy/SSL)    │    │  (Monitoring)   │    │  (Dashboards)   │
│     :80/443     │    │     :9000       │    │     :3000       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Network (wpa-network)                │
└─────────────────────────────────────────────────────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Django WPA    │    │   PostgreSQL    │    │     Redis       │
│    :8000        │    │     :5432       │    │     :6379       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Prometheus    │    │   Watchtower    │    │    Volumes      │
│    :9090        │    │ (Auto-update)   │    │  (Persistent)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔄 CI/CD Automático

El proyecto incluye pipelines de GitHub Actions que se ejecutan automáticamente:

### En Pull Requests
- ✅ Tests unitarios
- ✅ Linting y formateo de código
- ✅ Análisis de seguridad
- ✅ Build de Docker
- ✅ Verificaciones de calidad

### En Push a Main
- 🚀 Deploy automático a producción
- 📦 Build y push de imágenes
- 🔄 Rolling update sin downtime
- 📊 Notificaciones de estado

### Configuración de Secrets

Para habilitar el deploy automático, configura estos secrets en GitHub:

```bash
PRODUCTION_HOST      # IP o dominio del servidor
PRODUCTION_USER      # Usuario SSH
PRODUCTION_SSH_KEY   # Clave privada SSH
PRODUCTION_PORT      # Puerto SSH (opcional, default: 22)
SLACK_WEBHOOK        # Webhook para notificaciones (opcional)
```

## 📊 Monitoreo y Métricas

### Grafana Dashboards
- **Aplicación**: Métricas de Django, requests, errores
- **Infraestructura**: CPU, memoria, disco, red
- **Base de Datos**: Conexiones, queries, performance
- **Contenedores**: Estado, recursos, logs

### Prometheus Targets
- Aplicación Django (métricas custom)
- Nginx (requests, response times)
- PostgreSQL (conexiones, queries)
- Redis (memoria, conexiones)
- Sistema (CPU, memoria, disco)

### Portainer Features
- 📊 Vista general de contenedores
- 📈 Métricas en tiempo real
- 🔍 Logs centralizados
- ⚙️ Gestión de volúmenes y redes
- 🔄 Updates y rollbacks

## 🔐 Seguridad

### Medidas Implementadas
- ✅ Usuario no-root en contenedores
- ✅ Rate limiting en Nginx
- ✅ Headers de seguridad
- ✅ Secrets en variables de entorno
- ✅ SSL/TLS ready
- ✅ Análisis de vulnerabilidades
- ✅ Backup automático

### Configuración SSL (Opcional)

1. **Obtener certificados**
   ```bash
   # Con Let's Encrypt
   certbot certonly --standalone -d tu-dominio.com
   ```

2. **Configurar Nginx**
   ```bash
   # Copiar certificados a ./ssl/
   cp /etc/letsencrypt/live/tu-dominio.com/* ./ssl/
   
   # Descomentar configuración SSL en nginx/sites-enabled/default
   ```

3. **Reiniciar stack**
   ```bash
   ./stack.sh restart
   ```

---

⭐ **¡No olvides dar una estrella al proyecto si te resulta útil!**
