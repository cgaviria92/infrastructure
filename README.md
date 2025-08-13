# WPA - Infraestructura Simplificada

Esta infraestructura simplificada despliega WPA con los componentes esenciales:

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│     Nginx       │◄───┤       WPA       │◄───┤   PostgreSQL    │
│  (Port 80/443)  │    │   (Port 8000)   │    │   (Port 5432)   │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Componentes

- **PostgreSQL 15**: Base de datos principal
- **WPA Django App**: Aplicación web principal
- **Nginx**: Proxy reverso y servidor de archivos estáticos

## 📦 Inicio Rápido

### 1. Configuración inicial
```bash
# Copiar variables de entorno
cp .env.example .env

# Editar variables según necesidad
nano .env
```

### 2. Levantar servicios

**En Windows (PowerShell):**
```powershell
.\start-wpa.ps1
```

**En Linux/Mac:**
```bash
./start-wpa.sh
```

**Manual:**
```bash
docker-compose up -d --build
```

### 3. Verificar servicios
```bash
docker-compose ps
docker-compose logs -f
```

## 🌐 Acceso

- **Aplicación WPA**: http://localhost
- **Base de datos**: localhost:5432

## 🔧 Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f wpa
docker-compose logs -f postgres
docker-compose logs -f nginx

# Reiniciar servicios
docker-compose restart

# Parar servicios
docker-compose down

# Parar y eliminar volúmenes
docker-compose down -v

# Ejecutar comandos en contenedores
docker-compose exec wpa python manage.py migrate
docker-compose exec wpa python manage.py createsuperuser
docker-compose exec postgres psql -U wpa_user -d wpa_db
```

## 📁 Estructura de Archivos

```
infrastructure/
├── docker-compose.yml          # Configuración principal
├── .env.example               # Variables de entorno ejemplo
├── start-wpa.ps1             # Script de inicio Windows
├── start-wpa.sh              # Script de inicio Linux/Mac
├── nginx/
│   ├── nginx.conf            # Configuración Nginx principal
│   └── sites-enabled/
│       └── default           # Configuración sitio WPA
├── ssl/                      # Certificados SSL (opcional)
└── backups/                  # Backups de base de datos
```

## 🔒 Variables de Entorno

Las variables principales en `.env`:

```bash
# Base de datos
POSTGRES_PASSWORD=wpa_secure_password_2025
POSTGRES_DB=wpa_db
POSTGRES_USER=wpa_user

# Django
DJANGO_SECRET_KEY=your-super-secret-key-here
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,wpa.local

# URL de conexión
DATABASE_URL=postgresql://wpa_user:wpa_secure_password_2025@postgres:5432/wpa_db
```

## 🛠️ Desarrollo

Para desarrollo local, puedes modificar:

1. **Puerto de WPA**: Cambiar `8000:8000` en docker-compose.yml
2. **Configuración Nginx**: Editar `nginx/sites-enabled/default`
3. **Variables Django**: Ajustar `.env`

## 📊 Monitoreo

Los logs están disponibles en:
- Nginx: `docker-compose logs nginx`
- WPA: `docker-compose logs wpa`
- PostgreSQL: `docker-compose logs postgres`

## 🔄 Actualizaciones

Para actualizar WPA:
```bash
docker-compose down
docker-compose up -d --build
```

## 🆘 Troubleshooting

**Problema**: Servicios no arrancan
```bash
# Verificar logs
docker-compose logs

# Verificar recursos
docker system df
docker system prune
```

**Problema**: Base de datos no conecta
```bash
# Verificar PostgreSQL
docker-compose exec postgres pg_isready -U wpa_user
```

**Problema**: Nginx no sirve estáticos
```bash
# Verificar volúmenes
docker-compose exec nginx ls -la /var/www/static/
```
