#!/bin/bash

# Script para levantar WPA con infraestructura simplificada
# Solo PostgreSQL, Nginx y la aplicación WPA

echo "🚀 Iniciando WPA con infraestructura simplificada..."
echo "📦 Componentes: PostgreSQL + Nginx + WPA"

# Verificar que existe el archivo .env
if [ ! -f .env ]; then
    echo "⚠️  Archivo .env no encontrado. Copiando desde .env.example..."
    cp .env.example .env
    echo "✅ Por favor, revisa y ajusta las variables en .env antes de continuar"
    echo "📝 Especialmente: POSTGRES_PASSWORD y DJANGO_SECRET_KEY"
fi

# Construir y levantar los servicios
echo "🔨 Construyendo y levantando servicios..."
docker-compose up -d --build

# Verificar el estado de los servicios
echo "⏳ Esperando que los servicios estén listos..."
sleep 10

echo "🔍 Verificando estado de los servicios..."
docker-compose ps

echo ""
echo "✅ WPA está disponible en:"
echo "   🌐 Aplicación: http://localhost"
echo "   🐘 PostgreSQL: localhost:5432"
echo "   📊 Nginx logs: docker-compose logs nginx"
echo ""
echo "🔧 Comandos útiles:"
echo "   Ver logs: docker-compose logs -f"
echo "   Parar: docker-compose down"
echo "   Reiniciar: docker-compose restart"
