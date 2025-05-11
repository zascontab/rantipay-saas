#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Construyendo servicio user original   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Analizar la estructura del repositorio
echo -e "${YELLOW}Paso 1: Analizando la estructura del repositorio...${NC}"
if [ -d "kit/user" ]; then
    echo -e "${GREEN}Directorio 'kit/user' encontrado${NC}"
else
    echo -e "${RED}Directorio 'kit/user' no encontrado${NC}"
    echo -e "${YELLOW}Asegúrate de estar en el directorio raíz del proyecto${NC}"
    exit 1
fi

# Verificar si existe un archivo de configuración por defecto
CONFIG_FILES=$(find kit/ -name "config.yaml" -o -name "*.yaml" 2>/dev/null)
if [ -n "$CONFIG_FILES" ]; then
    echo -e "${GREEN}Archivos de configuración encontrados:${NC}"
    echo "$CONFIG_FILES"
else
    echo -e "${YELLOW}No se encontraron archivos de configuración. Deberemos crear uno.${NC}"
fi

echo -e "${GREEN}✓ Análisis completado${NC}"
echo ""

# Paso 2: Crear archivo de configuración básica
echo -e "${YELLOW}Paso 2: Creando archivo de configuración básica...${NC}"
mkdir -p configs/user
cat > configs/user/config.yaml << 'INNEREOF'
server:
  http:
    addr: 0.0.0.0:8000
    timeout: 60s
  grpc:
    addr: 0.0.0.0:9000
    timeout: 60s
data:
  database:
    driver: mysql
    source: root:youShouldChangeThis@tcp(mysqld:3306)/kit?parseTime=true&loc=Local&charset=utf8mb4&interpolateParams=true
  redis:
    addr: redis:6379
    password: youShouldChangeThis
    db: 0
security:
  jwt:
    expire_in: 2592000s # 30 days
    secret: youShouldChangeThis
  security_cookie:
    hash_key: youShouldChangeThis
user:
  password_score_min: 0
  admin:
    username: admin@rantipay.com
    password: "Admin123!"
logging:
  level: debug
INNEREOF
echo -e "${GREEN}✓ Archivo de configuración creado${NC}"
echo ""

# Paso 3: Crear Dockerfile para construir el servicio original
echo -e "${YELLOW}Paso 3: Creando Dockerfile para el servicio original...${NC}"
cat > kit/user/Dockerfile.original << 'INNEREOF'
FROM golang:1.20 AS builder

WORKDIR /src
COPY . .

# Construir el servicio user dentro del repositorio completo
WORKDIR /src/user
RUN go mod download
RUN go build -o /bin/user .

FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        && rm -rf /var/lib/apt/lists/ \
        && apt-get autoremove -y && apt-get autoclean -y

COPY --from=builder /bin/user /usr/local/bin/user
COPY --from=builder /src/user/i18n /app/i18n

WORKDIR /app

VOLUME /data/conf
EXPOSE 8000 9000

CMD ["user", "-conf", "/data/conf"]
INNEREOF
echo -e "${GREEN}✓ Dockerfile creado${NC}"
echo ""

# Paso 4: Construir la imagen
echo -e "${YELLOW}Paso 4: Construyendo la imagen...${NC}"
cd kit
docker build -t go-saas-kit-user:original -f user/Dockerfile.original .
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al construir la imagen. Verificando problemas...${NC}"
    # Verificar si se puede compilar el servicio manualmente
    cd user
    go mod download
    go build -o /tmp/user .
    if [ $? -ne 0 ]; then
        echo -e "${RED}× Error al compilar el servicio manualmente${NC}"
        echo -e "${YELLOW}Es posible que necesites configurar el entorno de desarrollo correctamente${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Compilación manual exitosa${NC}"
        echo -e "${YELLOW}Probando enfoque alternativo...${NC}"
        cd ..
        docker build -t go-saas-kit-user:original -f user/Dockerfile.original .
        if [ $? -ne 0 ]; then
            echo -e "${RED}× Error persistente al construir la imagen${NC}"
            exit 1
        fi
    fi
    cd ..
else
    cd ..
    echo -e "${GREEN}✓ Imagen construida exitosamente${NC}"
fi
echo ""

# Paso 5: Crear archivo docker-compose para el despliegue original
echo -e "${YELLOW}Paso 5: Creando archivo docker-compose para el despliegue original...${NC}"
cat > docker-compose-original-user.yml << 'INNEREOF'
version: '3'

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

  # Servicio user original
  user:
    image: go-saas-kit-user:original
    environment:
      - TZ=UTC
    volumes:
      - ./configs/user:/data/conf
    ports:
      - "8000:8000"
      - "9000:9000"
    depends_on:
      - mysqld
      - redis
      - etcd
    restart: unless-stopped
    networks:
      - app-network

  # API Gateway con NGINX
  nginx:
    image: nginx:1.21
    ports:
      - "81:80"
    volumes:
      - ./nginx-gateway/nginx-original.conf:/etc/nginx/nginx.conf:ro
    restart: unless-stopped
    depends_on:
      - user
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
INNEREOF
echo -e "${GREEN}✓ Archivo docker-compose creado${NC}"
echo ""

# Paso 6: Crear configuración NGINX para el servicio original
echo -e "${YELLOW}Paso 6: Creando configuración NGINX para el servicio original...${NC}"
mkdir -p nginx-gateway
cat > nginx-gateway/nginx-original.conf << 'INNEREOF'
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
        
        # Todas las rutas van al servicio user
        location / {
            proxy_pass http://user:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
INNEREOF
echo -e "${GREEN}✓ Configuración NGINX creada${NC}"
echo ""

# Paso 7: Desplegar usando docker-compose
echo -e "${YELLOW}Paso 7: Desplegando usando docker-compose...${NC}"
docker compose -f docker-compose-original-user.yml down
docker compose -f docker-compose-original-user.yml up -d
echo -e "${GREEN}✓ Despliegue iniciado${NC}"
echo ""

echo -e "${YELLOW}Esperando a que los servicios estén disponibles...${NC}"
sleep 10
echo ""

# Paso 8: Verificar el despliegue
echo -e "${YELLOW}Paso 8: Verificando el despliegue...${NC}"
echo -e "${YELLOW}8.1: Verificar contenedores:${NC}"
docker ps | grep -E 'user|nginx|web|mysql|redis|etcd'
echo ""

echo -e "${YELLOW}8.2: Verificar logs del servicio user:${NC}"
docker logs $(docker ps -qf "name=user") | tail -20
echo ""

echo -e "${YELLOW}8.3: Verificar logs de NGINX:${NC}"
docker logs $(docker ps -qf "name=nginx") | tail -20
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicio user original desplegado   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${YELLOW}Para verificar que todo está funcionando correctamente:${NC}"
echo -e "1. Abre ${GREEN}http://localhost:8080${NC} en tu navegador"
echo -e "2. Prueba iniciar sesión con ${GREEN}admin@rantipay.com${NC} / ${GREEN}Admin123!${NC}"
echo ""
echo -e "${YELLOW}Si encuentras problemas, puedes verificar los logs con:${NC}"
echo -e "${YELLOW}docker logs \$(docker ps -qf \"name=user\")${NC}"
echo -e "${YELLOW}docker logs \$(docker ps -qf \"name=nginx\")${NC}"
echo -e "${YELLOW}docker logs \$(docker ps -qf \"name=web\")${NC}"
echo -e ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f docker-compose-original-user.yml down${NC}"
echo ""
