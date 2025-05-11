#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Volviendo al Servicio de Usuario Simplificado   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener todos los servicios actuales
echo -e "${YELLOW}Paso 1: Deteniendo servicios actuales...${NC}"
docker compose -f docker-compose-full-user.yml down --remove-orphans
echo -e "${GREEN}✓ Servicios detenidos${NC}"
echo ""

# Paso 2: Limpiar volúmenes para evitar problemas de estado
echo -e "${YELLOW}Paso 2: Limpiando volúmenes...${NC}"
docker volume rm rantipay_saas_mysql_data rantipay_saas_etcd_data 2>/dev/null || true
echo -e "${GREEN}✓ Volúmenes limpiados${NC}"
echo ""

# Paso 3: Actualizar la configuración de NGINX para usar el nuevo nombre de servicio correcto
echo -e "${YELLOW}Paso 3: Actualizando configuración de NGINX...${NC}"
cat > nginx-gateway/nginx-hybrid-plus.conf << 'EOF'
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
    error_log   /var/log/nginx/error.log  debug;

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
        
        # Ruta health check para NGINX
        location = /health {
            access_log off;
            return 200 "NGINX Gateway Healthy\n";
        }
        
        # Ruta health check para el servicio User
        location = /v1/user/health {
            proxy_pass http://simple-user:8000/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Rutas para el servicio User
        location /v1/user/ {
            proxy_pass http://simple-user:8000/v1/user/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        location /v1/auth/ {
            proxy_pass http://simple-user:8000/v1/auth/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        location /v1/sys/ {
            proxy_pass http://simple-user:8000/v1/sys/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        location /v1/realtime/ {
            proxy_pass http://simple-user:8000/v1/realtime/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
        
        # Rutas para el servicio Companies
        location /v1/companies/ {
            proxy_pass http://companies:8010/api/v1/companies/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        # Ruta health check del servicio Companies
        location = /v1/companies/health {
            proxy_pass http://companies:8010/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Ruta para assets estáticos
        location /assets/ {
            proxy_pass http://simple-user:8000/assets/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Ruta de fallback
        location / {
            return 404 'API Gateway: Endpoint not found';
        }
    }
}
EOF
echo -e "${GREEN}✓ Configuración de NGINX actualizada${NC}"
echo ""

# Paso 4: Crear un docker-compose para el servicio de usuario simplificado
echo -e "${YELLOW}Paso 4: Creando docker-compose para usuario simplificado...${NC}"
cat > docker-compose-hybrid-plus.yml << 'EOF'
services:
  # Infraestructura básica
  mysqld:
    image: mysql:8.0
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=youShouldChangeThis
      - MYSQL_ROOT_HOST=%
      - MYSQL_DATABASE=kit
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3406:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-pyouShouldChangeThis"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  redis:
    image: redis:6.0
    restart: always
    command: redis-server --requirepass youShouldChangeThis
    ports:
      - "7379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "youShouldChangeThis", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  etcd:
    image: bitnami/etcd:3.5.0
    restart: always
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd:2379
    ports:
      - "3379:2379"
    volumes:
      - etcd_data:/bitnami/etcd
    healthcheck:
      test: ["CMD", "etcdctl", "endpoint", "health"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  # API Gateway con NGINX
  nginx:
    image: nginx:1.21
    ports:
      - "81:80"
    volumes:
      - ./nginx-gateway/nginx-hybrid-plus.conf:/etc/nginx/nginx.conf:ro
    restart: unless-stopped
    depends_on:
      - simple-user
      - companies
    networks:
      - app-network

  # Servicio de usuario simplificado
  simple-user:
    build:
      context: ./simple-user
      dockerfile: Dockerfile
    environment:
      - TZ=UTC
    ports:
      - "8000:8000"
    restart: unless-stopped
    networks:
      - app-network

  # Servicio Companies
  companies:
    build:
      context: ./companies-service
      dockerfile: Dockerfile
    environment:
      - TZ=UTC
    ports:
      - "8010:8010"
    depends_on:
      - mysqld
      - redis
      - etcd
    restart: unless-stopped
    networks:
      - app-network

  # Frontend
  web:
    image: goxiaoy/go-saas-kit-frontend:dev
    ports:
      - "8080:80"
    volumes:
      - ./kit-frontend/docker/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - nginx
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mysql_data:
  etcd_data:
EOF
echo -e "${GREEN}✓ Docker Compose creado${NC}"
echo ""

# Paso 5: Iniciar los servicios
echo -e "${YELLOW}Paso 5: Iniciando servicios...${NC}"
docker compose -f docker-compose-hybrid-plus.yml up -d
echo -e "${GREEN}✓ Servicios iniciados${NC}"
echo ""

# Paso 6: Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Paso 6: Esperando a que los servicios estén disponibles...${NC}"
sleep 10
echo -e "${GREEN}✓ Espera completada${NC}"
echo ""

# Paso 7: Verificar estado de los servicios
echo -e "${YELLOW}Paso 7: Verificando estado de los servicios...${NC}"
docker ps | grep rantipay_saas
echo ""

# Verificar el servicio user
echo -e "${YELLOW}Verificando servicio User:${NC}"
USER_RESPONSE=$(curl -s http://localhost:8000/health 2>/dev/null || echo "Error")
if [[ "$USER_RESPONSE" == *"OK"* ]]; then
    echo -e "  ${GREEN}✓ Servicio User está funcionando correctamente${NC}"
else
    echo -e "  ${RED}✗ Servicio User NO está funcionando correctamente${NC}"
    echo -e "  Respuesta: $USER_RESPONSE"
    echo -e "  Verificando logs:"
    docker logs --tail 20 rantipay_saas-simple-user-1
fi

# Verificar NGINX
echo -e "${YELLOW}Verificando NGINX:${NC}"
NGINX_RESPONSE=$(curl -s http://localhost:81/health 2>/dev/null || echo "Error")
if [[ "$NGINX_RESPONSE" == *"Healthy"* ]]; then
    echo -e "  ${GREEN}✓ NGINX está funcionando correctamente${NC}"
else
    echo -e "  ${RED}✗ NGINX NO está funcionando correctamente${NC}"
    echo -e "  Respuesta: $NGINX_RESPONSE"
    echo -e "  Verificando logs:"
    docker logs --tail 20 rantipay_saas-nginx-1
fi

# Verificar Frontend
echo -e "${YELLOW}Verificando Frontend:${NC}"
FRONTEND_RESPONSE=$(curl -s -I http://localhost:8080 2>/dev/null | head -n 1 || echo "Error")
if [[ "$FRONTEND_RESPONSE" == *"200 OK"* ]]; then
    echo -e "  ${GREEN}✓ Frontend está funcionando correctamente${NC}"
else
    echo -e "  ${RED}✗ Frontend NO está funcionando correctamente${NC}"
    echo -e "  Respuesta: $FRONTEND_RESPONSE"
    echo -e "  Verificando logs:"
    docker logs --tail 20 rantipay_saas-web-1
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Sistema restaurado con usuario simplificado   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81${NC}"
echo -e "${GREEN}Servicio User disponible en: http://localhost:8000${NC}"
echo -e "${GREEN}Servicio Companies disponible en: http://localhost:8010${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f docker-compose-hybrid-plus.yml down${NC}"