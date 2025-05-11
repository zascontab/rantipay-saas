#!/bin/bash

echo "Limpiando entorno anterior..."
docker compose -f docker-compose-update.yml down --remove-orphans

echo "Iniciando stack con servicios go-saas/kit..."
docker compose -f docker-compose-update.yml up -d

echo "Esperando a que los servicios estén disponibles..."
sleep 20

echo "Verificando estado de los servicios..."
echo "1. Usuario:"
curl -s http://localhost:81/v1/user/health || echo "Servicio User no disponible"

echo "2. SaaS:"
curl -s http://localhost:81/v1/saas/health || echo "Servicio SaaS no disponible"

echo "3. Sys:"
curl -s http://localhost:81/v1/sys/health || echo "Servicio Sys no disponible"

echo
echo "Configuración completa:"
echo "- Frontend disponible en: http://localhost:8080"
echo "- API Gateway disponible en: http://localhost:81/v1/"
echo "- Servicios individuales disponibles en:"
echo "  - User: http://localhost:8000"
echo "  - SaaS: http://localhost:8002"
echo "  - Sys: http://localhost:8003"
echo
echo "Para probar el frontend, abre en tu navegador: http://localhost:8080"
