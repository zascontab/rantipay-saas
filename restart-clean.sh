#!/bin/bash

echo "Deteniendo todos los contenedores..."
docker compose -f docker-compose-local.yml down

echo "Limpiando recursos antiguos..."
docker volume rm rantipay_saas_etcd_data 2>/dev/null || true

echo "Iniciando contenedores..."
docker compose -f docker-compose-local.yml up -d

echo "Esperando a que los servicios estén disponibles..."
sleep 20

echo "Verificando estado de APISIX..."
docker logs rantipay_saas-apisix-1

echo "Esperando a que APISIX esté completamente disponible..."
for i in {1..30}; do
  if docker exec -it rantipay_saas-apisix-1 curl -s 127.0.0.1:9180/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' &>/dev/null; then
    echo "APISIX está listo."
    break
  fi
  
  if [ $i -eq 30 ]; then
    echo "Tiempo de espera agotado. APISIX no está respondiendo."
    echo "Verificando logs de APISIX:"
    docker logs rantipay_saas-apisix-1
    exit 1
  fi
  
  echo "APISIX no está listo, esperando... ($i/30)"
  sleep 5
done

echo "Configurando rutas en APISIX..."
# Configurar ruta para el servicio de menús
docker exec -it rantipay_saas-apisix-1 curl -s 127.0.0.1:9180/apisix/admin/routes/1 \
  -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
  -X PUT -d '{
    "uri": "/v1/sys/menus/*",
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "user:8000": 1
        }
    }
}'

# Configurar ruta general para el servicio user
docker exec -it rantipay_saas-apisix-1 curl -s 127.0.0.1:9180/apisix/admin/routes/2 \
  -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
  -X PUT -d '{
    "uri": "/v1/*",
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "user:8000": 1
        }
    }
}'

echo "Verificando rutas configuradas:"
docker exec -it rantipay_saas-apisix-1 curl -s 127.0.0.1:9180/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1'

echo "Configuración completada. Verificar el frontend en http://localhost:8080"
