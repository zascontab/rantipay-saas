#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Configurando entorno base Rantipay SaaS   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Crear directorios necesarios
mkdir -p configs/{user,saas,sys} data/assets logs

# Crear archivo docker-compose.yml
cat > docker-compose.yml << 'EOFDC'
version: '3'

services:
  # Infraestructura
  etcd:
    image: bitnami/etcd:3.5.0
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd:2379
    ports:
      - "2379:2379"
    volumes:
      - etcd_data:/bitnami/etcd
    networks:
      - rantipay-network

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=rantipay123
      - MYSQL_ROOT_HOST=%
      - MYSQL_DATABASE=rantipay
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - rantipay-network

  redis:
    image: redis:6.0
    command: redis-server --requirepass rantipay123
    ports:
      - "6379:6379"
    networks:
      - rantipay-network

  # API Gateway
  apisix:
    image: apache/apisix:2.15.0-alpine
    volumes:
      - ./kit/deploy/apisix/config.yaml:/usr/local/apisix/conf/config.yaml:ro
      - ./kit/deploy/apisix/apisix.yaml:/usr/local/apisix/conf/apisix.yaml:ro
    ports:
      - "9080:9080"
      - "9180:9180"
    depends_on:
      - etcd
    networks:
      - rantipay-network

  apisix-dashboard:
    image: apache/apisix-dashboard:2.15.0-alpine
    volumes:
      - ./kit/deploy/apisix/dashboard_conf/conf.yaml:/usr/local/apisix-dashboard/conf/conf.yaml:ro
    ports:
      - "9000:9000"
    depends_on:
      - apisix
    networks:
      - rantipay-network

networks:
  rantipay-network:
    driver: bridge

volumes:
  mysql_data:
  etcd_data:
EOFDC

echo -e "${GREEN}✓ Archivo docker-compose.yml creado${NC}"
echo -e "${YELLOW}Iniciando servicios de infraestructura...${NC}"

# Iniciar servicios de infraestructura
docker compose up -d etcd mysql redis apisix apisix-dashboard

echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""
echo -e "${YELLOW}Servicios disponibles:${NC}"
echo -e "${GREEN}- ETCD: localhost:2379${NC}"
echo -e "${GREEN}- MySQL: localhost:3306${NC}"
echo -e "${GREEN}- Redis: localhost:6379${NC}"
echo -e "${GREEN}- APISIX: localhost:9080${NC}"
echo -e "${GREEN}- APISIX Dashboard: localhost:9000${NC}"