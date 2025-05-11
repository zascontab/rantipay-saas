#!/bin/bash

echo "Verificando estado de APISIX..."
docker logs rantipay_saas-apisix-1 | grep "Iniciando APISIX..."

if [ $? -ne 0 ]; then
  echo "APISIX no parece estar iniciado correctamente."
  docker logs rantipay_saas-apisix-1 | tail -n 50
  exit 1
fi

echo "Esperando a que APISIX esté disponible..."
for i in {1..10}; do
  if docker exec rantipay_saas-apisix-1 curl -s 127.0.0.1:9180/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' &>/dev/null; then
    echo "APISIX está listo."
    break
  fi
  
  if [ $i -eq 10 ]; then
    echo "Tiempo de espera agotado. APISIX no está respondiendo."
    exit 1
  fi
  
  echo "APISIX no está listo, esperando... ($i/10)"
  sleep 5
done

# Configurar ruta para el servicio de menús
echo "Configurando ruta para el servicio de menús..."
docker exec rantipay_saas-apisix-1 curl -s 127.0.0.1:9180/apisix/admin/routes/1 \
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
echo "Configurando ruta general para el servicio user..."
docker exec rantipay_saas-apisix-1 curl -s 127.0.0.1:9180/apisix/admin/routes/2 \
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

echo "Verificando rutas configuradas..."
docker exec rantipay_saas-apisix-1 curl -s 127.0.0.1:9180/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1'

# Configurar frontend para usar APISIX
echo "Configurando frontend para usar APISIX..."
mkdir -p ./kit-frontend/docker/nginx/

cat > ./kit-frontend/docker/nginx/default.conf << 'EOFNGINX'
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri $uri/ /index.html;
    }

    # Redirigir todas las llamadas a la API a APISIX
    location /v1/ {
        proxy_pass http://apisix:9080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOFNGINX

# Reiniciar el contenedor del frontend para aplicar la configuración
docker compose -f docker-compose-local.yml restart web

echo "Configuración completada. Verifica el frontend en http://localhost:8080"
