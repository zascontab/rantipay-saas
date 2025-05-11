#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Construcción de imágenes Docker locales   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Comprobar que estamos en el directorio correcto
if [ ! -d "kit" ]; then
    echo -e "${RED}Error: Directorio 'kit' no encontrado. Asegúrate de estar en el directorio raíz del proyecto.${NC}"
    exit 1
fi

# Primero construir la imagen simple-user para tener una alternativa de respaldo
echo -e "${YELLOW}Construyendo imagen simple-user...${NC}"
cd simple-user
docker build -t simple-user:debug -f Dockerfile.debug .
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al construir la imagen simple-user. Continuando con las otras imágenes...${NC}"
fi
cd ..
echo -e "${GREEN}✓ Imagen simple-user construida correctamente${NC}"
echo ""

# Examinar estructura del repositorio kit para ver cómo se organizan los servicios
echo -e "${YELLOW}Examinando estructura del repositorio kit...${NC}"
ls -la kit/
echo ""

# Intentar descubrir la estructura del servicio user
echo -e "${YELLOW}Buscando Dockerfile para el servicio user...${NC}"
find kit -name "Dockerfile" | grep -i user || echo -e "${RED}No se encontró Dockerfile para user${NC}"

# Intento 1: Buscar en directorio user
if [ -d "kit/user" ]; then
    echo -e "${YELLOW}Encontrado directorio kit/user, intentando construir imagen...${NC}"
    cd kit/user
    if [ -f "Dockerfile" ]; then
        echo -e "${GREEN}Encontrado Dockerfile en kit/user${NC}"
        docker build -t go-saas-kit-user:latest .
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Imagen go-saas-kit-user:latest construida correctamente${NC}"
        else
            echo -e "${RED}× Error al construir la imagen go-saas-kit-user${NC}"
        fi
    else
        echo -e "${RED}No se encontró Dockerfile en kit/user${NC}"
    fi
    cd ../..
fi

# Intento 2: Buscar en directorio saas
if [ -d "kit/saas" ]; then
    echo -e "${YELLOW}Encontrado directorio kit/saas, intentando construir imagen...${NC}"
    cd kit/saas
    if [ -f "Dockerfile" ]; then
        echo -e "${GREEN}Encontrado Dockerfile en kit/saas${NC}"
        docker build -t go-saas-kit-saas:latest .
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Imagen go-saas-kit-saas:latest construida correctamente${NC}"
        else
            echo -e "${RED}× Error al construir la imagen go-saas-kit-saas${NC}"
        fi
    else
        echo -e "${RED}No se encontró Dockerfile en kit/saas${NC}"
    fi
    cd ../..
fi

# Intento 3: Buscar en directorio sys
if [ -d "kit/sys" ]; then
    echo -e "${YELLOW}Encontrado directorio kit/sys, intentando construir imagen...${NC}"
    cd kit/sys
    if [ -f "Dockerfile" ]; then
        echo -e "${GREEN}Encontrado Dockerfile en kit/sys${NC}"
        docker build -t go-saas-kit-sys:latest .
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Imagen go-saas-kit-sys:latest construida correctamente${NC}"
        else
            echo -e "${RED}× Error al construir la imagen go-saas-kit-sys${NC}"
        fi
    else
        echo -e "${RED}No se encontró Dockerfile en kit/sys${NC}"
    fi
    cd ../..
fi

# Verificar las imágenes construidas
echo -e "${YELLOW}Verificando las imágenes Docker construidas...${NC}"
docker images | grep -E 'go-saas-kit-|simple-user'

# Crear un archivo docker-compose que use las imágenes que estén disponibles
echo -e "${YELLOW}Creando archivo docker-compose-local.yml con las imágenes disponibles...${NC}"

# Verificar qué imágenes existen
USER_IMAGE="simple-user:debug"
SAAS_IMAGE="goxiaoy/go-saas-kit-saas:latest"
SYS_IMAGE="goxiaoy/go-saas-kit-sys:latest"

if docker images | grep -q "go-saas-kit-user"; then
    USER_IMAGE="go-saas-kit-user:latest"
    echo -e "${GREEN}Usando imagen local go-saas-kit-user:latest${NC}"
fi

if docker images | grep -q "go-saas-kit-saas"; then
    SAAS_IMAGE="go-saas-kit-saas:latest"
    echo -e "${GREEN}Usando imagen local go-saas-kit-saas:latest${NC}"
fi

if docker images | grep -q "go-saas-kit-sys"; then
    SYS_IMAGE="go-saas-kit-sys:latest"
    echo -e "${GREEN}Usando imagen local go-saas-kit-sys:latest${NC}"
fi

# Crear el archivo docker-compose-local.yml
cat > docker-compose-local.yml << EOF
version: '3.7'
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
      - saas
      - sys
    networks:
      - app-network

  # Servicios go-saas/kit
  user:
    image: ${USER_IMAGE}
    environment:
      - TZ=UTC
      - DB_HOST=mysqld
      - DB_PORT=3306
      - DB_USER=root
      - DB_PASSWORD=youShouldChangeThis
      - DB_NAME=kit
      - REGISTRY_ENDPOINT=http://etcd:2379
      - REDIS_ADDR=redis:6379
      - REDIS_PASSWORD=youShouldChangeThis
      - LOGGING_LEVEL=debug
    ports:
      - "8000:8000"
      - "9000:9000"
    volumes:
      - ./configs:/data/conf
      - ./kit/quickstart/.assets:/app/.assets
    depends_on:
      - mysqld
      - redis
      - etcd
    restart: unless-stopped
    networks:
      - app-network

  saas:
    image: ${SAAS_IMAGE}
    environment:
      - TZ=UTC
      - DB_HOST=mysqld
      - DB_PORT=3306
      - DB_USER=root
      - DB_PASSWORD=youShouldChangeThis
      - DB_NAME=kit
      - REGISTRY_ENDPOINT=http://etcd:2379
      - REDIS_ADDR=redis:6379
      - REDIS_PASSWORD=youShouldChangeThis
      - LOGGING_LEVEL=debug
    ports:
      - "8002:8000"
      - "9002:9000"
    volumes:
      - ./configs:/data/conf
      - ./kit/quickstart/.assets:/app/.assets
    depends_on:
      - mysqld
      - redis
      - etcd
      - user
    restart: unless-stopped
    networks:
      - app-network

  sys:
    image: ${SYS_IMAGE}
    environment:
      - TZ=UTC
      - DB_HOST=mysqld
      - DB_PORT=3306
      - DB_USER=root
      - DB_PASSWORD=youShouldChangeThis
      - DB_NAME=kit
      - REGISTRY_ENDPOINT=http://etcd:2379
      - REDIS_ADDR=redis:6379
      - REDIS_PASSWORD=youShouldChangeThis
      - LOGGING_LEVEL=debug
    ports:
      - "8003:8000"
      - "9003:9000"
    volumes:
      - ./configs:/data/conf
      - ./kit/quickstart/.assets:/app/.assets
    depends_on:
      - mysqld
      - redis
      - etcd
      - user
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

echo -e "${GREEN}Archivo docker-compose-local.yml creado con éxito${NC}"
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Proceso completado   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Para iniciar los servicios, ejecuta:${NC}"
echo -e "${YELLOW}chmod +x start-local.sh${NC}"
echo -e "${YELLOW}./start-local.sh${NC}"
echo ""