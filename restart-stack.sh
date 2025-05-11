#!/bin/bash

echo "Deteniendo contenedores..."
docker compose -f docker-compose-local.yml down

echo "Iniciando contenedores..."
docker compose -f docker-compose-local.yml up -d

echo "Esperando a que los servicios estén disponibles..."
sleep 15

# Crear directorio para configuración nginx si no existe
mkdir -p ./kit-frontend/docker/nginx/

# Crear archivo de configuración nginx para el frontend si no existe
if [ ! -f ./kit-frontend/docker/nginx/default.conf ]; then
    echo "Creando configuración nginx para el frontend..."
    cat > ./kit-frontend/docker/nginx/default.conf << 'EOF'
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
EOF
fi

# Ejecutar script para configurar rutas de APISIX
./setup-apisix-routes.sh

echo "El stack ha sido reiniciado. Accede a http://localhost:8080 para verificar el frontend."