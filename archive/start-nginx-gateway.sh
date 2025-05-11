#!/bin/bash

echo "Limpiando entorno anterior..."
docker compose -f docker-compose-nginx-gateway.yml down --remove-orphans

echo "Iniciando stack con NGINX como gateway..."
docker compose -f docker-compose-nginx-gateway.yml up -d

echo "Esperando a que los servicios estén disponibles..."
sleep 10

echo "Verificando estado del gateway..."
curl -s http://localhost:81/v1/health || echo "API no disponible"

echo
echo "Configuración completa:"
echo "- Frontend disponible en: http://localhost:8080"
echo "- API Gateway disponible en: http://localhost:81/v1/"
echo "- Servicio User disponible directamente en: http://localhost:8000"
echo
echo "Para probar el frontend, abre en tu navegador: http://localhost:8080"
