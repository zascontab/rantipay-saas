#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Solucionando problemas del servicio User   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener los servicios
echo -e "${YELLOW}Paso 1: Deteniendo los servicios...${NC}"
docker compose -f docker-compose-full-user.yml down
echo -e "${GREEN}✓ Servicios detenidos${NC}"
echo ""

# Paso 2: Corregir la configuración del servicio User
echo -e "${YELLOW}Paso 2: Corrigiendo la configuración del servicio User...${NC}"
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
user:
  password_score_min: 0
  admin:
    username: admin@rantipay.com
    password: "Admin123!"
  idp: {}
logging:
  level: debug
INNEREOF
echo -e "${GREEN}✓ Configuración del servicio User corregida${NC}"
echo ""

# Paso 3: Corregir la configuración de NGINX
echo -e "${YELLOW}Paso 3: Corrigiendo la configuración de NGINX...${NC}"
mkdir -p nginx-gateway
cat > nginx-gateway/nginx-full.conf << 'INNEREOF'
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
        
        # Rutas para el servicio User
        location /v1/ {
            proxy_pass http://user:8000/v1/;
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
            proxy_pass http://user:8000/assets/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Ruta de fallback
        location / {
            return 404 'API Gateway: Endpoint not found';
        }
    }
}
INNEREOF
echo -e "${GREEN}✓ Configuración de NGINX corregida${NC}"
echo ""

# Paso 4: Actualizar el Dockerfile para usar una configuración más simple
echo -e "${YELLOW}Paso 4: Actualizando el Dockerfile...${NC}"
cat > kit/user/Dockerfile.simple << 'INNEREOF'
FROM golang:1.20 AS builder

WORKDIR /app
COPY . .

# Compilar el servicio user
WORKDIR /app/user
RUN go mod download
RUN make build

FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        curl \
        && rm -rf /var/lib/apt/lists/ \
        && apt-get autoremove -y && apt-get autoclean -y

WORKDIR /app

# Copiar el binario compilado y archivos necesarios
COPY --from=builder /app/user/bin/user /app/
COPY --from=builder /app/user/i18n /app/i18n

EXPOSE 8000
EXPOSE 9000

# Agregar un script para verificar la configuración y luego iniciar el servicio
COPY --from=builder /app/user/configs/config.yaml /app/default-config.yaml

# Agregar script de inicio
RUN echo '#!/bin/bash\n\
echo "Verificando configuración..."\n\
ls -la /data/conf\n\
if [ ! -f /data/conf/config.yaml ]; then\n\
  echo "Archivo de configuración no encontrado. Usando configuración por defecto..."\n\
  cp /app/default-config.yaml /data/conf/config.yaml\n\
fi\n\
echo "Iniciando servicio..."\n\
./user -conf /data/conf\n\
' > /app/start.sh && chmod +x /app/start.sh

VOLUME /data/conf
CMD ["/app/start.sh"]
INNEREOF
echo -e "${GREEN}✓ Dockerfile actualizado${NC}"
echo ""

# Paso 5: Reconstruir la imagen
echo -e "${YELLOW}Paso 5: Reconstruyendo la imagen...${NC}"
cd kit
docker build -t go-saas-kit-user:simple -f user/Dockerfile.simple .
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al reconstruir la imagen${NC}"
    exit 1
fi
cd ..
echo -e "${GREEN}✓ Imagen reconstruida exitosamente${NC}"
echo ""

# Paso 6: Actualizar el archivo docker-compose
echo -e "${YELLOW}Paso 6: Actualizando el archivo docker-compose...${NC}"
cat > docker-compose-simple-user.yml << 'INNEREOF'
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
      - ./nginx-gateway/nginx-full.conf:/etc/nginx/nginx.conf:ro
    restart: unless-stopped
    depends_on:
      - user
      - companies
    networks:
      - app-network

  # Servicio User con imagen simplificada
  user:
    image: go-saas-kit-user:simple
    environment:
      - TZ=UTC
    ports:
      - "8000:8000"
      - "9000:9000"
    volumes:
      - ./configs/user:/data/conf
      - ./kit/.assets:/app/.assets
    depends_on:
      - mysqld
      - redis
      - etcd
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
INNEREOF
echo -e "${GREEN}✓ Archivo docker-compose actualizado${NC}"
echo ""

# Paso 7: Iniciar los servicios
echo -e "${YELLOW}Paso 7: Iniciando los servicios...${NC}"
docker compose -f docker-compose-simple-user.yml up -d
echo -e "${GREEN}✓ Servicios iniciados${NC}"
echo ""

echo -e "${YELLOW}Esperando a que los servicios estén disponibles...${NC}"
sleep 10
echo ""

# Paso 8: Verificar los servicios
echo -e "${YELLOW}Paso 8: Verificando los servicios...${NC}"
echo -e "${YELLOW}8.1: Estado de los contenedores:${NC}"
docker ps | grep rantipay_saas
echo ""

echo -e "${YELLOW}8.2: Prueba del servicio User:${NC}"
curl -s http://localhost:8000/health
echo ""

echo -e "${YELLOW}8.3: Prueba del API Gateway:${NC}"
curl -s http://localhost:81/health
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicio User configurado correctamente   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81${NC}"
echo -e "${GREEN}Servicio User disponible en: http://localhost:8000${NC}"
echo ""
echo -e "${YELLOW}Para verificar los logs:${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-user-1${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-nginx-1${NC}"
