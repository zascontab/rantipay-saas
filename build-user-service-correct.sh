#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Construyendo servicio user correctamente   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Encontrar el archivo main.go
echo -e "${YELLOW}Paso 1: Buscando el punto de entrada del servicio...${NC}"
MAIN_GO=$(find kit/user -name "main.go" | grep -v "test" | head -1)
if [ -n "$MAIN_GO" ]; then
    echo -e "${GREEN}Archivo principal encontrado: $MAIN_GO${NC}"
    MAIN_DIR=$(dirname "$MAIN_GO")
    echo -e "${GREEN}Directorio principal: $MAIN_DIR${NC}"
else
    echo -e "${RED}No se encontró el archivo main.go${NC}"
    echo -e "${YELLOW}Buscando directorio cmd...${NC}"
    if [ -d "kit/user/cmd" ]; then
        echo -e "${GREEN}Directorio cmd encontrado${NC}"
        echo -e "${YELLOW}Contenido del directorio cmd:${NC}"
        ls -la kit/user/cmd/
        
        # Verificar subdirectorios en cmd
        SUB_DIRS=$(find kit/user/cmd -type d -mindepth 1 | head -1)
        if [ -n "$SUB_DIRS" ]; then
            echo -e "${GREEN}Subdirectorio encontrado: $SUB_DIRS${NC}"
            MAIN_DIR="$SUB_DIRS"
        else
            echo -e "${RED}No se encontraron subdirectorios en cmd${NC}"
            MAIN_DIR="kit/user/cmd"
        fi
    else
        echo -e "${RED}No se encontró el directorio cmd${NC}"
        echo -e "${YELLOW}Usando directorio user como alternativa${NC}"
        MAIN_DIR="kit/user"
    fi
fi
echo -e "${GREEN}Usando directorio principal: $MAIN_DIR${NC}"
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

# Paso 3: Crear Dockerfile actualizado
echo -e "${YELLOW}Paso 3: Creando Dockerfile actualizado...${NC}"
cat > kit/user/Dockerfile.corrected << 'INNEREOF'
FROM golang:1.20 AS builder

WORKDIR /src
COPY . .

# Compilar el servicio user
WORKDIR /src/user/cmd/server
RUN go mod tidy
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
echo -e "${GREEN}✓ Dockerfile actualizado${NC}"
echo ""

# Paso 4: Construir la imagen
echo -e "${YELLOW}Paso 4: Construyendo la imagen...${NC}"
cd kit
docker build -t go-saas-kit-user:corrected -f user/Dockerfile.corrected .
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al construir la imagen con /cmd/server. Probando con /cmd/user...${NC}"
    
    # Crear un Dockerfile alternativo
    cat > user/Dockerfile.corrected2 << 'INNEREOF'
FROM golang:1.20 AS builder

WORKDIR /src
COPY . .

# Compilar el servicio user
WORKDIR /src/user/cmd/user
RUN go mod tidy
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
    
    docker build -t go-saas-kit-user:corrected -f user/Dockerfile.corrected2 .
    if [ $? -ne 0 ]; then
        echo -e "${RED}× Error al construir la imagen con /cmd/user. Usando el servicio simple-user existente...${NC}"
        cd ..
        echo -e "${YELLOW}Usando el servicio simple-user como alternativa${NC}"
        echo -e "${YELLOW}Crea el servicio simple-user con ./fix-404-errors.sh y usa esa base${NC}"
        echo -e "${YELLOW}para desarrollar gradualmente la funcionalidad completa.${NC}"
        exit 1
    fi
    cd ..
else
    cd ..
    echo -e "${GREEN}✓ Imagen construida exitosamente${NC}"
fi
echo ""

# Paso 5: Crear archivo docker-compose actualizado
echo -e "${YELLOW}Paso 5: Creando archivo docker-compose actualizado...${NC}"
cat > docker-compose-corrected-user.yml << 'INNEREOF'
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
    image: go-saas-kit-user:corrected
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
echo -e "${GREEN}✓ Archivo docker-compose actualizado${NC}"
echo ""

# Paso 6: Crear configuración NGINX
echo -e "${YELLOW}Paso 6: Creando configuración NGINX...${NC}"
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

# Paso 7: Decisión final
echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Conclusiones y Recomendaciones   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""
echo -e "${GREEN}Después de analizar la estructura del repositorio kit/user, se encontró que:${NC}"
echo -e "1. La estructura no sigue un patrón estándar con un archivo main.go en la raíz."
echo -e "2. El directorio cmd podría contener múltiples puntos de entrada."
echo ""
echo -e "${YELLOW}Recomendaciones:${NC}"
echo -e "1. Usa el enfoque híbrido: Mantén el servicio simple-user que ya construiste para tener"
echo -e "   un entorno de desarrollo funcional, mientras sigues explorando kit/user."
echo -e "2. Construye el servicio user original gradualmente a medida que comprendes mejor su estructura."
echo -e "3. La implementación completa de go-saas/kit puede ser compleja, así que es mejor"
echo -e "   seguir un enfoque iterativo, añadiendo más funcionalidades a medida que sea necesario."
echo ""
echo -e "${GREEN}Comandos para continuar:${NC}"
echo -e "1. Volver al servicio simple-user funcional:${NC}"
echo -e "   ${YELLOW}./fix-404-errors.sh${NC}"
echo -e "2. Si la compilación del servicio original tiene éxito, puedes desplegarlo con:${NC}"
echo -e "   ${YELLOW}docker compose -f docker-compose-corrected-user.yml up -d${NC}"
echo ""
echo -e "${YELLOW}¿Quieres intentar compilar el servicio con una estructura corregida?${NC}"
echo -e "1. Sí: Ejecuta ${YELLOW}docker compose -f docker-compose-corrected-user.yml up -d${NC}"
echo -e "2. No: Mantén el servicio simple-user con ${YELLOW}./fix-404-errors.sh${NC}"
echo ""
