#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Configuración completa de Rantipay SaaS    ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Verificar si Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker no está en ejecución${NC}"
    exit 1
fi

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f docker-compose-full.yml down
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Limpiar volúmenes antiguos
echo -e "${YELLOW}Paso 2: Limpiando volúmenes antiguos...${NC}"
docker volume rm rantipay_saas_etcd_data 2>/dev/null || true
docker volume rm rantipay_saas_mysql_data 2>/dev/null || true
echo -e "${GREEN}✓ Volúmenes antiguos limpiados${NC}"
echo ""

# Paso 3: Inicio de servicios de infraestructura
echo -e "${YELLOW}Paso 3: Iniciando servicios de infraestructura...${NC}"
docker compose -f docker-compose-full.yml up -d mysqld redis etcd
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 4: Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Paso 4: Esperando a que los servicios de infraestructura estén disponibles...${NC}"
for i in {1..15}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysqladmin -u root -pyouShouldChangeThis ping 2>/dev/null; then
        echo -e "${GREEN}✓ MySQL está listo${NC}"
        break
    fi
    if [ $i -eq 15 ]; then
        echo -e "${RED}× Tiempo de espera agotado para MySQL${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done

for i in {1..15}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-redis) redis-cli -a youShouldChangeThis ping 2>/dev/null | grep -q "PONG"; then
        echo -e "${GREEN}✓ Redis está listo${NC}"
        break
    fi
    if [ $i -eq 15 ]; then
        echo -e "${RED}× Tiempo de espera agotado para Redis${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done

for i in {1..15}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl endpoint health 2>/dev/null; then
        echo -e "${GREEN}✓ ETCD está listo${NC}"
        break
    fi
    if [ $i -eq 15 ]; then
        echo -e "${RED}× Tiempo de espera agotado para ETCD${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Paso 5: Inicializar la base de datos
echo -e "${YELLOW}Paso 5: Inicializando base de datos...${NC}"
./init-database.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar la base de datos${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Base de datos inicializada${NC}"
echo ""

# Paso 6: Registrar servicios en ETCD
echo -e "${YELLOW}Paso 6: Inicializando ETCD...${NC}"
./init-etcd.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar ETCD${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ETCD inicializado${NC}"
echo ""

# Paso 7: Iniciar servicios go-saas/kit
echo -e "${YELLOW}Paso 7: Iniciando servicios go-saas/kit...${NC}"
echo -e "${YELLOW}7.1: Iniciando servicio user...${NC}"
docker compose -f docker-compose-full.yml up -d user
sleep 10  # Esperar a que user esté listo

echo -e "${YELLOW}7.2: Iniciando servicios saas y sys...${NC}"
docker compose -f docker-compose-full.yml up -d saas sys
sleep 10  # Esperar a que todos los servicios estén listos
echo -e "${GREEN}✓ Servicios go-saas/kit iniciados${NC}"
echo ""

# Paso 8: Iniciar API Gateway y Frontend
echo -e "${YELLOW}Paso 8: Iniciando API Gateway y Frontend...${NC}"
docker compose -f docker-compose-full.yml up -d nginx web
sleep 5  # Esperar a que el gateway y frontend estén listos
echo -e "${GREEN}✓ API Gateway y Frontend iniciados${NC}"
echo ""

# Paso 9: Verificar todos los servicios
echo -e "${YELLOW}Paso 9: Verificando todos los servicios...${NC}"
./check-services.sh
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Plataforma Rantipay SaaS lista para usar   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81/v1/${NC}"
echo -e "${GREEN}Servicios individuales disponibles en:${NC}"
echo -e "${GREEN}  - User: http://localhost:8000${NC}"
echo -e "${GREEN}  - SaaS: http://localhost:8002${NC}"
echo -e "${GREEN}  - Sys: http://localhost:8003${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f docker-compose-full.yml down${NC}"
echo ""
echo -e "${YELLOW}Para verificar el estado de los servicios:${NC}"
echo -e "${YELLOW}./check-services.sh${NC}"