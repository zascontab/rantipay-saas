#!/bin/bash

# Esperar a que APISIX esté listo
echo "Esperando a que APISIX esté disponible..."
until curl -s http://localhost:9180/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' > /dev/null; do
  echo "APISIX no está listo, esperando..."
  sleep 5
done

# Configurar ruta para el servicio de menús
echo "Configurando ruta para el servicio de menús..."
curl http://localhost:9180/apisix/admin/routes/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '{
    "uri": "/v1/sys/menus/*",
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "user:8000": 1
        }
    }
}'

# Configurar ruta general para el servicio user
echo "Configurando ruta general para el servicio user..."
curl http://localhost:9180/apisix/admin/routes/2 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '{
    "uri": "/v1/*",
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "user:8000": 1
        }
    }
}'

echo "Configuración de rutas en APISIX completada."