#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-hybrid-plus.yml"
UPDATED_COMPOSE_FILE="docker-compose-full-user.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Actualizando Docker Compose para Usar Servicio Completo de Usuario   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Verificar que el archivo docker-compose-hybrid-plus.yml existe
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}Error: No se encontró el archivo $DOCKER_COMPOSE_FILE${NC}"
    echo -e "${YELLOW}Asegúrate de estar en el directorio raíz del proyecto rantipay_saas${NC}"
    exit 1
fi

# Paso 2: Crear directorio para la configuración del usuario si no existe
mkdir -p configs/user

# Paso 3: Copiar el archivo de configuración del usuario
echo -e "${YELLOW}Copiando archivo de configuración del usuario...${NC}"
cp user-config.yaml configs/user/config.yaml
echo -e "${GREEN}✓ Archivo de configuración copiado${NC}"

# Paso 4: Crear nuevo archivo docker-compose
echo -e "${YELLOW}Creando nuevo archivo docker-compose...${NC}"
cat > $UPDATED_COMPOSE_FILE << 'EOF'
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
      - user
      - companies
    networks:
      - app-network

  # Servicio completo de usuario
  user:
    image: go-saas-kit-user:latest
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
EOF

echo -e "${GREEN}✓ Nuevo archivo docker-compose creado: $UPDATED_COMPOSE_FILE${NC}"
echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Docker Compose Actualizado   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${YELLOW}Para iniciar el sistema con el servicio completo de usuario, ejecuta:${NC}"
echo -e "${YELLOW}docker compose -f $UPDATED_COMPOSE_FILE down${NC}"
echo -e "${YELLOW}docker compose -f $UPDATED_COMPOSE_FILE up -d${NC}"
echo ""
echo -e "${YELLOW}Para inicializar la base de datos y ETCD:${NC}"
echo -e "${YELLOW}./init-database.sh${NC}"
echo -e "${YELLOW}./init-etcd.sh${NC}"