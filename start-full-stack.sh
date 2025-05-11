#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Deteniendo contenedores existentes...${NC}"
docker compose -f docker-compose-full.yml down

echo -e "${YELLOW}Limpiando volúmenes antiguos...${NC}"
docker volume rm rantipay_saas_etcd_data 2>/dev/null || true
docker volume rm rantipay_saas_mysql_data 2>/dev/null || true

# Crear directorios necesarios
mkdir -p ./kit-frontend/docker/nginx/
mkdir -p ./nginx-gateway/

# Asegurarse de que los archivos de configuración existan
echo -e "${YELLOW}Verificando archivos de configuración...${NC}"
if [ ! -f ./nginx-gateway/nginx-full.conf ]; then
    echo -e "${RED}Falta el archivo de configuración nginx-full.conf. Por favor, crea este archivo.${NC}"
    exit 1
fi

if [ ! -f ./kit-frontend/docker/nginx/default.conf ]; then
    echo -e "${RED}Falta el archivo de configuración default.conf. Por favor, crea este archivo.${NC}"
    exit 1
fi

echo -e "${YELLOW}Iniciando servicios de infraestructura...${NC}"
docker compose -f docker-compose-full.yml up -d mysqld redis etcd

echo -e "${YELLOW}Esperando a que los servicios de infraestructura estén listos...${NC}"
sleep 15

echo -e "${YELLOW}Verificando estado de etcd...${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl endpoint health || {
    echo -e "${RED}Error: etcd no está saludable${NC}"
    docker logs $(docker ps -q -f name=rantipay_saas-etcd)
    exit 1
}

echo -e "${YELLOW}Verificando estado de MySQL...${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysqladmin -u root -pyouShouldChangeThis ping || {
    echo -e "${RED}Error: MySQL no está saludable${NC}"
    docker logs $(docker ps -q -f name=rantipay_saas-mysqld)
    exit 1
}

echo -e "${YELLOW}Verificando estado de Redis...${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-redis) redis-cli -a youShouldChangeThis ping || {
    echo -e "${RED}Error: Redis no está saludable${NC}"
    docker logs $(docker ps -q -f name=rantipay_saas-redis)
    exit 1
}

echo -e "${YELLOW}Iniciando servicios go-saas/kit...${NC}"
docker compose -f docker-compose-full.yml up -d user

# Esperar a que el servicio user esté listo antes de iniciar los demás
echo -e "${YELLOW}Esperando a que el servicio user esté listo...${NC}"
sleep 10

# Iniciar el resto de los servicios
echo -e "${YELLOW}Iniciando servicios saas y sys...${NC}"
docker compose -f docker-compose-full.yml up -d saas sys

echo -e "${YELLOW}Esperando a que los servicios estén listos...${NC}"
sleep 10

echo -e "${YELLOW}Iniciando API Gateway y Frontend...${NC}"
docker compose -f docker-compose-full.yml up -d nginx web

echo -e "${YELLOW}Esperando a que el sistema completo esté disponible...${NC}"
sleep 10

echo -e "${YELLOW}Verificando estado de los servicios...${NC}"

echo -e "${YELLOW}1. Servicio User:${NC}"
curl -s http://localhost:8000/v1/user/health || echo -e "${RED}No se puede acceder al servicio User${NC}"

echo -e "${YELLOW}2. Servicio SaaS:${NC}"
curl -s http://localhost:8002/v1/saas/health || echo -e "${RED}No se puede acceder al servicio SaaS${NC}"

echo -e "${YELLOW}3. Servicio Sys:${NC}"
curl -s http://localhost:8003/v1/sys/health || echo -e "${RED}No se puede acceder al servicio Sys${NC}"

echo -e "${YELLOW}4. API Gateway:${NC}"
curl -s http://localhost:81/health || echo -e "${RED}No se puede acceder al API Gateway${NC}"

echo -e "${GREEN}Configuración completa.${NC}"
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81/v1/${NC}"
echo -e "${GREEN}Servicios individuales disponibles en:${NC}"
echo -e "${GREEN}  - User: http://localhost:8000${NC}"
echo -e "${GREEN}  - SaaS: http://localhost:8002${NC}"
echo -e "${GREEN}  - Sys: http://localhost:8003${NC}"

echo -e "${YELLOW}Para ver los logs de un servicio, ejecuta:${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-[nombre_servicio]-1${NC}"

echo -e "${YELLOW}Para detener todos los servicios, ejecuta:${NC}"
echo -e "${YELLOW}docker compose -f docker-compose-full.yml down${NC}"