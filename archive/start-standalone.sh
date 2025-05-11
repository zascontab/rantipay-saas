#!/bin/bash

echo "Deteniendo contenedores existentes..."
docker compose -f docker-compose-standalone.yml down

echo "Iniciando stack con APISIX en modo standalone..."
docker compose -f docker-compose-standalone.yml up -d

echo "Esperando a que los servicios estén disponibles..."
sleep 10

echo "Verificando estado de APISIX..."
docker exec $(docker ps -q -f name=rantipay_saas-apisix) curl -s 127.0.0.1:9180/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1'

echo "Configuración completa. Frontend disponible en http://localhost:8080"
echo "APISIX Admin API disponible en http://localhost:9180/apisix/admin/"
echo "Servicio User disponible en http://localhost:8000"
