#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que el archivo nginx-simple-proxy.conf existe
if [ ! -f "nginx-gateway/nginx-simple-proxy.conf" ]; then
    echo -e "${RED}El archivo nginx-gateway/nginx-simple-proxy.conf no existe.${NC}"
    
    # Crear el archivo
    echo -e "${YELLOW}Creando archivo nginx-gateway/nginx-simple-proxy.conf...${NC}"
    
    mkdir -p nginx-gateway
    
    cat > nginx-gateway/nginx-simple-proxy.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    sendfile        on;
    keepalive_timeout  65;

    # Configuración para logs y manejo de errores
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log  /var/log/nginx/access.log  main;
    error_log   /var/log/nginx/error.log  warn;

    # Buffers aumentados para mejorar rendimiento
    proxy_buffer_size   128k;
    proxy_buffers       4 256k;
    proxy_busy_buffers_size 256k;

    # Timeouts aumentados
    proxy_connect_timeout 60s;
    proxy_read_timeout 60s;
    proxy_send_timeout 60s;

    server {
        listen 80;
        server_name localhost;
        
        # Ruta para el servicio user simple
        location /v1/ {
            proxy_pass http://user:8000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Ruta directa para el servicio user
        location = /v1 {
            proxy_pass http://user:8000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Ruta para health check
        location /health {
            access_log off;
            return 200 "API Gateway Healthy\n";
        }
        
        # Ruta de fallback
        location / {
            return 404 'API Gateway: Endpoint not found';
        }
    }
}
EOF
    
    echo -e "${GREEN}Archivo nginx-gateway/nginx-simple-proxy.conf creado.${NC}"
else
    echo -e "${GREEN}El archivo nginx-gateway/nginx-simple-proxy.conf existe.${NC}"
fi

# Copiar a nginx.conf para asegurarnos
cp nginx-gateway/nginx-simple-proxy.conf nginx-gateway/nginx.conf
echo -e "${GREEN}Archivo copiado a nginx-gateway/nginx.conf${NC}"

echo -e "${YELLOW}Contenido del archivo nginx-gateway/nginx.conf:${NC}"
cat nginx-gateway/nginx.conf | head -n 20
echo -e "${YELLOW}[...]${NC}"

echo -e "${GREEN}Verificación completa.${NC}"