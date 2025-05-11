#!/bin/bash

echo "Deteniendo todos los contenedores..."
docker compose -f docker-compose-env.yml down

echo "Limpiando volúmenes antiguos..."
docker volume rm rantipay_saas_etcd_data 2>/dev/null || true

echo "Iniciando etcd primero y esperando a que esté listo..."
docker compose -f docker-compose-env.yml up -d etcd
sleep 5

echo "Verificando estado de etcd..."
docker exec -it $(docker ps -q -f name=rantipay_saas-etcd) etcdctl endpoint health || {
  echo "Error: etcd no está saludable"
  exit 1
}

echo "Iniciando APISIX..."
docker compose -f docker-compose-env.yml up -d apisix
sleep 10

echo "Verificando logs de APISIX para detectar errores..."
docker logs $(docker ps -q -f name=rantipay_saas-apisix) | grep -i error

echo "Iniciando servicios restantes..."
docker compose -f docker-compose-env.yml up -d

echo "Configurando frontend..."
mkdir -p ./kit-frontend/docker/nginx
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

echo "Reiniciando el contenedor web para aplicar la configuración..."
docker compose -f docker-compose-env.yml restart web

echo "Esperando para verificar si APISIX está disponible..."
for i in {1..30}; do
  if docker exec -it $(docker ps -q -f name=rantipay_saas-apisix) curl -s 127.0.0.1:9180/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' &>/dev/null; then
    echo "APISIX está listo."
    break
  fi
  
  if [ $i -eq 30 ]; then
    echo "Tiempo de espera agotado. APISIX no está respondiendo."
    echo "Verificando estado de todos los contenedores..."
    docker ps
    echo "Verificando logs de APISIX..."
    docker logs $(docker ps -q -f name=rantipay_saas-apisix)
    echo "Verificando red Docker..."
    docker network inspect rantipay_saas_default
    exit 1
  fi
  
  echo "APISIX no está listo, esperando... ($i/30)"
  sleep 5
done

echo "Configurando rutas en APISIX..."
# Configurar ruta para el servicio de menús
docker exec -it $(docker ps -q -f name=rantipay_saas-apisix) curl -s 127.0.0.1:9180/apisix/admin/routes/1 \
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
docker exec -it $(docker ps -q -f name=rantipay_saas-apisix) curl -s 127.0.0.1:9180/apisix/admin/routes/2 \
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
docker exec -it $(docker ps -q -f name=rantipay_saas-apisix) curl -s 127.0.0.1:9180/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1'

echo "Configuración completada. Verificar el frontend en http://localhost:8080"
